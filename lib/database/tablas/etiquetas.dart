import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

class Etiquetas {
  final tableName = tablaEtiquetas;

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
      "id_etiqueta" INTEGER NOT NULL,
      "nombre" TEXT NOT NULL, 
      PRIMARY KEY("id_etiqueta" AUTOINCREMENT)
    );""");
  }

  Future<int> create({required String nombre}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (nombre) VALUES (?)''',
      [nombre],
    );
  }

  Future<List<Etiqueta>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName ORDER BY id_etiqueta'''
    );
    return registros.map((etiqueta) => Etiqueta.fromSQfliteDatabase(etiqueta)).toList();
  }

  Future<Etiqueta> fetchById(int id) async {
    final database = await DatabaseService().database;
    final etiqueta = await database
        .rawQuery('''SELECT * from $tableName WHERE id_etiqueta = ?''', [id]);
    return Etiqueta.fromSQfliteDatabase(etiqueta.first);
  }

  Future<int> update({required int id, required String? nombre}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName, 
      {
        if (nombre != null) 'nombre': nombre,
      },
      where: 'id_etiqueta = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_etiqueta = ?''', [id]);
  }

  Future<String> obtenerNombreEtiquetaDeId(int id) async {
    Etiqueta etiqueta = await fetchById(id);
    return etiqueta.nombre;
  }
}