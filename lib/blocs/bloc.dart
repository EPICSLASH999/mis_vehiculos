// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/gastos_archivados.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
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
  final Future <List<Etiqueta>>? misEtiquetas;

  MisVehiculos({required this.misVehiculos, required this.misEtiquetas});

  @override
  List<Object?> get props => [misVehiculos];
}
class PlantillaVehiculo extends VehiculoEstado {
   final Vehiculo? vehiculo;
   final Future <List<String>>? matriculasVehiculos;

  PlantillaVehiculo({this.vehiculo, this.matriculasVehiculos,});

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
  final int filtroIdVehiculo;
  final Future <List<Vehiculo>>? misVehiculos;

  MisGastos({
    required this.misGastos, 
    required this.fechaInicial, 
    required this.fechaFinal,
    required this.misEtiquetas,
    required this.filtroIdEtiqueta,
    required this.filtroIdVehiculo, 
    required this.misVehiculos,
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
class FiltradoGastosPorVehiculo extends VehiculoEvento {
  final int idVehiculo;

  FiltradoGastosPorVehiculo({required this.idVehiculo});
}

// GASTOS ARCHIVADOS
class ClickeadoConsultarGastosArchivados extends VehiculoEvento {}
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
class ClickeadoregresarAConsultarGastos extends VehiculoEvento {}

// BOTTOM BAR
class CambiadoDePantalla extends VehiculoEvento {
  final OpcionesBottomBar pantalla;

  CambiadoDePantalla({required this.pantalla});
}
/* --------------------------------------------------------------------------- */


/* ---------------------------- VARIABLES GLOBALES --------------------------- */
// Vehiculos
Future <List<Vehiculo>>? _misVehiculos;
final vehiculos = Vehiculos();

// Etiquetas
Future <List<Etiqueta>>? _misEtiquetas;
final etiquetas = Etiquetas();

// Gastos
Future <List<Gasto>>? _misGastos;
final gastos = Gastos();

// Gastos Archivados
Future<List<GastoArchivado>>? _misGastosArchivados;
final gastosArchivados = GastosArchivados();
/* --------------------------------------------------------------------------- */

class VehiculoBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  // Vehiculos
  Future<List<String>>? matriculasVehiculos;

  // Gastos
  DateTime filtroFechaInicial = DateTime.now();
  DateTime filtroFechaFinal = DateTime.now();
  int filtroIdEtiqueta = valorOpcionTodas;
  int filtroIdVehiculo = valorOpcionTodas;

  // Gastos Archivados
  String filtroVehiculo = valorOpcionTodas.toString();
  Future<List<String>>? misVehiculosArchivados;

  // MÉTODOS
  //Métodos para gastos.
  String normalizarNumeroA2DigitosFecha(int numero){
    String numeroRecibido = '';
    if (numero.toString().length == 1) numeroRecibido += '0';
    return numeroRecibido += numero.toString();
  }
  void reiniciarFiltrosGastos() {
    filtroFechaFinal  = DateTime.now();
    filtroFechaInicial = DateTime.parse('${filtroFechaFinal.year}-${normalizarNumeroA2DigitosFecha(filtroFechaFinal.month)}-01');
    filtroIdEtiqueta = valorOpcionTodas;
    filtroIdVehiculo = valorOpcionTodas;
  }
  Future<List<Gasto>> obtenerGastos(){
    int? idVehiculo = (filtroIdVehiculo == valorOpcionTodas)?null:filtroIdVehiculo;
    return gastos.fetchAllWithFilters(filtroFechaInicial, filtroFechaFinal, idVehiculo);
  }

  // Métodos para gastos archivados.
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
    if(matricula == valorOpcionTodas.toString()) {
      return gastosArchivados.fetchAll();
    }
    return gastosArchivados.fetchByVehicule(filtroVehiculo);
  }
  Future<void> eliminarGastosArchivados(EliminadosGastosArchivados event) async {
    if(event.matricula == valorOpcionTodas.toString()) {
      await gastosArchivados.deleteAll();
      return;
    }
    await gastosArchivados.deleteWhereVehicle(event.matricula);
  }

  
  VehiculoBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      reiniciarFiltrosGastos();
      _misVehiculos = vehiculos.fetchAll();
      _misEtiquetas = etiquetas.fetchAll();
      _misGastos = obtenerGastos();
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
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
      _misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
    });
    on<EliminadoVehiculo>((event, emit) async {
      await archivarGastosDeIdVehiculo(event.id);
      await vehiculos.delete(event.id);
      _misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
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
      _misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoAgregarVehiculo>((event, emit) async {
      matriculasVehiculos = vehiculos.fetchAllPlatesExcept('0');
      emit(PlantillaVehiculo(matriculasVehiculos: matriculasVehiculos));
    });
    on<ClickeadoEditarVehiculo>((event, emit) async {
      matriculasVehiculos = vehiculos.fetchAllPlatesExcept(event.vehiculo.matricula);
      emit(PlantillaVehiculo(vehiculo: event.vehiculo, matriculasVehiculos: matriculasVehiculos));
    });
   
    // Gastos
    on<ClickeadoAgregarGasto>((event, emit) async {
      _misEtiquetas = etiquetas.fetchAll();
      emit(PlantillaGasto(idVehiculo: event.idVehiculo, misEtiquetas: _misEtiquetas));
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
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoConsultarGastos>((event, emit) async {    
      reiniciarFiltrosGastos();
      _misGastos = obtenerGastos();
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });
    on<EliminadoGasto>((event, emit) async {
      await gastos.delete(event.id);
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });
    on<ClickeadoEditarGasto>((event, emit) {
      _misEtiquetas = etiquetas.fetchAll();
      emit(PlantillaGasto(idVehiculo: 0, misEtiquetas: _misEtiquetas, gasto: event.gasto));
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
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });
    on<FiltradoGastosPorFecha>((event, emit) {
      filtroFechaInicial = event.fechaInicial;
      filtroFechaFinal = event.fechaFinal;
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });
    on<FiltradoGastosPorEtiqueta>((event, emit) {
      filtroIdEtiqueta = event.idEtiqueta;
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });
    on<FiltradoGastosPorVehiculo>((event, emit) {
      filtroIdVehiculo = event.idVehiculo;
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    
    });

    // Etiquetas
    on<ClickeadoAdministrarEtiquetas>((event, emit) {
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoAgregarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta());
    });
    on<AgregadoEtiqueta>((event, emit) async {
      await etiquetas.create(nombre: event.nombreEtiqueta);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
    });
    on<EliminadaEtiqueta>((event, emit) async {
      await etiquetas.delete(event.id);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoEditarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta(etiqueta: event.etiqueta));
    });
    on<EditadoEtiqueta>((event, emit) async {
      await etiquetas.update(id: event.etiqueta.id, nombre: event.etiqueta.nombre);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
    });

    // Gastos Archivados
    on<ClickeadoConsultarGastosArchivados>((event, emit) {
      _misGastosArchivados = gastosArchivados.fetchAll();
      filtroVehiculo = valorOpcionTodas.toString();
      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });
    on<FiltradoGastoArchivadoPorVehiculo>((event, emit) {
      filtroVehiculo = event.matricula;
      _misGastosArchivados = obtenerGastosArchivados(event.matricula);

      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });
    on<EliminadosGastosArchivados>((event, emit) async {
      await eliminarGastosArchivados(event);
      _misGastosArchivados = gastosArchivados.fetchAll();
      misVehiculosArchivados = gastosArchivados.fetchAllVehicles();
      filtroVehiculo = valorOpcionTodas.toString();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, vehiculoSeleccionado: filtroVehiculo, misVehiculosArchivados: misVehiculosArchivados));
    });

    // MISC
    on<ClickeadoRegresarAMisvehiculos>((event, emit) async {
      reiniciarFiltrosGastos();
      _misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoRegresarAAdministradorEtiquetas>((event, emit) {
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
    });
    on<ClickeadoregresarAConsultarGastos>((event, emit) {
      _misGastos = obtenerGastos();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));
    });

    // Bottom Bar
    on<CambiadoDePantalla>((event, emit) async {
      if(event.pantalla == OpcionesBottomBar.misVehiculos){
        _misVehiculos = vehiculos.fetchAll();
        emit(MisVehiculos(misVehiculos: _misVehiculos, misEtiquetas: _misEtiquetas));
        return;
      }
      if(event.pantalla == OpcionesBottomBar.misEtiquetas){
        _misEtiquetas = etiquetas.fetchAll();
        emit(MisEtiquetas(misEtiquetas: _misEtiquetas));
        return;
      }
      reiniciarFiltrosGastos();
      _misGastos = obtenerGastos();
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroFechaInicial, fechaFinal: filtroFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroIdEtiqueta, filtroIdVehiculo: filtroIdVehiculo, misVehiculos: _misVehiculos));    
    });

  }
}


