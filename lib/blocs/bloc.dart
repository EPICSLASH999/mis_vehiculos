// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/gastos_archivados.dart';

import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';

/* --------------------------------- ESTADOS --------------------------------- */
sealed class VehiculoEstado with EquatableMixin{}

class Inicial extends VehiculoEstado{
  @override
  List<Object?> get props => [];
}

// VEHICULOS
class MisVehiculos extends VehiculoEstado {
  final Future<List<Vehiculo>>? misVehiculos;
  final List<int> idsVehiculosSeleccionados;
  
  MisVehiculos({required this.misVehiculos, required this.idsVehiculosSeleccionados});

  @override
  List<Object?> get props => [misVehiculos, idsVehiculosSeleccionados];
}
class PlantillaVehiculo extends VehiculoEstado {
   final Vehiculo? vehiculo;

  PlantillaVehiculo({this.vehiculo});

  @override
  List<Object?> get props => [vehiculo];
}

// GASTOS
class PlantillaGasto extends VehiculoEstado {
  final int idVehiculo;
  final Future<List<Etiqueta>>? misEtiquetas;
  final Gasto? gasto;

  PlantillaGasto({required this.idVehiculo, required this.misEtiquetas, this.gasto});

  @override
  List<Object?> get props => [idVehiculo, misEtiquetas, gasto];
}
class MisGastos extends VehiculoEstado {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaInicial;
  final DateTime fechaFinal;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int filtroIdEtiqueta;

  MisGastos({
    required this.misGastos, 
    required this.fechaInicial, 
    required this.fechaFinal,
    required this.misEtiquetas,
    required this.filtroIdEtiqueta
  });

  @override
  List<Object?> get props => [misGastos, fechaInicial, fechaFinal, misEtiquetas, filtroIdEtiqueta];
}

// ETIQUETAS
class MisEtiquetas extends VehiculoEstado {
  final Future<List<Etiqueta>>? misEtiquetas;

  MisEtiquetas({required this.misEtiquetas});
  
  @override
  List<Object?> get props => [misEtiquetas];
}
class PlantillaEtiqueta extends VehiculoEstado {
  final Etiqueta? etiqueta;

  PlantillaEtiqueta({this.etiqueta});

  @override
  List<Object?> get props => [etiqueta];
}

// GASTOS ARCHIVADOS
class MisGastosArchivados extends VehiculoEstado {
  final Future <List<GastoArchivado>>? misGastosArchivados;
  final String vehiculoSeleccionado;
  final Future <List<String>>? misVehiculosArchivados;

  MisGastosArchivados({required this.misGastosArchivados, required this.vehiculoSeleccionado, required this.misVehiculosArchivados, });

  @override
  List<Object?> get props => [misGastosArchivados, vehiculoSeleccionado, misVehiculosArchivados];
}
/* --------------------------------------------------------------------------- */

/* --------------------------------- EVENTOS --------------------------------- */
sealed class VehiculoEvento {}

// VEHICULOS
class ClickeadoAgregarVehiculo extends VehiculoEvento {}
class EliminadoVehiculo extends VehiculoEvento {
  final int id;

  EliminadoVehiculo({required this.id});
}
class ClickeadoEditarVehiculo extends VehiculoEvento {
   final Vehiculo vehiculo;

  ClickeadoEditarVehiculo({required this.vehiculo});
}
class AgregadoVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  AgregadoVehiculo({required this.vehiculo});
}
class EditadoVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  EditadoVehiculo({required this.vehiculo});
}
class SeleccionadoVehiculo extends VehiculoEvento {
  final int idVehiculo;

  SeleccionadoVehiculo({required this.idVehiculo});
}

// ETIQUETAS
class ClickeadoAdministrarEtiquetas extends VehiculoEvento {}
class ClickeadoAgregarEtiqueta extends VehiculoEvento {}
class EliminadaEtiqueta extends VehiculoEvento {
  final int id;

  EliminadaEtiqueta({required this.id});
}
class ClickeadoEditarEtiqueta extends VehiculoEvento {
  final Etiqueta etiqueta;

  ClickeadoEditarEtiqueta({required this.etiqueta});
}
class EditadoEtiqueta extends VehiculoEvento {
  final Etiqueta etiqueta;

  EditadoEtiqueta({required this.etiqueta});
}
class AgregadoEtiqueta extends VehiculoEvento {
  final String nombreEtiqueta;

  AgregadoEtiqueta({required this.nombreEtiqueta});
}

// GASTOS
class ClickeadoAgregarGasto extends VehiculoEvento {
  final int idVehiculo;

  ClickeadoAgregarGasto({required this.idVehiculo});
}
class ClickeadoConsultarGastos extends VehiculoEvento {}
class AgregadoGasto extends VehiculoEvento {
  final Gasto gasto;

  AgregadoGasto({required this.gasto});
}
class FiltradoGastosPorFecha extends VehiculoEvento {
  final DateTime fechaInicial;
  final DateTime fechaFinal;

  FiltradoGastosPorFecha({required this.fechaInicial, required this.fechaFinal});
}
class ClickeadoEditarGasto extends VehiculoEvento {
  final Gasto gasto;

  ClickeadoEditarGasto({required this.gasto});
}
class EditadoGasto extends VehiculoEvento {
  final Gasto gasto;

  EditadoGasto({required this.gasto});
}
class EliminadoGasto extends VehiculoEvento {
  final int id;

  EliminadoGasto({required this.id});
}
class FiltradoGastosPorEtiqueta extends VehiculoEvento {
  final int idEtiqueta;

  FiltradoGastosPorEtiqueta({required this.idEtiqueta});
}


// GASTOS ARCHIVADOS
/*class ClickeadoConsultarGastosArchivados extends VehiculoEvento {}*/
class FiltradoGastoArchivadoPorVehiculo extends VehiculoEvento {
  final String matricula;

  FiltradoGastoArchivadoPorVehiculo({required this.matricula});
}
class EliminadosGastosArchivados extends VehiculoEvento {
  final String matricula;

  EliminadosGastosArchivados({required this.matricula});
}

// MISC
class Inicializado extends VehiculoEvento {}
class ClickeadoRegresarAMisvehiculos extends VehiculoEvento {}
class ClickeadoRegresarAAdministradorEtiquetas extends VehiculoEvento {}
/*class ClickeadoRegresarDesdeAdministradorEtiquetas extends VehiculoEvento {}*/
class ClickeadoregresarAConsultarGastos extends VehiculoEvento {}

// BOTTOM BAR
class CambiadoDePantalla extends VehiculoEvento {
  final Pantallas pantalla;

  CambiadoDePantalla({required this.pantalla});
}
/* --------------------------------------------------------------------------- */


/* ---------------------------- VARIABLES GLOBALES --------------------------- */

/* --------------------------------------------------------------------------- */

class VehiculoBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  // Vehiculos
  Future <List<Vehiculo>>? misVehiculos;
  final vehiculos = Vehiculos();
  List<int> idsVehiculosSeleccionados = [];

  // Etiquetas
  Future <List<Etiqueta>>? misEtiquetas;
  final etiquetas = Etiquetas();

  // Gastos
  Future <List<Gasto>>? misGastos;
  final gastos = Gastos();
  DateTime filtroFechaInicial = DateTime.now();
  DateTime filtroFechaFinal = DateTime.now();
  int filtroIdEtiqueta = valorEtiquetaTodas;

  // Gastos Archivados
  Future<List<GastoArchivado>>? misGastosArchivados;
  final gastosArchivados = GastosArchivados();
  String filtroVehiculo = valorEtiquetaTodas.toString();
  Future<List<String>>? misVehiculosArchivados;

  // Bottom Bar
  int indiceBottomBarSeleccionado = 0;

  void gestionarIdVehiculoSeleccionado(int idVehiculo) {
    if (idsVehiculosSeleccionados.contains(idVehiculo)){
      idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..remove(idVehiculo);
      return;
    }
    idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..add(idVehiculo);
  }
  void reiniciarFiltros() {
    filtroFechaFinal  = DateTime.now();
    filtroFechaInicial = DateTime(filtroFechaFinal.year);
    filtroIdEtiqueta = valorEtiquetaTodas;
  }
  Future<void> archivarGastosDeIdVehiculo(int id) async {
    List<Gasto> misGastosPorVehiculo = await Gastos().fetchByVehicleId(id);
    for (var gasto in misGastosPorVehiculo) {
      DateTime fechaNormalizada = DateTime.fromMillisecondsSinceEpoch(DateTime.parse(gasto.fecha).millisecondsSinceEpoch);
      Map<String,dynamic> datos = {
        "vehiculo": gasto.nombreVehiculo,
        "etiqueta": gasto.nombreEtiqueta,
        "mecanico": gasto.mecanico,
        "lugar": gasto.lugar,
        "costo": gasto.costo,
        "fecha": fechaNormalizada.millisecondsSinceEpoch.toString(),
      };
      await gastosArchivados.create(datos: datos);
    }
  }


  Future<List<GastoArchivado>> obtenerGastosArchivados(String matricula) {
    if(matricula == valorEtiquetaTodas.toString()) {
      return gastosArchivados.fetchAll();
    }
    return gastosArchivados.fetchByVehicule(filtroVehiculo);
  }
  Future<void> eliminarGastosArchivados(EliminadosGastosArchivados event) async {
    if(event.matricula == valorEtiquetaTodas.toString()) {
      await gastosArchivados.deleteAll();
      return;
    }
    await gastosArchivados.deleteWhereVehicle(event.matricula);
  }


  VehiculoBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      reiniciarFiltros();
      misVehiculos = vehiculos.fetchAll();
      misEtiquetas = etiquetas.fetchAll();
      emit(MisVehiculos(misVehiculos: misVehiculos, idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    
    // Vehiculos
    on<AgregadoVehiculo>((event, emit) async {
      Map<String,dynamic> datos = {
        "matricula": event.vehiculo.matricula,
        "marca": event.vehiculo.marca,
        "modelo": event.vehiculo.modelo,
        "color": event.vehiculo.color,
        "ano": event.vehiculo.ano,
      };
      await vehiculos.create(datos: datos);
      misVehiculos = vehiculos.fetchAll();
      idsVehiculosSeleccionados = [];
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<EliminadoVehiculo>((event, emit) async {
      await archivarGastosDeIdVehiculo(event.id);
      await vehiculos.delete(event.id);
      misVehiculos = vehiculos.fetchAll();
      idsVehiculosSeleccionados = [];
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<EditadoVehiculo>((event, emit) async {
      Map<String,dynamic> datos = {
        "matricula": event.vehiculo.matricula,
        "marca": event.vehiculo.marca,
        "modelo": event.vehiculo.modelo,
        "color": event.vehiculo.color,
        "ano": event.vehiculo.ano,
      };
      await vehiculos.update(id: event.vehiculo.id, datos: datos);
      misVehiculos = vehiculos.fetchAll();
      idsVehiculosSeleccionados = [];
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<ClickeadoAgregarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo());
    });
    on<ClickeadoEditarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo(vehiculo: event.vehiculo));
    });
    on<SeleccionadoVehiculo>((event, emit) {
      gestionarIdVehiculoSeleccionado(event.idVehiculo);
      emit(MisVehiculos(misVehiculos: misVehiculos, idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });

    // MISC
    on<ClickeadoRegresarAMisvehiculos>((event, emit) async {
      idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..clear();
      reiniciarFiltros();
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<ClickeadoRegresarAAdministradorEtiquetas>((event, emit) {
      emit(MisEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoregresarAConsultarGastos>((event, emit) {
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });

    // Gastos
    on<ClickeadoAgregarGasto>((event, emit) async {
      misEtiquetas = etiquetas.fetchAll();
      emit(PlantillaGasto(idVehiculo: event.idVehiculo, misEtiquetas: misEtiquetas));
    });
    on<AgregadoGasto>((event, emit) async {
       Map<String,dynamic> datos = {
        "vehiculo": event.gasto.vehiculo,
        "etiqueta": event.gasto.etiqueta,
        "mecanico": event.gasto.mecanico,
        "lugar": event.gasto.lugar,
        "costo": event.gasto.costo,
        "fecha": event.gasto.fecha,
      };
      await gastos.create(datos: datos);
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<ClickeadoConsultarGastos>((event, emit) async {    
      reiniciarFiltros();
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      misEtiquetas = etiquetas.fetchAll();
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });
    on<EliminadoGasto>((event, emit) async {
      await gastos.delete(event.id);
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });
    on<ClickeadoEditarGasto>((event, emit) {
      misEtiquetas = etiquetas.fetchAll();
      emit(PlantillaGasto(idVehiculo: 0, misEtiquetas: misEtiquetas, gasto: event.gasto));
    });
    on<EditadoGasto>((event, emit) async {
      Map<String,dynamic> datos = {
        "vehiculo": event.gasto.vehiculo,
        "etiqueta": event.gasto.etiqueta,
        "mecanico": event.gasto.mecanico,
        "lugar": event.gasto.lugar,
        "costo": event.gasto.costo,
        "fecha": event.gasto.fecha,
      };
      await gastos.update(id: event.gasto.id, datos: datos);
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });
    on<FiltradoGastosPorFecha>((event, emit) {
      filtroFechaInicial = event.fechaInicial;
      filtroFechaFinal = event.fechaFinal;
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });
    on<FiltradoGastosPorEtiqueta>((event, emit) {
      filtroIdEtiqueta = event.idEtiqueta;
      misGastos = gastos.fetchAllWithFilters(idsVehiculosSeleccionados, filtroFechaInicial, filtroFechaFinal);
      emit(MisGastos(misGastos: misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta));
    });

    // Etiquetas
    on<ClickeadoAdministrarEtiquetas>((event, emit) {
      misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoAgregarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta());
    });
    on<AgregadoEtiqueta>((event, emit) async {
      await etiquetas.create(nombre: event.nombreEtiqueta);
      misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<EliminadaEtiqueta>((event, emit) async {
      await etiquetas.delete(event.id);
      misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoEditarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta(etiqueta: event.etiqueta));
    });
    on<EditadoEtiqueta>((event, emit) async {
      await etiquetas.update(id: event.etiqueta.id, nombre: event.etiqueta.nombre);
      misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: misEtiquetas));
    });

    // Gastos Archivados
    /*on<ClickeadoConsultarGastosArchivados>((event, emit) {
      misGastosArchivados = gastosArchivados.fetchAll();
      emit(MisGastosArchivados(misGastosArchivados: misGastosArchivados));
    });*/
    on<FiltradoGastoArchivadoPorVehiculo>((event, emit) {
      filtroVehiculo = event.matricula;
      misGastosArchivados = obtenerGastosArchivados(event.matricula);

      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();
      emit(MisGastosArchivados(misGastosArchivados: misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });
    on<EliminadosGastosArchivados>((event, emit) async {
      await eliminarGastosArchivados(event);
      misGastosArchivados = gastosArchivados.fetchAll();
      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();
      filtroVehiculo = valorEtiquetaTodas.toString();
      emit(MisGastosArchivados(misGastosArchivados: misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });

    // Bottom Bar
    on<CambiadoDePantalla>((event, emit) {
      //indiceBottomBarSeleccionado = event.indicePantalla;
      misVehiculos = vehiculos.fetchAll();
      misEtiquetas = etiquetas.fetchAll();
      misGastosArchivados = gastosArchivados.fetchAll();
      filtroVehiculo = valorEtiquetaTodas.toString();
      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();

      if(event.pantalla == Pantallas.misVehiculos){
        emit(MisVehiculos(misVehiculos: misVehiculos, idsVehiculosSeleccionados: idsVehiculosSeleccionados));
        return;
      }
      if(event.pantalla == Pantallas.misEtiquetas){
        emit(MisEtiquetas(misEtiquetas: misEtiquetas));
        return;
      }
      emit(MisGastosArchivados(misGastosArchivados: misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });

  }

  
}





