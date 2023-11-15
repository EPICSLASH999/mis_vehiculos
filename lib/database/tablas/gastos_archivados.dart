import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

class GastosArchivados {
  final tableName = tablaGastosArchivados;

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
      "id_gasto_archivado" INTEGER NOT NULL,
      "vehiculo" TEXT, 
      "etiqueta" TEXT,
      "mecanico" TEXT,
      "lugar" TEXT,
      "costo" INTEGER NOT NULL,
      "fecha" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      PRIMARY KEY("id_gasto_archivado" AUTOINCREMENT)
    );""");
  }

  Future<int> create({required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (vehiculo,etiqueta,mecanico,lugar,costo,fecha) VALUES (?,?,?,?,?,?)''',
      datos.values.toList()
    );
  }

  Future<List<GastoArchivado>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName ORDER BY fecha DESC'''
    );
    return registros.map((gastoArchivado) => GastoArchivado.fromSQfliteDatabase(gastoArchivado)).toList();
  }

  Future<List<GastoArchivado>> fetchByVehicule(String vehiculo) async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName 
      WHERE vehiculo = '$vehiculo'
      ORDER BY fecha DESC'''
    );
    return registros.map((gastoArchivado) => GastoArchivado.fromSQfliteDatabase(gastoArchivado)).toList();
  }

  //SELECT DISTINCT Country FROM Customers;
  Future<List<String>> fetchAllVehicles() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT DISTINCT vehiculo from $tableName'''
    );
    return registros.map((gastoArchivado) => gastoArchivado["vehiculo"] as String).toList();
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_gasto_archivado = ?''', [id]);
  }
}