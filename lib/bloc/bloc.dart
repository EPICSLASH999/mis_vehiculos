// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
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
  List<Vehiculo> vehiculos = [];
  llenarvehiculosParaProps () async {
    vehiculos = await misVehiculos??[];
  }

  MisVehiculos({required this.misVehiculos}){
    llenarvehiculosParaProps();
  }

  @override
  List<Object?> get props => [vehiculos];
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
class AgregarGasto extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
class EditarGasto extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
class ConsultarGastos extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
class ConsultargastosArchivados extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}

// ETIQUETAS
class AdministrarEtiquetas extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
class AgregarEtiqueta extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
class EditarEtiqueta extends VehiculoEstado {
  @override
  List<Object?> get props => [];
}
/* --------------------------------------------------- */

/* --------------------- EVENTOS --------------------- */
sealed class VehiculoEvento {}

// VEHICULOS
class ClickeadoAgregarVehiculo extends VehiculoEvento {}
class EliminadoVehiculo extends VehiculoEvento {
  final int id;

  EliminadoVehiculo({required this.id});
}
class FiltradoVehiculos extends VehiculoEvento {}
class ClickeadoEditarVehiculo extends VehiculoEvento {
   final Vehiculo vehiculo;

  ClickeadoEditarVehiculo({required this.vehiculo});
}
class CheckeadoSeleccionarTodosVehiculos extends VehiculoEvento {}
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
class EliminadaEtiqueta extends VehiculoEvento {}
class ClickeadoEditarEtiqueta extends VehiculoEvento {}
class EditadoEtiqueta extends VehiculoEvento {}
class AgregadoEtiqueta extends VehiculoEvento {}

// GASTOS
class ClickeadoConsultarGastosArchivados extends VehiculoEvento {}
class ClickeadoAgregarGasto extends VehiculoEvento {}
class ClickeadoConsultarGastos extends VehiculoEvento {}
class AgregadoGasto extends VehiculoEvento {}
class ConsultadoGastos extends VehiculoEvento {}
class CheckeadoEditarGasto extends VehiculoEvento {}
class EliminadoGasto extends VehiculoEvento {}

// MISC
class Inicializado extends VehiculoEvento {}
class RegresadoAEstado extends VehiculoEvento {}
/* --------------------------------------------------- */


class VehiculoBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  Future <List<Vehiculo>>? misVehiculos;
  final vehiculos = Vehiculos();

  VehiculoBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: misVehiculos));
    });
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
      emit(MisVehiculos(misVehiculos: misVehiculos));
    });
    on<EliminadoVehiculo>((event, emit) async {
      // TODO: Pasar registros de gastos a tabla gastos_archivados y en lugar de id de coche, que sea matricula.
      await vehiculos.delete(event.id);
      misVehiculos = vehiculos.fetchAll();
      emit(MisVehiculos(misVehiculos: misVehiculos));
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
      emit(MisVehiculos(misVehiculos: misVehiculos));
    });
    on<ClickeadoAgregarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo());
    });
    on<ClickeadoEditarVehiculo>((event, emit) async {
      emit(PlantillaVehiculo(vehiculo: event.vehiculo));
    });
  }
}





