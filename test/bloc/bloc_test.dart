import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
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
      expect: () =>  <VehiculoEstado>[MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: [])],
    );
    blocTest<VehiculoBloc, VehiculoEstado> (
      'Auto agregado es lista con 1 elemento',
      build: () => VehiculoBloc(),
      act: (bloc) async {
        //await testingMethod();
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: [])
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Eliminado unico vehiculo devuelve lista vacia.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EliminadoVehiculo(id: 1));
      },
      expect: () => <VehiculoEstado>[MisVehiculos(misVehiculos: Future.value([]), idsVehiculosSeleccionados: [])],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Editado vehiculo correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EditadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: [])
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future.value([]), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a editar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoEditarVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future.value([]), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969))
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Volver desde Agregar vehiculo devuelve a MisVehiculos.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(ClickeadoRegresarAMisvehiculos());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Seleccionar un vehiculo lo añade a la lista de seleccionados.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add((SeleccionadoVehiculo(idVehiculo: 1)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: [1]),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Deseleccionar un vehiculo lo remueve de la lista de seleccionados.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add((SeleccionadoVehiculo(idVehiculo: 1)));
        bloc.add((SeleccionadoVehiculo(idVehiculo: 1)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: [1]),
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
      ],
    );
  
  });

  group('Gastos: ', () {
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar gasto manda a Estado PlantillaGasto.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a consultar gastos manda a Estado ConsultaDeGastos.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(SeleccionadoVehiculo(idVehiculo: 1));
        bloc.add(ClickeadoConsultarGastos());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: [1]),
        MisGastos(misGastos: Gastos().fetchAllWithFilters(DateTime.now(), DateTime.now()), fechaFinal: DateTime.now(), fechaInicial: DateTime.now(), misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: 0, filtroIdVehiculo: 0, misVehiculos: Future(() => [])),
      ],
    );
     blocTest<VehiculoBloc, VehiculoEstado>(
      'Eliminado gasto funciona correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(SeleccionadoVehiculo(idVehiculo: 1));
        bloc.add(ClickeadoConsultarGastos());
        bloc.add(EliminadoGasto(id: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: [1]),
        MisGastos(misGastos: Future.value([const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: 0, filtroIdVehiculo: 0, misVehiculos: Future(() => [])),
        MisGastos(misGastos: Future.value([]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: 0, filtroIdVehiculo: 0, misVehiculos: Future(() => [])),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Gasto editado correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(SeleccionadoVehiculo(idVehiculo: 1));
        bloc.add(ClickeadoConsultarGastos());
        bloc.add(ClickeadoEditarGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(EditadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: []),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), idsVehiculosSeleccionados: [1]),
        MisGastos(misGastos: Future.value([const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: 0, filtroIdVehiculo: 0, misVehiculos: Future(() => [])),
        MisGastos(misGastos: Future.value([]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: 0, filtroIdVehiculo: 0, misVehiculos: Future(() => [])),
      ],
    );
  });
  
  group('Etiquetas: ', () {
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a administrar etiquetas manda a Estado AdministradorEtiquetas.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar etiqueta funciona correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a borrar etiqueta funciona correctamente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
        bloc.add(EliminadaEtiqueta(id: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a editar etiqueta genera la PlantillaEtiqueta con el nombre correspondiente.',
      build: () => VehiculoBloc(),
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'gasolina'));
        bloc.add(ClickeadoEditarEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'gasolina')));
        bloc.add(EditadoEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'Gasolina2')));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Vehiculos().fetchAll(), idsVehiculosSeleccionados: []),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
        PlantillaEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'Gasolina2')),
        MisEtiquetas(misEtiquetas: Etiquetas().fetchAll()),
      ],
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