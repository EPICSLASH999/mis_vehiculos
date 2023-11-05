import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mis_vehiculos/bloc/bloc.dart';
import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/*void main() {
  blocTest<VehiculoBloc, VehiculoEstado>(
    'Estado es MisVehiculos despues de inicializado.',
    build: () => VehiculoBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () =>  <VehiculoEstado>[MisVehiculos(misVehiculos: [])],
  );
  blocTest<VehiculoBloc, VehiculoEstado>(
    'Ningun vehiculo cuando inicializado.',
    build: () => VehiculoBloc(),
    act: (bloc) => bloc.add(Inicializado()),
    expect: () =>  <VehiculoEstado>[MisVehiculos(misVehiculos: [])],
  );
  group('SQL Lite', () {
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Probar SQL Lite.',
      build: () => VehiculoBloc(),
      act: (bloc) => bloc.add(Inicializado()),
      expect: () =>  <VehiculoEstado>[MisVehiculos(misVehiculos: [])],
    );
  });
  
}*/

Future main() async {
  //late Future<Database> database;
  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing calls for SQFlite
    databaseFactory = databaseFactoryFfi;
    //database = DatabaseService().database;
  });
  
  tearDownAll (() async {
    // Maybe delete the database here
    //databaseFactory.deleteDatabase(await DatabaseService().fullPath);
  });

  group('SQL Lite: ', () {
    test('sqflite version es 1', () async {
      Database database2 = await DatabaseService().database;
      expect(await database2.getVersion(), 1);
    });
  });

  group('Vehiculos: ', () {
    blocTest<VehiculoBloc, VehiculoEstado> (
      'base de datos inizializada en lista vacia = [].',
      build: () => VehiculoBloc(),
      act: (bloc) async {
        //await testingMethod();
        bloc.add(Inicializado());
      },
      expect: () =>  <VehiculoEstado>[MisVehiculos(misVehiculos: Vehiculos().fetchAll())],
    );
    blocTest<VehiculoBloc, VehiculoEstado> (
      'Auto agregado es lista con 1 elemento',
      build: () => VehiculoBloc(),
      act: (bloc) async {
        //await testingMethod();
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]))],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Eliminado unico vehiculo devuelve lista vacia.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EliminadoVehiculo(id: 1));
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Future.value([]))],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Editado vehiculo correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EditadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]))],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Vehiculos().fetchAll()),PlantillaVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969))],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a editar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoEditarVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Vehiculos().fetchAll()),PlantillaVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969))],
    );
  });
  
}

Future<void> testingMethod() async {
  if (Platform.environment.containsKey('FLUTTER_TEST')){
    // This if-staement can be quite handy !
    // Maybe put something in here
  }
  await DatabaseService().database;
}