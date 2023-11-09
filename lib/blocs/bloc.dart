// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';

import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';

/* --------------------- ESTADOS --------------------- */
sealed class VehiculoEstado with EquatableMixin{}

class Inicial extends VehiculoEstado{
  @override
  List<Object?> get props => [];
}

// VEHICULOS
class MisVehiculos extends VehiculoEstado {
  final Future<List<Vehiculo>>? misVehiculos;
  final List<int> idsVehiculosSeleccionados;
  
  List<Vehiculo> vehiculos = []; // Para los tests
  llenarvehiculosParaProps () async {
    vehiculos = await misVehiculos??[];
  }

  MisVehiculos({required this.misVehiculos, required this.idsVehiculosSeleccionados}){
    llenarvehiculosParaProps();
  }

  @override
  List<Object?> get props => [vehiculos, idsVehiculosSeleccionados];
}
class PlantillaVehiculo extends VehiculoEstado {
   final Vehiculo? vehiculo;

  PlantillaVehiculo({this.vehiculo});

  @override
  List<Object?> get props => [vehiculo];
}
/*class Editarvehiculo extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}*/

// GASTOS
class PlantillaGasto extends VehiculoEstado {
  final int idVehiculo;
  final Future<List<Etiqueta>>? misEtiquetas;
  final Gasto? gasto;

  PlantillaGasto({required this.idVehiculo, required this.misEtiquetas, this.gasto});

  @override
  List<Object?> get props => [idVehiculo, misEtiquetas];
}
/*class EditarGasto extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}*/
class MisGastos extends VehiculoEstado {
  Future <List<Gasto>>? misGastos;
  final DateTime fechaInicial;
  final DateTime fechaFinal;

  MisGastos({required this.misGastos, required this.fechaInicial, required this.fechaFinal});

  @override
  List<Object?> get props => [misGastos];
}
class ConsultargastosArchivados extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}

// ETIQUETAS
class AdministradorEtiquetas extends VehiculoEstado {
  final Future<List<Etiqueta>>? misEtiquetas;

  AdministradorEtiquetas({required this.misEtiquetas});
  
  @override
  List<Object?> get props => [misEtiquetas];
}
class PlantillaEtiqueta extends VehiculoEstado {
  final Etiqueta? etiqueta;

  PlantillaEtiqueta({this.etiqueta});

  @override
  List<Object?> get props => [etiqueta];
}
/*class EditarEtiqueta extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}*/
/* --------------------------------------------------- */

/* --------------------- EVENTOS --------------------- */
sealed class VehiculoEvento {}

// VEHICULOS
class ClickeadoAgregarVehiculo extends VehiculoEvento {}
class EliminadoVehiculo extends VehiculoEvento {
  final int id;

  EliminadoVehiculo({required this.id});
}
/*class FiltradoVehiculos extends VehiculoEvento {}*/
class ClickeadoEditarVehiculo extends VehiculoEvento {
   final Vehiculo vehiculo;

  ClickeadoEditarVehiculo({required this.vehiculo});
}
/*class CheckeadoSeleccionarTodosVehiculos extends VehiculoEvento {}*/
class AgregadoVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  AgregadoVehiculo({required this.vehiculo});
}
class EditadoVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  EditadoVehiculo({required this.vehiculo});
}
class ClickeadoSeleccionarVehiculo extends VehiculoEvento {
  final int idVehiculo;

  ClickeadoSeleccionarVehiculo({required this.idVehiculo});
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
class ClickeadoConsultarGastosArchivados extends VehiculoEvento {}
class ClickeadoAgregarGasto extends VehiculoEvento {
  final int idVehiculo;

  ClickeadoAgregarGasto({required this.idVehiculo});
}
class ClickeadoConsultarGastos extends VehiculoEvento {}
class AgregadoGasto extends VehiculoEvento {
  final Gasto gasto;

  AgregadoGasto({required this.gasto});
}
/*class ConsultadoGastos extends VehiculoEvento {}*/
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

// MISC
class Inicializado extends VehiculoEvento {}
class ClickeadoRegresarAMisvehiculos extends VehiculoEvento {}
class ClickeadoRegresarAAdministradorEtiquetas extends VehiculoEvento {}
/*class ClickeadoRegresarDesdeAdministradorEtiquetas extends VehiculoEvento {}*/
class ClickeadoregresarAConsultarGastos extends VehiculoEvento {}
/* --------------------------------------------------- */


class VehiculoBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  Future <List<Vehiculo>>? misVehiculos;
  final vehiculos = Vehiculos();

  Future <List<Etiqueta>>? misEtiquetas;
  final etiquetas = Etiquetas();

  Future <List<Gasto>>? misGastos;
  final gastos = Gastos();
  DateTime fechaInicial = DateTime.now();
  DateTime fechaFinal = DateTime.now();

  List<int> idsVehiculosSeleccionados = [];

  void gestionarVahiculoSeleccionado(int idVehiculo) {
    if (idsVehiculosSeleccionados.contains(idVehiculo)){
      idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..remove(idVehiculo);
      return;
    }
    idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..add(idVehiculo);
  }

  VehiculoBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      fechaInicial = DateTime(fechaFinal.year);
      misVehiculos = vehiculos.fetchAll();
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
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<EliminadoVehiculo>((event, emit) async {
      // TODO: Pasar registros de gastos a tabla gastos_archivados y en lugar de id de coche, que sea matricula.
      await vehiculos.delete(event.id);
      misVehiculos = vehiculos.fetchAll();
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
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<ClickeadoAgregarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo());
    });
    on<ClickeadoEditarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo(vehiculo: event.vehiculo));
    });
    on<ClickeadoSeleccionarVehiculo>((event, emit) {
      gestionarVahiculoSeleccionado(event.idVehiculo);
      emit(MisVehiculos(misVehiculos: misVehiculos, idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });

    // MISC
    on<ClickeadoRegresarAMisvehiculos>((event, emit) async {
      idsVehiculosSeleccionados = idsVehiculosSeleccionados.copiar()..clear();
      emit(MisVehiculos(misVehiculos: misVehiculos,idsVehiculosSeleccionados: idsVehiculosSeleccionados));
    });
    on<ClickeadoRegresarAAdministradorEtiquetas>((event, emit) {
      emit(AdministradorEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoregresarAConsultarGastos>((event, emit) {
      emit(MisGastos(misGastos: misGastos, fechaInicial: fechaInicial, fechaFinal: fechaFinal));
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
      misGastos = gastos.fetchAllWhereVehiclesIds(idsVehiculosSeleccionados);
      emit(MisGastos(misGastos: misGastos, fechaInicial: fechaInicial, fechaFinal: fechaFinal));
    });
    on<EliminadoGasto>((event, emit) async {
      await gastos.delete(event.id);
      misGastos = gastos.fetchAllWhereVehiclesIds(idsVehiculosSeleccionados);
      emit(MisGastos(misGastos: misGastos, fechaInicial: fechaInicial, fechaFinal: fechaFinal));
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
      misGastos = gastos.fetchAllWhereVehiclesIds(idsVehiculosSeleccionados);
      emit(MisGastos(misGastos: misGastos, fechaInicial: fechaInicial, fechaFinal: fechaFinal));
    });

    // Etiquetas
    on<ClickeadoAdministrarEtiquetas>((event, emit) {
      emit(AdministradorEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoAgregarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta());
    });
    on<AgregadoEtiqueta>((event, emit) async {
      await etiquetas.create(nombre: event.nombreEtiqueta);
      misEtiquetas = etiquetas.fetchAll();
      emit(AdministradorEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<EliminadaEtiqueta>((event, emit) async {
      await etiquetas.delete(event.id);
      misEtiquetas = etiquetas.fetchAll();
      emit(AdministradorEtiquetas(misEtiquetas: misEtiquetas));
    });
    on<ClickeadoEditarEtiqueta>((event, emit) {
      emit(PlantillaEtiqueta(etiqueta: event.etiqueta));
    });
    on<EditadoEtiqueta>((event, emit) async {
      await etiquetas.update(id: event.etiqueta.id, nombre: event.etiqueta.nombre);
      misEtiquetas = etiquetas.fetchAll();
      emit(AdministradorEtiquetas(misEtiquetas: misEtiquetas));
    });
  }
  
}





