import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:sqflite/sqflite.dart';

class Gastos {
  final tableName = 'gastos';

  Future<void> createTable(Database database) async {
    await database.execute("""PRAGMA foreign_keys = ON;""");
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
      "id_gasto" INTEGER NOT NULL,
      "vehiculo" INTEGER, 
      "etiqueta" INTEGER,
      "mecanico" TEXT,
      "lugar" TEXT,
      "costo" INTEGER NOT NULL,
      "fecha" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      PRIMARY KEY("id_gasto" AUTOINCREMENT),
      CONSTRAINT fk_etiqueta
        FOREIGN KEY (etiqueta)
        REFERENCES etiquetas(id_etiqueta)
        ON DELETE SET NULL,
      CONSTRAINT fk_vehiculo
        FOREIGN KEY (vehiculo)
        REFERENCES vehiculos(id_vehiculo)
        ON DELETE CASCADE
    );""");
  }
  //"etiqueta" INTEGER REFERENCES etiquetas(id_etiqueta) ON DELETE SET NULL,

  Future<int> create({required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (vehiculo,etiqueta,mecanico,lugar,costo,fecha) VALUES (?,?,?,?,?,?)''',
      datos.values.toList()
      //[datos["vehiculo"],datos["etiqueta"],datos["mecanico"],datos["lugar"],datos["costo"],datos["fecha"],],
      //[datos.values],
    );
  }

  Future<List<Gasto>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName ORDER BY id_gasto'''
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<List<Gasto>> fetchAllWhereVehiclesIds(List<int> idsVehiculosSeleccionados) async{
    final database = await DatabaseService().database;
    String values = "";
    for(var id in idsVehiculosSeleccionados) {
      values+= '$id${(id != idsVehiculosSeleccionados.last)?',':''}';
    }
    String query = ''' SELECT * from $tableName WHERE vehiculo IN ($values) ORDER BY fecha DESC''';
    final registros = await database.rawQuery(
      query
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<Gasto> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * from $tableName WHERE id_gasto = ?''', [id]);
    return Gasto.fromSQfliteDatabase(todo.first);
  }

  Future<int> update({required int id, required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName, 
      {
        if (datos["vehiculo"] != null) 'vehiculo': datos["vehiculo"],
        if (datos["etiqueta"] != null) 'etiqueta': datos["etiqueta"],
        if (datos["mecanico"] != null) 'mecanico': datos["mecanico"],
        if (datos["lugar"] != null) 'lugar': datos["lugar"],
        if (datos["costo"] != null) 'costo': datos["costo"],
        if (datos["fecha"] != null) 'fecha': datos["fecha"],
      },
      where: 'id_gasto = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_gasto = ?''', [id]);
  }
}