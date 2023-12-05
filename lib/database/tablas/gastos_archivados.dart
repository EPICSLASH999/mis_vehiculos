import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
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
      "id_vehiculo" INTEGER NOT NULL,
      "id_etiqueta" INTEGER NOT NULL,
      "marca_vehiculo" TEXT NOT NULL,
      "modelo_vehiculo" TEXT NOT NULL,
      "color_vehiculo" TEXT NOT NULL,
      "ano_vehiculo" INTEGER NOT NULL,
      PRIMARY KEY("id_gasto_archivado" AUTOINCREMENT)
    );""");
  }

  Future<int> create({required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (vehiculo,etiqueta,mecanico,lugar,costo,fecha,id_vehiculo,id_etiqueta,marca_vehiculo,modelo_vehiculo,color_vehiculo,ano_vehiculo) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)''',
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

  Future<List<GastoArchivado>> fetchByFilters(DateTime fechaInicial, DateTime fechaFinal, int? vehiculo) async{
    final database = await DatabaseService().database;
    String filtroVehiculo = (vehiculo == null)?'':'AND id_vehiculo = $vehiculo ';
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName 
      WHERE fecha BETWEEN ${fechaInicial.millisecondsSinceEpoch} AND ${fechaFinal.millisecondsSinceEpoch} 
      $filtroVehiculo
      ORDER BY fecha DESC'''
    );
    return registros.map((gastoArchivado) => GastoArchivado.fromSQfliteDatabase(gastoArchivado)).toList();
  }

  Future<List<GastoArchivado>> fetchAllWhereVehicleID(int idVehiculo) async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName 
        WHERE id_vehiculo = $idVehiculo 
        ORDER BY fecha DESC'''
    );
    return registros.map((gastoArchivado) => GastoArchivado.fromSQfliteDatabase(gastoArchivado)).toList();
  }

  Future<List<String>> fetchAllVehiclesPlates() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT DISTINCT vehiculo from $tableName'''
    );
    return registros.map((gastoArchivado) => gastoArchivado["vehiculo"] as String).toList();
  }
  Future<List<Vehiculo>> fetchAllArchivedVehicles() async{
    //id_vehiculo,vehiculo,marca_vehiculo,modelo_vehiculo,color_vehiculo,ano_vehiculo
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT DISTINCT id_vehiculo,
                vehiculo as matricula,
                marca_vehiculo as marca,
                modelo_vehiculo as modelo,
                color_vehiculo as color,
                ano_vehiculo as ano 
        from $tableName'''
    );
    return registros.map((vehiculo) => Vehiculo.fromSQfliteDatabase(vehiculo)).toList();
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_gasto_archivado = ?''', [id]);
  }

  Future<void> deleteWhereVehiclePlate(String matricula) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE vehiculo = ?''', [matricula]);
  }

  Future<void> deleteWhereVehicleId(int idVehiculo) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_vehiculo = ?''', [idVehiculo]);
  }

  Future<void> deleteByFilters(DateTime fechaInicial, DateTime fechaFinal, int? idVehiculo) async {
    final database = await DatabaseService().database;
    String filtroVehiculo = (idVehiculo == null)?'':'AND id_vehiculo = $idVehiculo ';
    await database.rawDelete('''DELETE FROM $tableName 
      WHERE fecha BETWEEN ${fechaInicial.millisecondsSinceEpoch} AND ${fechaFinal.millisecondsSinceEpoch} 
      $filtroVehiculo''');
  }

  Future<void> deleteAll() async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName''');
  }
  

  Future<int> updateAllWhereVehicleId({required int idVehiculoVieja, required int idVehiculoNueva}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName, 
      {
        'id_vehiculo': idVehiculoNueva,
      },
      where: 'id_vehiculo = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [idVehiculoVieja],
    );
  }
}