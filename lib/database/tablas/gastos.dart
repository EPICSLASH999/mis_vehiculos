import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

class Gastos {
  final tableName = tablaGastos;

  Future<void> createTable(Database database) async {
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
        REFERENCES $tablaEtiquetas(id_etiqueta)
        ON DELETE SET NULL,
      CONSTRAINT fk_vehiculo
        FOREIGN KEY (vehiculo)
        REFERENCES $tablaVehiculos(id_vehiculo)
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
    );
  }

  Future<List<Gasto>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName 
      ORDER BY id_gasto'''
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<List<Gasto>> fetchAllWhereVehiclesIds(List<int> idsVehiculosSeleccionados, DateTime fechaInicial, DateTime fechaFinal) async{
    final database = await DatabaseService().database;
    String values = "";
    for(var id in idsVehiculosSeleccionados) {values+= '$id${(id != idsVehiculosSeleccionados.last)?',':''}';} // Crea lista similar a esta: 1,2,3
    //String query = ''' SELECT * from $tableName WHERE vehiculo IN ($values) ORDER BY fecha DESC''';
    String query = ''' SELECT id_gasto,vehiculo,etiqueta,mecanico,lugar,costo,fecha,matricula from $tableName 
      INNER JOIN vehiculos ON $tablaVehiculos.id_vehiculo = $tableName.vehiculo 
      WHERE vehiculo IN ($values) 
      AND fecha BETWEEN ${fechaInicial.millisecondsSinceEpoch} AND ${fechaFinal.millisecondsSinceEpoch} 
      ORDER BY fecha DESC''';
    final registros = await database.rawQuery(
      query
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<Gasto> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * from $tableName 
          WHERE id_gasto = ?''', [id]);
    return Gasto.fromSQfliteDatabase(todo.first);
  }

  Future<int> update({required int id, required Map<String,dynamic> datos}) async {
    // En caso de que la etiqueta se haya eliminado del registro de gasto, y se desea actualizar dejando la etiqueta con valor nulo...
    // Normalizar el valor de la etiqueta a NULL para que no trate de actualizarlo y ocasione algun error
    if(datos["etiqueta"] == valorEtiquetaNula) datos["etiqueta"] = null; 

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