import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

class Etiquetas {
  final tableName = tablaEtiquetas;

  Future<void> createTable(Database database) async {
    await crearTabla(database);
    await database.rawInsert('''INSERT INTO $tableName(id_etiqueta,nombre) 
      SELECT $idSinEtiqueta, '$nombreSinEtiqueta' 
      WHERE NOT EXISTS(SELECT 1 FROM $tableName WHERE id_etiqueta = $idSinEtiqueta AND nombre = '$nombreSinEtiqueta');'''); // Inserta la Etiqueta 'Sin etiqueta' (se asigna por omisión en caso de eliminar su etiqueta)   
  }

  Future<void> crearTabla(Database database) async {
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
      ''' SELECT * from $tableName 
      WHERE id_etiqueta != $idSinEtiqueta 
      ORDER BY nombre'''
    );
    return registros.map((etiqueta) => Etiqueta.fromSQfliteDatabase(etiqueta)).toList();
  }

  Future<Etiqueta?> fetchById(int id) async {
    final database = await DatabaseService().database;
    final etiqueta = await database
        .rawQuery('''SELECT * from $tableName WHERE id_etiqueta = ?''', [id]);
    if (etiqueta.isEmpty) return null;
    return Etiqueta.fromSQfliteDatabase(etiqueta.first);
  }

  Future<Etiqueta?> fetchByName(String nombreEtiqueta) async {
    final database = await DatabaseService().database;
    final etiqueta = await database
        .rawQuery('''SELECT * from $tableName WHERE nombre = ?''', [nombreEtiqueta]);
    if (etiqueta.isEmpty) return null;
    return Etiqueta.fromSQfliteDatabase(etiqueta.first);
  }

  Future<List<String>> fetchAllTagsExcept(String etiqueta) async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT nombre from $tableName 
      WHERE nombre NOT IN ('$etiqueta') 
      ORDER BY id_etiqueta'''
    );
    return registros.map((etiqueta) => etiqueta["nombre"] as String).toList();
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
}