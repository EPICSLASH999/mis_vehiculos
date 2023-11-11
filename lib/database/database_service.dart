import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/gastos_archivados.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _baseDeDatosEnEjecucion;

class DatabaseService {
  Database? get _database => _baseDeDatosEnEjecucion;

  Future<Database> get database async {
    if (_database != null){
      return _database!;
    }
    _baseDeDatosEnEjecucion = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = nombreBD;
    final path = await getDatabasesPath();
    return join(path,name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 2,
      onOpen: turnOnForeignKeys,
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
    await GastosArchivados().createTable(database);
    print('CREATED');
  }

  Future<void> turnOnForeignKeys(Database database) async {
     // Sql-lite necesita hacer esto manualmente para poder usar llaver foraneas
    await database.execute("""PRAGMA foreign_keys = ON;""");
    //print('---> ACTIVATED FK !');
  }

  Future<void> recrearTablas(Database database) async {
    database.execute('DROP TABLE IF EXISTS ${Gastos().tableName}');
    await Gastos().createTable(database);
  }
}