final String tableRoutes = 'Routes';
final String tableRoutePoints = 'RoutePoints';

// class for what will be saved to the database for a route
class RoutesFields {
  static final List<String> values = [id, name];

  static final String id = '_id';
  static final String name = 'name';
}

// class for what will be saved to the database for a route point
class RoutePointFields {
  static final List<String> values = [id, routeId, lat, long];
  static final String id = '_id';
  static final String routeId = '_route_id';
  static final String lat = '_latitude';
  static final String long = '_longitude';
}

// class for route, used Routes because Route is a use variable
class Routes {
  final int? id;
  final String name;

  // the route class constructor
  const Routes({this.id, required this.name});

  Routes copy({int? id, String? name}) =>
      Routes(id: id ?? this.id, name: name ?? this.name);

  static Routes fromJson(Map<String, Object?> json) => Routes(
    id: json[RoutesFields.id] as int,
    name: json[RoutesFields.name] as String,
  );

  Map<String, Object?> toJson() => {
    RoutesFields.id: id,
    RoutesFields.name: name,
  };
}

// used for the different routepoints
class RoutePoint {
  final int? id;
  final int routeId;
  final double lat;
  final double long;

  // the route point class constructor
  const RoutePoint({
    this.id,
    required this.routeId,
    required this.lat,
    required this.long,
  });

  RoutePoint copy({int? routeId ,int? id, double? lat, double? long}) =>
      RoutePoint(
        id: id ?? this.id,
        routeId: routeId ?? this.routeId,
        lat: lat ?? this.lat,
        long: long ?? this.long,
      );

  // converts map to object
  static RoutePoint fromJson(Map<String, Object?> json) => RoutePoint(
    routeId: json[RoutePointFields.routeId] as int,
    id: json[RoutePointFields.id] as int,
    lat: json[RoutePointFields.lat] as double,
    long: json[RoutePointFields.long] as double,
  );

  // converts object to map
  Map<String, Object?> toJson() => {
    RoutePointFields.routeId: routeId,
    RoutePointFields.id: id,
    RoutePointFields.lat: lat,
    RoutePointFields.long: long,
  };
}
