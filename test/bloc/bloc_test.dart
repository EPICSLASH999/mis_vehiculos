import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/database_service.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

 main()  {
  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    sqfliteFfiInit(); // Initialize FFI for web or computer
    databaseFactory = databaseFactoryFfi; // Change the default factory for unit testing calls for SQFlite
  });
  
  tearDownAll (() async {
    // Maybe delete the database here
    //databaseFactory.deleteDatabase(await DatabaseService().fullPath);
  });

  group('SQL Lite: ', () {
    test('Sqflite version es 2', () async {
      Database database2 = await DatabaseService().database;
      expect(await database2.getVersion(), 2);
    });
  });

  group('Vehiculos: ', () {
    blocTest<VehiculoBloc, VehiculoEstado> (
      'base de datos inizializada en lista vacia = [].',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
      },
      expect: () async =>  <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false)
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado> (
      'Auto agregado es lista con 1 elemento',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: ()  async => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false)
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Eliminado unico vehiculo devuelve lista vacia.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EliminadoVehiculo(id: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future.value([]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future(() => [const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Editado vehiculo correctamente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(EditadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future(() => [const Vehiculo(id: 1, matricula: 'xxx-2', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      skip: 1,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
      },
      expect: () => <VehiculoEstado>[
        //MisVehiculos(misVehiculos: Future.value([]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a editar vehiculo manda a Estado PlantillaVehiculo.',
      build: () => VehiculoBloc(),
      skip: 1,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoEditarVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
      },
      expect: () => <VehiculoEstado>[
        //MisVehiculos(misVehiculos: Future.value([]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969))
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Volver desde Agregar vehiculo devuelve a MisVehiculos.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(ClickeadoRegresarAMisvehiculos());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
      ],
    );
  });

  group('Etiquetas: ', () {
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a administrar etiquetas manda a Estado AdministradorEtiquetas.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar etiqueta funciona correctamente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina')]), estaModoSeleccionActivo: false),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a borrar etiqueta funciona correctamente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
        bloc.add(EliminadaEtiqueta(id: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina')]), estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a editar etiqueta genera la PlantillaEtiqueta con el nombre correspondiente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'gasolina'));
        bloc.add(ClickeadoEditarEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'gasolina')));
        bloc.add(EditadoEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'Gasolina2')));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'gasolina')]), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(etiqueta: const Etiqueta(id: 1, nombre: 'gasolina')),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina2')]), estaModoSeleccionActivo: false),
      ],
    );
    
  });

  group('Gastos: ', () {
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a agregar gasto manda a Estado PlantillaGasto.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Future(() => [])),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Click a consultar gastos manda a Estado ConsultaDeGastos.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
        bloc.add(ClickeadoRegresarAMisvehiculos());
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(ClickeadoConsultarGastos());
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina')]), estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),        
        MisGastos(misGastos: Gastos().fetchAllWithFilters(DateTime.now(), DateTime.now(), 1), fechaFinal: DateTime.now(), fechaInicial: DateTime.now(), misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: valorOpcionTodas, filtroIdVehiculo: valorOpcionTodas, misVehiculos: vehiculos.fetchAll(), filtroMecanico: "", representacionGasto: RepresentacionGastos.lista, tipoReporte: TipoReporte.year),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Eliminado gasto funciona correctamente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
        bloc.add(ClickeadoRegresarAMisvehiculos());
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(ClickeadoConsultarGastos());
        bloc.add(EliminadoGasto(id: 1));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina')]), estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),        
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),        
        MisGastos(misGastos: Future.value([const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: valorOpcionTodas, filtroIdVehiculo: valorOpcionTodas, misVehiculos: vehiculos.fetchAll(), filtroMecanico: "", representacionGasto: RepresentacionGastos.lista, tipoReporte: TipoReporte.year),
        MisGastos(misGastos: Future.value([]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: valorOpcionTodas, filtroIdVehiculo: valorOpcionTodas, misVehiculos: vehiculos.fetchAll(), filtroMecanico: "", representacionGasto: RepresentacionGastos.lista, tipoReporte: TipoReporte.year),
      ],
    );
    blocTest<VehiculoBloc, VehiculoEstado>(
      'Gasto editado correctamente.',
      build: () => VehiculoBloc(),
      skip: 0,
      act: (bloc) {
        bloc.add(Inicializado());
        bloc.add(ClickeadoAgregarVehiculo());
        bloc.add(AgregadoVehiculo(vehiculo: const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)));
        bloc.add(ClickeadoAdministrarEtiquetas());
        bloc.add(ClickeadoAgregarEtiqueta());
        bloc.add(AgregadoEtiqueta(nombreEtiqueta: 'Gasolina'));
        bloc.add(ClickeadoRegresarAMisvehiculos());
        bloc.add(ClickeadoAgregarGasto(idVehiculo: 1));
        bloc.add(AgregadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(ClickeadoConsultarGastos());
        bloc.add(ClickeadoEditarGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
        bloc.add(EditadoGasto(gasto: const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico 2', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')));
      },
      expect: () => <VehiculoEstado>[
        MisVehiculos(misVehiculos: Future(() => []), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        PlantillaVehiculo(),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false),
        MisEtiquetas(misEtiquetas: Future(() => []), estaModoSeleccionActivo: false),
        PlantillaEtiqueta(),
        MisEtiquetas(misEtiquetas: Future(() => [const Etiqueta(id: 1, nombre: 'Gasolina')]), estaModoSeleccionActivo: false),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false), 
        PlantillaGasto(idVehiculo: 1, misEtiquetas: Etiquetas().fetchAll()),
        MisVehiculos(misVehiculos: Future.value([const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969)]), buscarVehiculosQueContengan: "", estaModoSeleccionActivo: false), 
        MisGastos(misGastos: Future.value([const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: valorOpcionTodas, filtroIdVehiculo: valorOpcionTodas, misVehiculos: vehiculos.fetchAll(), filtroMecanico: "", representacionGasto: RepresentacionGastos.lista, tipoReporte: TipoReporte.year),
        PlantillaGasto(idVehiculo: 1, misEtiquetas: etiquetas.fetchAll()),
        MisGastos(misGastos: Future.value([const Gasto(id: 1, vehiculo: 1, etiqueta: 1, mecanico: 'mecanico 2', lugar: 'lugar', costo: 200.19, fecha: '26 Nov, 2023')]), fechaInicial: DateTime.now(), fechaFinal: DateTime.now(),misEtiquetas: Etiquetas().fetchAll(), filtroIdEtiqueta: valorOpcionTodas, filtroIdVehiculo: valorOpcionTodas, misVehiculos: vehiculos.fetchAll(), filtroMecanico: "", representacionGasto: RepresentacionGastos.lista, tipoReporte: TipoReporte.year),
      ],
    );
  });
  
}

