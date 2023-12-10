// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/gastos.dart';
import 'package:mis_vehiculos/database/tablas/gastos_archivados.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/funciones/funciones.dart';
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
  final String buscarVehiculosQueContengan;
  final bool estaModoSeleccionActivo;

  MisVehiculos({required this.misVehiculos, required this.buscarVehiculosQueContengan, required this.estaModoSeleccionActivo, });

  @override
  List<Object?> get props => [misVehiculos, buscarVehiculosQueContengan,estaModoSeleccionActivo];
}
class PlantillaVehiculo extends VehiculoEstado {
   final Vehiculo? vehiculo;

  PlantillaVehiculo({this.vehiculo,});

  @override
  List<Object?> get props => [vehiculo];
}

// GASTOS
class PlantillaGasto extends VehiculoEstado {
  final int idVehiculo;
  final Gasto? gasto;
  final Future <List<Etiqueta>>? misEtiquetas;
  final Future<List<Map<String, Object?>>>? listaMecanicoPorEtiqueta;
  final bool agregadaEtiquetaDesdeGasto;
  final bool esEditarGasto;

  PlantillaGasto({required this.idVehiculo, this.gasto, required this.misEtiquetas, this.listaMecanicoPorEtiqueta, this.agregadaEtiquetaDesdeGasto = false, this.esEditarGasto = false, });

  @override
  List<Object?> get props => [idVehiculo, gasto, misEtiquetas, listaMecanicoPorEtiqueta, agregadaEtiquetaDesdeGasto, esEditarGasto];
}
class MisGastos extends VehiculoEstado {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaInicial;
  final DateTime fechaFinal;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int filtroIdEtiqueta;
  final int filtroIdVehiculo;
  final Future <List<Vehiculo>>? misVehiculos;
  final String filtroMecanico;
  final RepresentacionGastos representacionGasto;
  final TipoReporte tipoReporte;

  MisGastos({
    required this.misGastos, 
    required this.fechaInicial, 
    required this.fechaFinal,
    required this.misEtiquetas,
    required this.filtroIdEtiqueta,
    required this.filtroIdVehiculo, 
    required this.misVehiculos,
    required this.filtroMecanico, 
    required this.representacionGasto, 
    required this.tipoReporte, 
  });

  @override
  List<Object?> get props => [misGastos, fechaInicial, fechaFinal, misEtiquetas, filtroIdEtiqueta, filtroIdVehiculo, misVehiculos, filtroMecanico, representacionGasto, tipoReporte];
}

// ETIQUETAS
class MisEtiquetas extends VehiculoEstado {
  final Future<List<Etiqueta>>? misEtiquetas;
  final bool estaModoSeleccionActivo;

  MisEtiquetas({required this.misEtiquetas, required this.estaModoSeleccionActivo, });
  
  @override
  List<Object?> get props => [misEtiquetas, estaModoSeleccionActivo];
}
class PlantillaEtiqueta extends VehiculoEstado {
  final Etiqueta? etiqueta;
  final Future<List<String>>? nombresEtiquetas;

  PlantillaEtiqueta({this.etiqueta, this.nombresEtiquetas, });

  @override
  List<Object?> get props => [etiqueta, nombresEtiquetas];
}

// GASTOS ARCHIVADOS
class MisGastosArchivados extends VehiculoEstado {
  final Future <List<GastoArchivado>>? misGastosArchivados;
  final int idVehiculoSeleccionado;
  final Future <List<Vehiculo>>? misVehiculosArchivados;
  final DateTime fechaInicial;
  final DateTime fechaFinal;

  MisGastosArchivados({
    required this.misGastosArchivados, 
    required this.idVehiculoSeleccionado, 
    required this.misVehiculosArchivados, 
    required this.fechaInicial, 
    required this.fechaFinal, 
  });

  @override
  List<Object?> get props => [misGastosArchivados, idVehiculoSeleccionado, misVehiculosArchivados, fechaInicial, fechaFinal];
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
class BuscadoVehiculos extends VehiculoEvento {
  final String buscarVehiculosQueContengan;

  BuscadoVehiculos({required this.buscarVehiculosQueContengan});
}
class CambiadaModalidadSeleccionVehiculo extends VehiculoEvento {
  final bool estaModoSeleccionActivo;

  CambiadaModalidadSeleccionVehiculo({required this.estaModoSeleccionActivo});
}
class EliminadosVehiculosSeleccionados extends VehiculoEvento {
  final List<int> idsVehiculosSeleccionados;

  EliminadosVehiculosSeleccionados({required this.idsVehiculosSeleccionados});
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
class AgregadoEtiquetaDesdeGasto extends VehiculoEvento {
  final String nombreEtiqueta;
  final int idVehiculo;
  final Gasto? gasto;
  final bool esEditarGasto;

  AgregadoEtiquetaDesdeGasto({required this.nombreEtiqueta, required this.idVehiculo, this.gasto, this.esEditarGasto = false});
}
class EliminadasEtiquetasSeleccionadas extends VehiculoEvento {
  final List<int> idsEtiquetasSeleccionadas;

  EliminadasEtiquetasSeleccionadas({required this.idsEtiquetasSeleccionadas});
}
class CambiadaModalidadSeleccionEtiqueta extends VehiculoEvento {
  final bool estaModoSeleccionActivo;

  CambiadaModalidadSeleccionEtiqueta({required this.estaModoSeleccionActivo});
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
class VisibilitadoFiltros extends VehiculoEvento {
  final bool estanVisibles;

  VisibilitadoFiltros({required this.estanVisibles});
}
class FiltradoGastosPorMecanico extends VehiculoEvento{
  final String mecanico;

  FiltradoGastosPorMecanico({required this.mecanico});
}
class CambiadaRepresentacionGastos extends VehiculoEvento {
  final RepresentacionGastos representacionGastos;

  CambiadaRepresentacionGastos({required this.representacionGastos});
}
class CambiadoAnoAMostrarReporte extends VehiculoEvento {
  final int anoAMostrarReporte;

  CambiadoAnoAMostrarReporte({required this.anoAMostrarReporte});
}
class CambiadoMesAMostrarReporte extends VehiculoEvento{
  final int mesAMostrarReporte;

  CambiadoMesAMostrarReporte({required this.mesAMostrarReporte});
}
class CambiadoTipoReporte extends VehiculoEvento {
  final TipoReporte tipoReporte;

  CambiadoTipoReporte({required this.tipoReporte});
}

// GASTOS ARCHIVADOS
class ClickeadoConsultarGastosArchivados extends VehiculoEvento {}
class FiltradoGastoArchivadoPorVehiculo extends VehiculoEvento {
  final int idVehiculo;

  FiltradoGastoArchivadoPorVehiculo({required this.idVehiculo});
}
class EliminadosGastosArchivados extends VehiculoEvento {
  final int idVehiculo;

  EliminadosGastosArchivados({required this.idVehiculo});
}
class FiltradoGastosArchivadosPorFecha extends VehiculoEvento {
  final DateTime fechaInicial;
  final DateTime fechaFinal;

  FiltradoGastosArchivadosPorFecha({required this.fechaInicial, required this.fechaFinal});
}
class RestauradoGastoArchivado extends VehiculoEvento {
  final GastoArchivado gastoArchivado;
  final bool debeRestaurarVehiculo;

  RestauradoGastoArchivado({required this.gastoArchivado,required this.debeRestaurarVehiculo, });
}
class EliminadoGastoArchivado extends VehiculoEvento {
  final int idGastoArchivado;

  EliminadoGastoArchivado({required this.idGastoArchivado});
}
class RestauradosGastosArchivados extends VehiculoEvento {
  final int idVehiculo;

  RestauradosGastosArchivados({required this.idVehiculo});
}

// MISC
class Inicializado extends VehiculoEvento {}
class ClickeadoRegresarAMisvehiculos extends VehiculoEvento {
  final bool reiniciarBusquedaDeVehiculos;

  ClickeadoRegresarAMisvehiculos({this.reiniciarBusquedaDeVehiculos = false});
}
class ClickeadoRegresarAAdministradorEtiquetas extends VehiculoEvento {}
class ClickeadoregresarAConsultarGastos extends VehiculoEvento {}
class ClickeadoRegresarDesdeGastos extends VehiculoEvento {}

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
  Future<List<String>>? matriculasVehiculos; // Para no ingresar vehiculos duplicados.
  String buscarVehiculosQueContengan = ""; // Filtro de búsqueda en MisVehículos.
  bool estaModoSeleccionVehiculosActivo = false;

  // Etiquetas
  Future<List<Etiqueta>>? get misEtiquetas => _misEtiquetas;
  Future<List<String>>? nombresEtiquetas; // Para no ingresar etiquetas duplicadas.
  bool estaModoSeleccionEtiquetasActivo = false;

  // Gastos
  DateTime filtroGastosFechaInicial = DateTime.now();
  DateTime filtroGastosFechaFinal = DateTime.now();
  int filtroGastosIdEtiqueta = valorOpcionTodas;
  int filtroGastosIdVehiculo = valorOpcionTodas;
  Future<List<Map<String, Object?>>>? listaMecanicoPorEtiqueta; // IA para rellenar automáticamente campo mecánico.
  bool filtrosGastosVisibles = true;
  String filtroGastosMecanico = "";
  Future <List<Gasto>>? misGastosGlobales;
  RepresentacionGastos representacionGasto = RepresentacionGastos.lista;
  int anoAMostrarReporte = 0;
  int mesAMostrarReporte = 0;
  TipoReporte tipoReporte = TipoReporte.year;

  // Gastos Archivados
  int filtroGastosArchivadosIdVehiculo = valorOpcionTodas;
  Future<List<Vehiculo>>? misVehiculosArchivados;
  DateTime filtroGastosArchivadosFechaInicial = DateTime.now();
  DateTime filtroGastosArchivadosFechaFinal = DateTime.now();

  // MÉTODOS
  // Métodos para vehículos
  void abortarSeleccionVehiculos() {
    estaModoSeleccionVehiculosActivo = false;
  }
  Future<void> eliminarVehiculosSeleccionados(List<int> idsVehiculosSeleccionados) async {
    for (var idVehiculo in idsVehiculosSeleccionados) {
      if (idVehiculo == filtroGastosIdVehiculo) { // Si se elimina el vehiculo seleccionado en el filtro, se reinicia a Opcion 'Todos'.
        filtroGastosIdVehiculo = valorOpcionTodas; 
        reiniciarTipoReporte(); // Reiniciar reporte
      }
      await archivarGastosDeIdVehiculo(idVehiculo);
      await vehiculos.delete(idVehiculo);
    }
    abortarSeleccionVehiculos();
  }

  //Métodos para gastos.
  void reiniciarFiltrosGastos() {
    //yyyy-MM-dd HH:mm:ss
    filtroGastosFechaFinal = obtenerValorMaximoDelDiaDeFecha(DateTime.now());
    filtroGastosFechaInicial = DateTime.parse('${filtroGastosFechaFinal.year}-${normalizarNumeroA2DigitosFecha(filtroGastosFechaFinal.month)}-01');
    filtroGastosIdEtiqueta = valorOpcionTodas;
    filtroGastosIdVehiculo = valorOpcionTodas;
  }
  Future<List<Gasto>> obtenerGastosFiltrados(){
    int? idVehiculo = (filtroGastosIdVehiculo == valorOpcionTodas)?null:filtroGastosIdVehiculo;

    misGastosGlobales = gastos.fetchAllInnerJoined(); // Obtiene los gastos de toda la lista de un vehiculo proporcionado. Esto es para el Reporte.

    return gastos.fetchAllWithFilters(filtroGastosFechaInicial, filtroGastosFechaFinal, idVehiculo);
  }
  void reiniciarTipoReporte() {
    tipoReporte = TipoReporte.year;
  }

  // Métodos para gastos archivados.
  Future<void> archivarGastosDeIdVehiculo(int idVehiculo) async {
    List<Gasto> misGastosPorVehiculo = await Gastos().fetchByVehicleId(idVehiculo);
    for (var gasto in misGastosPorVehiculo) {
      DateTime fechaNormalizada = DateTime.fromMillisecondsSinceEpoch(DateTime.parse(gasto.fecha).millisecondsSinceEpoch);
      Map<String,dynamic> datos = {
        "vehiculo": gasto.nombreVehiculo,
        "etiqueta": gasto.nombreEtiqueta,
        "mecanico": gasto.mecanico,
        "lugar": gasto.lugar,
        "costo": gasto.costo,
        "fecha": fechaNormalizada.millisecondsSinceEpoch.toString(),
        "id_vehiculo": gasto.vehiculo,
        "id_etiqueta": gasto.etiqueta,
        "marca_vehiculo": gasto.marcaVehiculo,
        "modelo_vehiculo": gasto.modeloVehiculo,
        "color_vehiculo": gasto.colorVehiculo,
        "ano_vehiculo": gasto.anoVehiculo,
      };
      await gastosArchivados.create(datos: datos);
    }
  }
  Future<void> archivarGastoIndividual(int idGasto) async {
    Gasto gasto = await Gastos().fetchById(idGasto);
    DateTime fechaNormalizada = DateTime.fromMillisecondsSinceEpoch(DateTime.parse(gasto.fecha).millisecondsSinceEpoch);
    Map<String,dynamic> datos = {
      "vehiculo": gasto.nombreVehiculo,
      "etiqueta": gasto.nombreEtiqueta,
      "mecanico": gasto.mecanico,
      "lugar": gasto.lugar,
      "costo": gasto.costo,
      "fecha": fechaNormalizada.millisecondsSinceEpoch.toString(),
      "id_vehiculo": gasto.vehiculo,
      "id_etiqueta": gasto.etiqueta,
      "marca_vehiculo": gasto.marcaVehiculo,
      "modelo_vehiculo": gasto.modeloVehiculo,
      "color_vehiculo": gasto.colorVehiculo,
      "ano_vehiculo": gasto.anoVehiculo,
    };
    await gastosArchivados.create(datos: datos);
  }
  Future<List<GastoArchivado>> obtenerGastosArchivados() {
    int? idVehiculo = (filtroGastosArchivadosIdVehiculo == valorOpcionTodas)?null:filtroGastosArchivadosIdVehiculo;
    //return gastosArchivados.fetchByFilters(filtroGastosArchivadosFechaInicial, filtroGastosArchivadosFechaFinal, idVehiculo);
    return gastosArchivados.fetchAllWhereVehicleID(idVehiculo);
  }
  Future<void> eliminarGastosArchivadosPorIdVehiculo(int idVehiculo) async {
    if(idVehiculo == valorOpcionTodas) {
      await gastosArchivados.deleteAll();
      return;
    }
    await gastosArchivados.deleteWhereVehicleId(idVehiculo);

    /*int? idVehiculoAEliminar = idVehiculo;
    if (idVehiculoAEliminar == valorOpcionTodas) idVehiculoAEliminar = null;
    await gastosArchivados.deleteByFilters(filtroGastosArchivadosFechaInicial, filtroGastosArchivadosFechaFinal, idVehiculoAEliminar);*/
  }
  void reiniciarFiltrosGastosArchivados() {
    //yyyy-MM-dd HH:mm:ss
    filtroGastosArchivadosFechaFinal = obtenerValorMaximoDelDiaDeFecha(DateTime.now());
    filtroGastosArchivadosFechaInicial = DateTime.parse('${filtroGastosArchivadosFechaFinal.year}-01-01');
    filtroGastosArchivadosIdVehiculo = valorOpcionTodas;
  } 
  void reiniciarFiltroVehiculoGastosArchivados() {
    filtroGastosArchivadosIdVehiculo = valorOpcionTodas;
  }
  Future<int> obtenerIdEtiquetaGastoArchivadoARestaurar(GastoArchivado gastoArchivado) async {
    int? idEtiquetaFinal;
    Etiqueta? etiqueta = await etiquetas.fetchById(gastoArchivado.idEtiqueta);
    if (etiqueta == null){
      etiqueta = await etiquetas.fetchByName(gastoArchivado.etiqueta);
      if (etiqueta != null) return etiqueta.id;
      
      idEtiquetaFinal = await crearEtiqueta(idEtiquetaFinal, gastoArchivado);
    }
    idEtiquetaFinal??= etiqueta!.id;
    return idEtiquetaFinal;
  }
  Future<int?> crearEtiqueta(int? idEtiquetaFinal, GastoArchivado gastoArchivado) async {
    idEtiquetaFinal = await etiquetas.create(nombre: gastoArchivado.etiqueta);
    return idEtiquetaFinal;
  }
  Future<int?> obtenerIdVehiculoGastoArchivadoARestaurar(GastoArchivado gastoArchivado) async {
    int idVehiculoABuscar = (filtroGastosArchivadosIdVehiculo != valorOpcionTodas)? filtroGastosArchivadosIdVehiculo:gastoArchivado.idVehiculo;
    Vehiculo? vehiculo = await vehiculos.fetchById(idVehiculoABuscar);
    //Vehiculo? vehiculo = await vehiculos.fetchById(gastoArchivado.idVehiculo);

    int? idVehiculoFinal;
    //if (event.debeRestaurarVehiculo){
    if (vehiculo == null){
      Map<String,dynamic> datos = {
        "matricula": gastoArchivado.vehiculo,
        "marca": gastoArchivado.marcaVehiculo,
        "modelo": gastoArchivado.modeloVehiculo,
        "color": gastoArchivado.colorVehiculo,
        "ano": gastoArchivado.anoVehiculo,
      };
      idVehiculoFinal = await crearVehiculo(idVehiculoFinal, datos);
      
      // Tercero, actualizar todos los gastosArchviados de ese vehiculo para referenciar la Id del Vehiculo restaurado.
      await gastosArchivados.updateAllWhereVehicleId(idVehiculoVieja: idVehiculoABuscar, idVehiculoNueva: idVehiculoFinal);
    }
    idVehiculoFinal??= idVehiculoABuscar;
    if(filtroGastosArchivadosIdVehiculo != valorOpcionTodas) filtroGastosArchivadosIdVehiculo = idVehiculoFinal; // Establce el filtro actual del vehiculo, en caso de que se haya creado un vehiculo
    return idVehiculoFinal;
  }
  Future<int> crearVehiculo(int? idVehiculoFinal, Map<String, dynamic> datos) async {
    idVehiculoFinal = await vehiculos.create(datos: datos);
    return idVehiculoFinal;
  }
  Future<void> restaurarGastoArchivado(GastoArchivado gastoArchivado) async {
    // Primero comprobar que existe etiqueta
    int idEtiquetaFinal = await obtenerIdEtiquetaGastoArchivadoARestaurar(gastoArchivado);
    
    // Segundo, comprobar que el vehiculo exista. Si no, lo crea.
    int? idVehiculoFinal = await obtenerIdVehiculoGastoArchivadoARestaurar(gastoArchivado);
    
    // Siguiente, restaurar el gasto a la tabla de "Gastos"
    await restaurarGasto(gastoArchivado, idVehiculoFinal, idEtiquetaFinal);
    
    // Eliminar el gasto de la tabla de "gastosArchivados"
    await gastosArchivados.delete(gastoArchivado.id); 
  }
  Future<void> restaurarGasto(GastoArchivado gastoArchivado, int? idVehiculoFinal, int idEtiquetaFinal) async {
    DateTime fechaRecibida = DateTime.parse(gastoArchivado.fecha);
    int fechaEnMilisegundos = fechaRecibida.millisecondsSinceEpoch;
    Map<String,dynamic> datos = {
      "vehiculo": idVehiculoFinal,
      "etiqueta": idEtiquetaFinal,
      "mecanico": gastoArchivado.mecanico,
      "lugar": gastoArchivado.lugar,
      "costo": gastoArchivado.costo,
      "fecha": fechaEnMilisegundos,
    };
    
    await gastos.create(datos: datos);
  }

  // Métodos para etiquetas
  Future<void> eliminarEtiquetasSeleccionadas(List<int> idsEtiquetasSeleccionadas) async {
    for (var idEtiqueta in idsEtiquetasSeleccionadas) {
      if (idEtiqueta == filtroGastosIdEtiqueta) filtroGastosIdEtiqueta = valorOpcionTodas; // Si se elimina la etiqueta seleccionado en el filtro, se reinicia a Opcion 'Todas'.
      await etiquetas.delete(idEtiqueta);
    }
    abortarSeleccionEtiquetas();
  }
  void abortarSeleccionEtiquetas() {
    estaModoSeleccionEtiquetasActivo = false;
  }
  Future<bool> hayAlmenosUnaEtiqueta() async{
    var etiquetas = await _misEtiquetas??[];
    return etiquetas.isNotEmpty;
  }


  VehiculoBloc() : super(Inicial()) {
    on<Inicializado>((event, emit) async {
      reiniciarFiltrosGastos();
      reiniciarFiltrosGastosArchivados();
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      _misEtiquetas = etiquetas.fetchAll();
      _misGastos = obtenerGastosFiltrados();
      _misGastosArchivados = gastosArchivados.fetchAll();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
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
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan,estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    /*on<EliminadoVehiculo>((event, emit) async {
      await archivarGastosDeIdVehiculo(event.id);
      await vehiculos.delete(event.id);
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });*/
    on<EditadoVehiculo>((event, emit) async {
      Map<String,dynamic> datos = {
        "matricula": event.vehiculo.matricula,
        "marca": event.vehiculo.marca,
        "modelo": event.vehiculo.modelo,
        "color": event.vehiculo.color,
        "ano": event.vehiculo.ano,
      };
      await vehiculos.update(id: event.vehiculo.id, datos: datos);
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    on<ClickeadoAgregarVehiculo>((event, emit) async {
      matriculasVehiculos = vehiculos.fetchAllPlatesExcept('0');
      emit(PlantillaVehiculo());
    });
    on<ClickeadoEditarVehiculo>((event, emit) async {
      matriculasVehiculos = vehiculos.fetchAllPlatesExcept(event.vehiculo.matricula);
      emit(PlantillaVehiculo(vehiculo: event.vehiculo,));
    });
    on<BuscadoVehiculos>((event, emit) {
      buscarVehiculosQueContengan = event.buscarVehiculosQueContengan;
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    on<CambiadaModalidadSeleccionVehiculo>((event, emit) {
      estaModoSeleccionVehiculosActivo = event.estaModoSeleccionActivo;
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    on<EliminadosVehiculosSeleccionados>((event, emit) async {
      await eliminarVehiculosSeleccionados(event.idsVehiculosSeleccionados);
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });

    // Gastos
    on<ClickeadoAgregarGasto>((event, emit) {
      listaMecanicoPorEtiqueta = gastos.fetchMostOccurringMechanics(event.idVehiculo);
      emit(PlantillaGasto(idVehiculo: event.idVehiculo, misEtiquetas: _misEtiquetas, listaMecanicoPorEtiqueta: listaMecanicoPorEtiqueta));
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
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    on<ClickeadoConsultarGastos>((event, emit) async {    
      //reiniciarFiltrosGastos();
      _misGastos = obtenerGastosFiltrados();
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });
    on<EliminadoGasto>((event, emit) async {
      await archivarGastoIndividual(event.id);
      await gastos.delete(event.id);
      _misGastos = obtenerGastosFiltrados();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });
    on<ClickeadoEditarGasto>((event, emit) {
      listaMecanicoPorEtiqueta = gastos.fetchMostOccurringMechanics(event.gasto.vehiculo);
      emit(PlantillaGasto(idVehiculo: 0, gasto: event.gasto, misEtiquetas: _misEtiquetas, listaMecanicoPorEtiqueta: listaMecanicoPorEtiqueta, esEditarGasto: true));
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
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });
    on<FiltradoGastosPorFecha>((event, emit) {
      filtroGastosFechaInicial = event.fechaInicial;
      filtroGastosFechaFinal = event.fechaFinal;
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });
    on<FiltradoGastosPorEtiqueta>((event, emit) {
      filtroGastosIdEtiqueta = event.idEtiqueta;
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });
    on<FiltradoGastosPorVehiculo>((event, emit) {
      filtroGastosIdVehiculo = event.idVehiculo;
      reiniciarTipoReporte();
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));    
    });
    on<VisibilitadoFiltros>((event, emit) {
      filtrosGastosVisibles = event.estanVisibles;
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
    });
    on<FiltradoGastosPorMecanico>((event, emit) {
      filtroGastosMecanico = event.mecanico;
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
    });
    on<CambiadaRepresentacionGastos>((event, emit) {
      representacionGasto = event.representacionGastos;
      reiniciarTipoReporte(); // Devovler a año
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
    });
    on<CambiadoAnoAMostrarReporte>((event, emit) {
      anoAMostrarReporte = event.anoAMostrarReporte;
    });
    on<CambiadoMesAMostrarReporte>((event, emit) {
      mesAMostrarReporte = event.mesAMostrarReporte;      
    });
    on<CambiadoTipoReporte>((event, emit) {
      tipoReporte = event.tipoReporte;
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
    });
    on<ClickeadoRegresarDesdeGastos>((event, emit) {
      if (representacionGasto == RepresentacionGastos.reporte && tipoReporte == TipoReporte.day){
        tipoReporte = TipoReporte.month;
        emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
        return;
      }
      if (representacionGasto == RepresentacionGastos.reporte && tipoReporte == TipoReporte.month){
        tipoReporte = TipoReporte.year;
        emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));   
        return;
      }
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    
    });

    // Etiquetas
    on<ClickeadoAdministrarEtiquetas>((event, emit) {
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });   
    on<AgregadoEtiqueta>((event, emit) async {
      await etiquetas.create(nombre: event.nombreEtiqueta);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    on<EditadoEtiqueta>((event, emit) async {
      await etiquetas.update(id: event.etiqueta.id, nombre: event.etiqueta.nombre);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    on<EliminadaEtiqueta>((event, emit) async {
      await etiquetas.delete(event.id);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    on<ClickeadoAgregarEtiqueta>((event, emit) {
      nombresEtiquetas = etiquetas.fetchAllTagsExcept('0');
      emit(PlantillaEtiqueta(nombresEtiquetas: nombresEtiquetas));
    });
    on<ClickeadoEditarEtiqueta>((event, emit) {
      nombresEtiquetas = etiquetas.fetchAllTagsExcept(event.etiqueta.nombre);
      emit(PlantillaEtiqueta(etiqueta: event.etiqueta, nombresEtiquetas: nombresEtiquetas));
    });   
    on<AgregadoEtiquetaDesdeGasto>((event, emit) async {
      await etiquetas.create(nombre: event.nombreEtiqueta);
      _misEtiquetas = etiquetas.fetchAll();
      emit(PlantillaGasto(idVehiculo: event.idVehiculo, gasto: event.gasto, misEtiquetas: _misEtiquetas, listaMecanicoPorEtiqueta: listaMecanicoPorEtiqueta, agregadaEtiquetaDesdeGasto: true, esEditarGasto: event.esEditarGasto));
    });
    on<CambiadaModalidadSeleccionEtiqueta>((event, emit) {
      estaModoSeleccionEtiquetasActivo = event.estaModoSeleccionActivo;
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    on<EliminadasEtiquetasSeleccionadas>((event, emit) async {
      await eliminarEtiquetasSeleccionadas(event.idsEtiquetasSeleccionadas);
      _misEtiquetas = etiquetas.fetchAll();
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    
    // Gastos Archivados
    on<ClickeadoConsultarGastosArchivados>((event, emit) {
      //reiniciarFiltrosGastosArchivados();
      _misGastosArchivados = obtenerGastosArchivados();
      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));
    });
    on<FiltradoGastoArchivadoPorVehiculo>((event, emit) {
      filtroGastosArchivadosIdVehiculo = event.idVehiculo;
      _misGastosArchivados = obtenerGastosArchivados();

      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));
    });
    on<EliminadosGastosArchivados>((event, emit) async {
      await eliminarGastosArchivadosPorIdVehiculo(event.idVehiculo);
      
      reiniciarFiltroVehiculoGastosArchivados();

      _misGastosArchivados = obtenerGastosArchivados();
      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));
    });
    on<FiltradoGastosArchivadosPorFecha>((event, emit) {
      filtroGastosArchivadosFechaInicial = event.fechaInicial;
      filtroGastosArchivadosFechaFinal = event.fechaFinal;
      _misGastosArchivados = obtenerGastosArchivados();
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));
    });
    on<RestauradoGastoArchivado>((event, emit) async {
      
      await restaurarGastoArchivado(event.gastoArchivado); 

      // Checa si ese vehiculo ya no tiene gastos Archivados, para limpiar el filtro.
      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      var vehiculosArchivados = await misVehiculosArchivados;
      if (vehiculosArchivados == null || vehiculosArchivados.isEmpty || !vehiculosArchivados.any((element) => element.id == filtroGastosArchivadosIdVehiculo)) reiniciarFiltroVehiculoGastosArchivados();
      
      //reiniciarFiltroVehiculoGastosArchivados();

      _misGastosArchivados = obtenerGastosArchivados();
      _misEtiquetas = etiquetas.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));      
    });
    on<EliminadoGastoArchivado>((event, emit) async {
      await gastosArchivados.delete(event.idGastoArchivado); 

      // Checa si ese vehiculo ya no tiene gastos Archivados, para limpiar el filtro.
      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      var vehiculosArchivados = await misVehiculosArchivados;
      if (vehiculosArchivados == null ||  vehiculosArchivados.isEmpty || !vehiculosArchivados.any((element) => element.id == filtroGastosArchivadosIdVehiculo)) reiniciarFiltroVehiculoGastosArchivados();
      //reiniciarFiltroVehiculoGastosArchivados();

      _misGastosArchivados = obtenerGastosArchivados();
      
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));      
    });
    on<RestauradosGastosArchivados>((event, emit) async {
      //List<GastoArchivado> gastosArchivadosDeVehiculo = await gastosArchivados.fetchByFilters(filtroGastosArchivadosFechaInicial, filtroGastosArchivadosFechaFinal, event.idVehiculo);
      List<GastoArchivado> gastosArchivadosDeVehiculo = await gastosArchivados.fetchAllWhereVehicleID(event.idVehiculo);
      for (var gastoArchivado in gastosArchivadosDeVehiculo) {
        await restaurarGastoArchivado(gastoArchivado);
      }
      misVehiculosArchivados = gastosArchivados.fetchAllArchivedVehicles();
      reiniciarFiltroVehiculoGastosArchivados();
      _misGastosArchivados = obtenerGastosArchivados();
      _misEtiquetas = etiquetas.fetchAll(); // Por si se recrearon etiquetas
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent(); // Por si se restauraron vehiculos
      
      emit(MisGastosArchivados(misGastosArchivados: _misGastosArchivados, idVehiculoSeleccionado: filtroGastosArchivadosIdVehiculo, misVehiculosArchivados: misVehiculosArchivados, fechaInicial: filtroGastosArchivadosFechaInicial, fechaFinal: filtroGastosArchivadosFechaFinal));      
    });

    // MISC
    on<ClickeadoRegresarAMisvehiculos>((event, emit) async {
      //reiniciarFiltrosGastos();
      //_misVehiculos = vehiculos.fetchAll();
      _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
      if (event.reiniciarBusquedaDeVehiculos) buscarVehiculosQueContengan = "";
      emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
    });
    on<ClickeadoRegresarAAdministradorEtiquetas>((event, emit) {
      emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
    });
    on<ClickeadoregresarAConsultarGastos>((event, emit) {
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));
    });

    // Bottom Bar
    on<CambiadoDePantalla>((event, emit) async {
      abortarSeleccionEtiquetas();
      abortarSeleccionVehiculos();
      if(event.pantalla == OpcionesBottomBar.misVehiculos){
        //_misVehiculos = vehiculos.fetchAll();

        //var listaFrecuencia = await vehiculos.fetchAllFavoritesAndFrequent();
        //listaFrecuencia.forEach(print);

        _misVehiculos = vehiculos.fetchAllFavoritesAndFrequent();
        emit(MisVehiculos(misVehiculos: _misVehiculos, buscarVehiculosQueContengan: buscarVehiculosQueContengan, estaModoSeleccionActivo: estaModoSeleccionVehiculosActivo));
        return;
      }
      if(event.pantalla == OpcionesBottomBar.misEtiquetas){
        _misEtiquetas = etiquetas.fetchAll();
        emit(MisEtiquetas(misEtiquetas: _misEtiquetas, estaModoSeleccionActivo: estaModoSeleccionEtiquetasActivo));
        return;
      }
      reiniciarTipoReporte();
      //reiniciarFiltrosGastos();
      _misGastos = obtenerGastosFiltrados();
      emit(MisGastos(misGastos: _misGastos, fechaInicial: filtroGastosFechaInicial, fechaFinal: filtroGastosFechaFinal, misEtiquetas: _misEtiquetas, filtroIdEtiqueta: filtroGastosIdEtiqueta, filtroIdVehiculo: filtroGastosIdVehiculo, misVehiculos: _misVehiculos, filtroMecanico: filtroGastosMecanico, representacionGasto: representacionGasto, tipoReporte: tipoReporte));    
    });

  }
}


