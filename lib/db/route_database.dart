import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tracking_app/model/route.dart';

class RoutesDatabase {
  static final RoutesDatabase instance = RoutesDatabase._init();

  static Database? _database;

  RoutesDatabase._init();

  // accesses database, or creates one if none exists
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('Routes.db');
    return _database!;
  }

  // initialiezes database and opens it
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // creates database
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final doubleType = 'DOUBLE NOT NULL';

    // creates route table
    await db.execute('''
    CREATE TABLE $tableRoutes (
      ${RoutesFields.id} $idType,
      ${RoutesFields.name} $textType
    )
    ''');
    // creates route point table
    await db.execute('''
    CREATE TABLE $tableRoutePoints (
      ${RoutePointFields.id} $idType,
      ${RoutePointFields.routeId} $intType,
      ${RoutePointFields.lat} $doubleType,
      ${RoutePointFields.long} $doubleType,
      FOREIGN KEY(${RoutePointFields.routeId}) REFERENCES $tableRoutes(${RoutesFields.id}) ON DELETE CASCADE
    )
    ''');
  }

  // saves route to database
  Future<Routes> create(Routes route) async {
    final db = await instance.database;

    final id = await db.insert(tableRoutes, route.toJson());

    return route.copy(id: id);
  }

  // saves route point to database
  Future<RoutePoint> createRoutePoint(RoutePoint point) async {
    final db = await instance.database;

    final id = await db.insert(tableRoutePoints, point.toJson());
    return point.copy(id: id);
  }

  // returns route from database
  Future<Routes> readRoute(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableRoutes,
      columns: RoutesFields.values,
      where: '${RoutesFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Routes.fromJson(maps.first);
    } else {
      throw Exception('ID not found');
    }
  }

  // returns list of routes from database
  Future<List<Routes>> readAllRoutes() async {
    final db = await instance.database;

    final result = await db.query(tableRoutes);

    return result.map((json) => Routes.fromJson(json)).toList();
  }

  // returns list of points for a specific point
  Future<List<RoutePoint>> readRoutePoints(int routeId) async {
    final db = await instance.database;

    final result = await db.query(
      tableRoutePoints,
      columns: RoutePointFields.values,
      where: '${RoutePointFields.routeId} = ?',
      whereArgs: [routeId],
    );

    return result.map((json) => RoutePoint.fromJson(json)).toList();
  }
}
