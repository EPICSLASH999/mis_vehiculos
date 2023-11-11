import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _baseDeDatosEnEjecucion;

class DatabaseService {
  Database? get _database => _baseDeDatosEnEjecucion;

  Future<Database> get database async {
    if (_database != null){
      //print('ALREADY INITIALIZED !');
      return _database!;
    }
    _baseDeDatosEnEjecucion = await _initialize();
    //print('INITIALIZED !');
    turnOnForeignKeys(_database!); // Sql-lite necesita hacer esto manualmente para poder usar llaver foraneas
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'mis_vehiculos.db';
    final path = await getDatabasesPath();
    return join(path,name);
  }

  Future<Database> _initialize() async {
    //print('INITIALIZING...');
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    //recrearTablas(database);
    return database;
  }

  Future<void> create(Database database, int version) async {
    await Vehiculos().createTable(database);
    await Etiquetas().createTable(database);
    await Gastos().createTable(database);
  }

  Future<void> turnOnForeignKeys(Database database) async {
    await database.execute("""PRAGMA foreign_keys = ON;""");
  }

  Future<void> recrearTablas(Database database) async {
    database.execute('DROP TABLE IF EXISTS ${Gastos().tableName}');
    await Gastos().createTable(database);
  }
}