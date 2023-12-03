import 'package:equatable/equatable.dart';
import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite/sqflite.dart';

abstract class RepositorioVehiculos{
  Future<int> create({required Map<String,dynamic> datos});
  Future<List<Vehiculo>> fetchAll();
  Future<Vehiculo?> fetchById(int id);
  Future<List<String>> fetchAllPlatesExcept(String plate);
  Future<int> update({required int id, required Map<String,dynamic> datos});
  Future<void> delete(int id);
  Future<String> obtenerNombreVehiculoDeId(int id);
}

// ignore: must_be_immutable
class VehiculosFalso extends Equatable implements RepositorioVehiculos {
  List<Vehiculo> listaVehiculos = [];

  @override
  Future<void> delete(int id) async {
    listaVehiculos = listaVehiculos.copiar()..removeWhere((element) => element.id == id,);
  }

  @override
  Future<List<Vehiculo>> fetchAll() async{
    return Future(() => listaVehiculos.copiar());
  }

  @override
  Future<List<String>> fetchAllPlatesExcept(String plate) {
    List<String> listaMatriculasVehiculos = [];
    for (var vehiculo in listaVehiculos) {
      listaMatriculasVehiculos = listaMatriculasVehiculos.copiar()..add(vehiculo.matricula);
    }
    return Future(() => listaMatriculasVehiculos);
  }

  @override
  Future<Vehiculo?> fetchById(int id) {
    late Vehiculo vehiculoPorID;
    for (var vehiculo in listaVehiculos) {
      if (vehiculo.id == id) vehiculoPorID = vehiculo;
      break;
    }
    return Future(() => vehiculoPorID);
  }

  @override
  Future<String> obtenerNombreVehiculoDeId(int id) {
    String nombreVehiculo = "";
    for (var vehiculo in listaVehiculos) {
      if (vehiculo.id == id) nombreVehiculo = vehiculo.modelo;
      break;
    }
    return Future(() => nombreVehiculo);
  }

  @override
  Future<int> update({required int id, required Map<String, dynamic> datos}) {
    Vehiculo vehiculoActualizado = Vehiculo(id: id, matricula: datos["matricula"], marca: datos["marca"], modelo: datos["modelo"], color: datos["color"], ano: datos["ano"]);
    for (var vehiculo in listaVehiculos) {
      if (vehiculo.id == id) listaVehiculos.replaceRange(listaVehiculos.indexOf(vehiculo), listaVehiculos.indexOf(vehiculo)+1, [vehiculoActualizado]);
      break;
    }
    return Future(() => 5);
  }
  
  @override
  Future<int> create({required Map<String, dynamic> datos}) async {
    Vehiculo nuevoVehiculo = Vehiculo(id: 0, matricula: datos["matricula"], marca: datos["marca"], modelo: datos["modelo"], color: datos["color"], ano: datos["ano"]);
    listaVehiculos = listaVehiculos.copiar()..add(nuevoVehiculo);
    return Future(() => 1);
  }
  
  @override
  List<Object?> get props => [listaVehiculos];

}

class Vehiculos implements RepositorioVehiculos{
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

  @override
  Future<int> create({required Map<String,dynamic> datos}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (matricula,marca,modelo,color,ano) VALUES (?,?,?,?,?)''',
      //[datos["matricula"],datos["marca"],datos["modelo"],datos["color"],datos["ano"],],
      datos.values.toList(),
    );
  }

  @override
  Future<List<Vehiculo>> fetchAll() async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT * from $tableName ORDER BY id_vehiculo DESC'''
    );
    return registros.map((vehiculo) => Vehiculo.fromSQfliteDatabase(vehiculo)).toList();
  }

  Future<List<Vehiculo>> fetchAllFavoritesAndFrequent() async{
    final database = await DatabaseService().database;
    String queryUnion = '''
      WITH Favoritos AS (
        SELECT
            id_vehiculo,
            MAX($tablaGastos.id_gasto) AS ultima_aparicion,
            matricula,
            marca,
            modelo,
            color,
            ano,
            COUNT(id_vehiculo) AS `frecuencia`,
            ROW_NUMBER() OVER (PARTITION BY id_vehiculo ORDER BY COUNT(id_vehiculo) DESC) AS rn,
            1 as filter
        FROM
            $tableName
        INNER JOIN
            $tablaGastos ON $tablaGastos.vehiculo = $tableName.id_vehiculo
        GROUP BY
            id_vehiculo
        ORDER BY
            `frecuencia` DESC
        LIMIT
            $numeroVehiculosFavoritos
    )
    SELECT *
    FROM Favoritos

    UNION ALL

    SELECT * FROM (
        SELECT
            id_vehiculo,
            MAX($tablaGastos.id_gasto) AS ultima_aparicion,
            matricula,
            marca,
            modelo,
            color,
            ano,
            COUNT(id_vehiculo) AS frecuencia,
            ROW_NUMBER() OVER (PARTITION BY id_vehiculo ORDER BY MAX($tablaGastos.id_gasto) DESC) AS rn,
            2 as filter
        FROM
            $tableName
        LEFT JOIN
            $tablaGastos ON $tablaGastos.vehiculo = $tableName.id_vehiculo
        WHERE
          id_vehiculo NOT IN (
            SELECT
                id_vehiculo
            FROM
                Favoritos
            LIMIT
                $numeroVehiculosFavoritos
          )
        GROUP BY
            id_vehiculo, matricula, marca, modelo, color, ano
        ORDER BY
            ultima_aparicion DESC, frecuencia DESC
    ) AS AllResults
    WHERE rn = 1
    ORDER BY
      filter;

    ''';

    final registros = await database.rawQuery(queryUnion);

    return registros.map((vehiculo) => Vehiculo.fromSQfliteDatabase(vehiculo)).toList();
  }

  @override
  Future<Vehiculo?> fetchById(int id) async {
    final database = await DatabaseService().database;
    final vehiculo = await database
        .rawQuery('''SELECT * from $tableName WHERE id_vehiculo = ?''', [id]);
    if (vehiculo.isEmpty) return null;
    return Vehiculo.fromSQfliteDatabase(vehiculo.first);
  }

  @override
  Future<List<String>> fetchAllPlatesExcept(String plate) async{
    final database = await DatabaseService().database;
    final registros = await database.rawQuery(
      ''' SELECT matricula from $tableName 
      WHERE matricula NOT IN ('$plate') 
      ORDER BY id_vehiculo'''
    );
    return registros.map((vehiculo) => vehiculo["matricula"] as String).toList();
  }

  @override
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

  @override
  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id_vehiculo = ?''', [id]);
  }

  @override
  Future<String> obtenerNombreVehiculoDeId(int id) async {
    Vehiculo? vehiculo = await fetchById(id);
    return vehiculo!.matricula;
  }
}