import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

class Vehiculos {
  final tableName = tablaVehiculos;

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
      "id_vehiculo" INTEGER NOT NULL,
      "matricula" TEXT NOT NULL,
      "marca" TEXT NOT NULL,
      "modelo" TEXT NOT NULL,
      "color" TEXT NOT NULL,
      "ano" INTEGER NOT NULL,
      PRIMARY KEY("id_vehiculo" AUTOINCREMENT)
    );""");
  }

  Future<int> create({required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (matricula,marca,modelo,color,ano) VALUES (?,?,?,?,?)''',
      //[datos["matricula"],datos["marca"],datos["modelo"],datos["color"],datos["ano"],],
      datos.values.toList(),
    );
  }

  Future<List<Vehiculo>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName ORDER BY id_vehiculo'''
    );
    return registros.map((vehiculo) => Vehiculo.fromSQfliteDatabase(vehiculo)).toList();
  }

  Future<Vehiculo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * from $tableName WHERE id_vehiculo = ?''', [id]);
    return Vehiculo.fromSQfliteDatabase(todo.first);
  }

  Future<List<String>> fetchAllPlatesExcept(String plate) async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT matricula from $tableName 
      WHERE matricula NOT IN ('$plate') 
      ORDER BY id_vehiculo'''
    );
    return registros.map((vehiculo) => vehiculo["matricula"] as String).toList();
  }

  Future<int> update({required int id, required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName, 
      {
        if (datos["matricula"] != null) 'matricula': datos["matricula"],
        if (datos["marca"] != null) 'marca': datos["marca"],
        if (datos["modelo"] != null) 'modelo': datos["modelo"],
        if (datos["color"] != null) 'color': datos["color"],
        if (datos["ano"] != null) 'ano': datos["ano"],
      },
      where: 'id_vehiculo = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_vehiculo = ?''', [id]);
  }

  Future<String> obtenerNombreVehiculoDeId(int id) async {
    Vehiculo vehiculo = await fetchById(id);
    return vehiculo.matricula;
  }
}