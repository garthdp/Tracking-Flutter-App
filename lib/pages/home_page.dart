import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../db/route_database.dart';
import '../model/route.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final Location _locationController = Location();

  // checks whether the user is tracking or not
  bool tracking = false;

  // saves users current route
  List<LatLng> route = [];

  // subscribes to the stream onLocationChanged,
  // it is used to save route points every time it updates the users location.
  StreamSubscription<LocationData>? _locationSubscription;

  bool displayRoute = false;

  // used to display google maps
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // saves users current location
  LatLng? _currentP;

  Set<Marker> customMarkers = {};

  // saves routes lines
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // checks if users location is known, if not shows loading text,
          // if known shows user on map
          _currentP == null
              ? const Center(child: Text("Loading..."))
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated:
                        (GoogleMapController controller) =>
                            _mapController.complete(controller),
                    initialCameraPosition: CameraPosition(
                      target: _currentP!,
                      zoom: 15,
                    ),
                    // shows user location as a marker
                    markers: {
                      Marker(
                        markerId: MarkerId("_currentLocation"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                        position: _currentP!,
                      ),
                      ...customMarkers,
                    },
                    polylines: Set<Polyline>.of(polylines.values),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 20,
                    // button which shows users saved routes
                    child: ElevatedButton.icon(
                      onPressed: showSavedRoutes,
                      icon: const Icon(Icons.map),
                      label: const Text("View Saved Routes"),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 20,
                    // button which starts and stops tracking.
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (tracking) {
                            tracking = false;
                          } else {
                            polylines.clear();
                            customMarkers.clear();
                            tracking = true;
                          }
                        });
                        startEndTracking(tracking);
                      },
                      // changes text/icon based on if the user is tracking or not
                      icon: Icon(tracking ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        tracking ? "Stop Tracking" : "Start Tracking",
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  // sets camera on users position
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 13);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  // gets updates on users location
  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();

    // checks is location service is allowed
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    // checks if permission is granted for location
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    // gets and saves users location
    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });

        // prevents camera from panning when displaying route
        if (!displayRoute) {
          // moves camera to users location
          _cameraToPosition(_currentP!);
        }
      }
    });
  }

  // generates lines from the points saved from the route the user took
  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.lightBlue,
      points: polylineCoordinates,
      width: 8,
    );

    //sets routes start marker
    Marker startMarker = Marker(
      markerId: MarkerId("start"),
      position: polylineCoordinates.first,
      infoWindow: InfoWindow(title: "Start"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    //sets routes end marker
    Marker endMarker = Marker(
      markerId: MarkerId("end"),
      position: polylineCoordinates.last,
      infoWindow: InfoWindow(title: "End"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    // updates line and markers
    setState(() {
      polylines[id] = polyline;
      customMarkers = {startMarker, endMarker};
    });
  }

  // shows dialog which allows user to save or cancel route
  Future<void> showSaveRouteDialog() async {
    String routeName = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Route'),
          content: TextField(
            onChanged: (value) {
              routeName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Route Name',
              hintText: 'Enter a name for this route',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  route.clear();
                  polylines.clear();
                  customMarkers.clear();
                });
              },
            ),
            // button which saves route
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // only saves if name is not null
                if (routeName.trim().isNotEmpty) {
                  // saves route to database
                  final newRoute = Routes(name: routeName);
                  final savedRoute = await RoutesDatabase.instance.create(
                    newRoute,
                  );
                  // saves routes points to database
                  for (var point in route) {
                    RoutePoint savePoint = RoutePoint(
                      routeId: savedRoute.id!,
                      lat: point.latitude,
                      long: point.longitude,
                    );
                    await RoutesDatabase.instance.createRoutePoint(savePoint);
                  }

                  // clears route when done saving
                  setState(() {
                    route.clear();
                  });

                  //closes dialog box
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // shows a list of previous saved routes
  Future<void> showSavedRoutes() async {
    List<Routes> routes = await RoutesDatabase.instance.readAllRoutes();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a Route"),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: routes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(routes[index].name),
                  onTap: () {
                    Navigator.of(context).pop();
                    loadAndDisplayRoute(routes[index].id!);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // gets routes points from database and shows it on map
  Future<void> loadAndDisplayRoute(int routeId) async {
    // gets list of points from database
    List<RoutePoint> savedPoints = await RoutesDatabase.instance
        .readRoutePoints(routeId);

    // makes a <LatLng> list from the RoutePoints list for line and marker
    List<LatLng> loadedRoute =
        savedPoints.map((point) => LatLng(point.lat, point.long)).toList();

    // clears previous route
    // prevents camera from panning when displaying route
    if (loadedRoute.isNotEmpty) {
      setState(() {
        route.clear();
        polylines.clear();
        displayRoute = true;
      });

      // generates line and moves camera to start marker
      generatePolylineFromPoints(loadedRoute);
      _cameraToPosition(loadedRoute.first);
    }
  }

  // starts and ends tracking
  void startEndTracking(bool start) async {
    // checks if tracking
    if (start) {

      // pans camera to user location on tracking start
      if(displayRoute){
        setState(() {
          displayRoute = false;
        });
        _cameraToPosition(_currentP!);
      }

      // runs everytime the users location is updated
      _locationSubscription = _locationController.onLocationChanged.listen((
        locationData,
      ) async {
        // checks if location data is null
        if (locationData.latitude != null && locationData.longitude != null) {
          // makes point
          LatLng newPoint = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );

          // adds route to list
          setState(() {
            route.add(newPoint);
          });

          // if the route list is bigger than one it makes generates/updates the route line
          if (route.length > 1) {
            generatePolylineFromPoints(List.from(route));
          }
        }
      });
    } else {
      // cancels location subscription and shows save dialog
      _locationSubscription?.cancel();
      _locationSubscription = null;
      setState(() {
        displayRoute = false;
        route = [];
      });
      await showSaveRouteDialog();
    }
  }
}
