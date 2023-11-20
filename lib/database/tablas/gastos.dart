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
      "etiqueta" INTEGER DEFAULT $idSinEtiqueta,
      "mecanico" TEXT,
      "lugar" TEXT,
      "costo" INTEGER NOT NULL,
      "fecha" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      PRIMARY KEY("id_gasto" AUTOINCREMENT),
      CONSTRAINT fk_etiqueta
        FOREIGN KEY (etiqueta)
        REFERENCES $tablaEtiquetas(id_etiqueta)
        ON DELETE SET DEFAULT,
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
      ''' SELECT * from $tableName ORDER BY id_gasto'''
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<List<Gasto>> fetchAllWithFilters(DateTime fechaInicial, DateTime fechaFinal, int? idVehiculo) async{
    final database = await DatabaseService().database;
    String filtroVehiculo = (idVehiculo == null)?'':'AND vehiculo = $idVehiculo ';
    //String query = ''' SELECT * from $tableName WHERE vehiculo IN ($values) ORDER BY fecha DESC''';
    String query = ''' SELECT id_gasto,vehiculo,etiqueta,mecanico,lugar,costo,fecha,matricula, nombre from $tableName 
      INNER JOIN $tablaVehiculos ON $tablaVehiculos.id_vehiculo = $tableName.vehiculo 
      INNER JOIN $tablaEtiquetas ON $tablaEtiquetas.id_etiqueta = $tableName.etiqueta 
      WHERE fecha BETWEEN ${fechaInicial.millisecondsSinceEpoch} AND ${fechaFinal.millisecondsSinceEpoch} 
      $filtroVehiculo
      ORDER BY fecha DESC''';
    final registros = await database.rawQuery(
      query
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<List<Gasto>> fetchByVehicleId(int idVehiculo) async{
    final database = await DatabaseService().database;
    String query = ''' SELECT mecanico,lugar,costo,fecha,matricula,nombre from $tableName 
      INNER JOIN $tablaVehiculos ON $tablaVehiculos.id_vehiculo = $tableName.vehiculo 
      INNER JOIN $tablaEtiquetas ON $tablaEtiquetas.id_etiqueta = $tableName.etiqueta 
      WHERE vehiculo = $idVehiculo
      ORDER BY fecha DESC''';
    final registros = await database.rawQuery(
      query
    );
    return registros.map((gasto) => Gasto.fromSQfliteDatabase(gasto)).toList();
  }

  Future<List<Map<String, Object?>>> fetchMostOccurringMechanics(int idVehiculo) async{
    final database = await DatabaseService().database;
    String query = ''' WITH CTE AS (
        SELECT
          etiqueta, 
          mecanico,
          ROW_NUMBER() OVER (PARTITION BY etiqueta ORDER BY COUNT(*) DESC) AS rn
        FROM $tableName
        WHERE vehiculo = $idVehiculo 
        AND etiqueta != $idSinEtiqueta
        AND (
            mecanico <> '' 
            OR NOT EXISTS (
              SELECT 1
              FROM $tableName c2
              WHERE vehiculo = $idVehiculo 
              AND c2.etiqueta = $tableName.etiqueta AND c2.mecanico <> ''
            )
      )
        GROUP BY etiqueta, mecanico
      )
      SELECT etiqueta, mecanico
      FROM CTE
      WHERE rn = 1
      ORDER BY (SELECT COUNT(*) FROM $tableName WHERE etiqueta = CTE.etiqueta and vehiculo = $idVehiculo) DESC; -- Ordenar por la cuenta de etiquetas de forma descendente ''';
   
    final registros = await database.rawQuery(
      query
    );
    return registros;
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
    if(datos["etiqueta"] == idSinEtiqueta) datos["etiqueta"] = null; 

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