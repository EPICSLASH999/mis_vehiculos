

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mis_vehiculos/widgets/widgets_fl_chart.dart';

// Variables Globales
// Métodos IA
int obtenerEtiquetaConMayorOcurrencias(List<Map<String, Object?>> listaMecanicoPorEtiqueta, bool agregadaEtiquetaDesdeGasto) {
  if (agregadaEtiquetaDesdeGasto) return valorNoTieneEtiquetaConMayorOcurrencias;
  if (listaMecanicoPorEtiqueta.isEmpty) return valorNoTieneEtiquetaConMayorOcurrencias;
  int idEtiquetaConMayorOcurrencias = (listaMecanicoPorEtiqueta.first["etiqueta"] as int);
  if (idEtiquetaConMayorOcurrencias == idSinEtiqueta) return valorNoTieneEtiquetaConMayorOcurrencias;
  return idEtiquetaConMayorOcurrencias;
}
String obtenerMecanicoConMayorOcurrenciasDeEtiqueta(List<Map<String, Object?>> listaMecanicoPorEtiqueta, int idEtiqueta) {
    if(listaMecanicoPorEtiqueta.isEmpty) return "";
    for (var element in listaMecanicoPorEtiqueta) {
      if((element["etiqueta"] as int) == idEtiqueta){
        String mecanico = (element["mecanico"]??'') as String;
        return mecanico;
      }
    }
    return "";
  }

/* -------------------------------- PLANTILLA GASTO -------------------------------- */
class WidgetPlantillaGasto extends StatefulWidget {
  final Gasto? gasto;
  final int idVehiculo;
  final Future<List<Map<String, Object?>>>? listaMecanicoPorEtiqueta; // Lista para rellenar mecánico más frecuente dependiendo de la etiqueta seleccionada.
  final bool fueAgregadaUnaEtiquetaDesdeGasto;
  final bool esEditarGasto;

  const WidgetPlantillaGasto({
    super.key, 
    required this.idVehiculo, 
    this.gasto, 
    this.listaMecanicoPorEtiqueta, 
    this.fueAgregadaUnaEtiquetaDesdeGasto = false,
    required this.esEditarGasto
  });

  @override
  State<WidgetPlantillaGasto> createState() => _WidgetPlantillaGastoState();
}

class _WidgetPlantillaGastoState extends State<WidgetPlantillaGasto> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController controladorVehiculo = TextEditingController();
  final TextEditingController controladorEtiqueta = TextEditingController();
  final TextEditingController controladorMecanico = TextEditingController();
  final TextEditingController controladorLugar = TextEditingController();
  final TextEditingController controladorCosto = TextEditingController();
  final TextEditingController controladorFecha = TextEditingController();

  DateTime fechaSeleccionada = DateTime.now();
  String idVehiculoString = "";

  bool get esEditarGasto => widget.esEditarGasto;
  String obtenerTexto() => '${(!esEditarGasto)? 'Agregar':'Editar'} Gasto'; // Titulo de la plantilla y botón.

  int? idEtiquetaSeleccionadaOriginal;

  bool escribioSuPropioMecanico = true;

  void inicializarValoresDeControladores(){
    idVehiculoString = (widget.gasto?.vehiculo??widget.idVehiculo.toString()).toString();
    controladorVehiculo.text = idVehiculoString;
    controladorEtiqueta.text = (widget.gasto?.etiqueta??'').toString();
    controladorMecanico.text = widget.gasto?.mecanico??'';
    controladorLugar.text = widget.gasto?.lugar??'';
    controladorCosto.text = (widget.gasto?.costo??'').toString();
    if (controladorCosto.text.endsWith(".0")) controladorCosto.text = controladorCosto.text.replaceAll(".0", ""); // Remueve el '.0' al final para evitar overflow de caracteres permitidos. En caso de que la cantidad sea el maximo de caracteres permitidos.

    DateTime fechaRecibida = DateTime.parse(widget.gasto?.fecha??fechaSeleccionada.toIso8601String());
    controladorFecha.text = DateFormat.yMMMd().format(fechaRecibida); // Esto es solo para mostrar la fecha en el TextBox
    fechaSeleccionada = fechaRecibida; // Esta es la fecha que se guardará en la BaseDeDatos
  }
  Gasto obtenerGasto(){
    return Gasto(
      id: (widget.gasto?.id)??0, 
      vehiculo: int.parse(idVehiculoString),
      etiqueta: int.parse(controladorEtiqueta.text),
      mecanico: controladorMecanico.text.trim(),
      lugar: controladorLugar.text,
      costo: double.tryParse(controladorCosto.text)??0,
      fecha: fechaSeleccionada.millisecondsSinceEpoch.toString()
    );
  }
  VoidCallback funcionAlPresionarFecha(){
    return () async {
      DateTime? nuevaFecha = await showDatePicker(
        context: context, 
        initialDate: fechaSeleccionada,
        firstDate: DateTime(1970), 
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly
      );
      if (nuevaFecha != null) {
        fechaSeleccionada = nuevaFecha;
        controladorFecha
          ..text = DateFormat.yMMMd().format(fechaSeleccionada)
          ..selection = TextSelection.fromPosition(TextPosition(
              offset: controladorFecha.text.length,
              affinity: TextAffinity.upstream));
        
        //controladorFecha.text = DateFormat.yMMMd().format(fechaSeleccionada);
      }
    };
  }
  
  Gasto recuperarGastoActual(){ // Función para recupera el gasto en pantalla en caso de crear una etiqueta desde aquí.
    return Gasto(
      id: (widget.gasto?.id)??0, 
      vehiculo: int.parse(idVehiculoString),
      etiqueta: obtenerIdEtiqueta(),
      mecanico: controladorMecanico.text.trim(),
      lugar: controladorLugar.text,
      costo: double.tryParse(controladorCosto.text)??0,
      fecha: DateTime.fromMillisecondsSinceEpoch(int.parse(fechaSeleccionada.millisecondsSinceEpoch.toString())).toIso8601String(),
    );
  }
  int obtenerIdEtiqueta(){ // En caso de que el gasto sea 'Sin etiqueta', no perder el valor al recuperar el gasto.
    if ((idEtiquetaSeleccionadaOriginal != null) && idEtiquetaSeleccionadaOriginal == idSinEtiqueta) return idSinEtiqueta;
    return int.parse(controladorEtiqueta.text);
  }

  @override
  void dispose() {
    controladorVehiculo.dispose();
    controladorEtiqueta.dispose();
    controladorMecanico.dispose();
    controladorLugar.dispose();
    controladorCosto.dispose();
    controladorFecha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();
    var pressedFecha = funcionAlPresionarFecha();
    idEtiquetaSeleccionadaOriginal??= int.tryParse(controladorEtiqueta.text);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        leading: IconButton( // Botón Volver.
          onPressed: () {
            if (!esEditarGasto) {
              context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
              return;
            }
            context.read<VehiculoBloc>().add(ClickeadoregresarAConsultarGastos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisGastos),
      body: FutureBuilder<String>(
        future: Vehiculos().obtenerNombreVehiculoDeId(int.parse(controladorVehiculo.text)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final nombreVehiculo = snapshot.data?? '';
            controladorVehiculo.text = nombreVehiculo;
            
            return FutureBuilder(
              future: widget.listaMecanicoPorEtiqueta, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final listaMecanicoPorEtiqueta = snapshot.data?? [];
                  
                  // Procedimiento para IA de obtener mecánico por etiqueta.
                  // Este procedimiento solamente se ejecuta 1 vez, y es en cuantro se carga este widget/estado.
                  int idEtiquetaConMayorOcurrencias = obtenerEtiquetaConMayorOcurrencias(listaMecanicoPorEtiqueta, widget.fueAgregadaUnaEtiquetaDesdeGasto);
                  String mecanicoConMayorOcurrenciasDeEtiqueta = obtenerMecanicoConMayorOcurrenciasDeEtiqueta(listaMecanicoPorEtiqueta, idEtiquetaConMayorOcurrencias);
                  // Solo se actualiza el mecanico si es en 'Agregar Gasto' y NO acaba de agregar una etiqueta por medio de esta Plantilla. 
                  if(!esEditarGasto && !widget.fueAgregadaUnaEtiquetaDesdeGasto) controladorMecanico.text = mecanicoConMayorOcurrenciasDeEtiqueta;
                  if(!esEditarGasto && !widget.fueAgregadaUnaEtiquetaDesdeGasto) controladorEtiqueta.text = idEtiquetaConMayorOcurrencias.toString(); 
                    
                  return SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          CuadroDeTexto(controlador: controladorVehiculo, titulo: 'Vehiculo', esSoloLectura: true,),
                          SeleccionadorEtiqueta(etiquetaSeleccionada: controladorEtiqueta, titulo: 'Etiqueta', esEditarGasto: esEditarGasto,controladorMecanico: controladorMecanico, listaMecanicoPorEtiqueta: listaMecanicoPorEtiqueta),
                          BotonCrearEtiqueta(funcionObtenerGasto: recuperarGastoActual, esEditarGasto: esEditarGasto, idVehiculo: widget.idVehiculo,),
                          CuadroDeTexto(controlador: controladorMecanico, titulo: 'Mecanico', campoRequerido: false, icono: const Icon(Icons.build),),
                          CuadroDeTexto(controlador: controladorLugar, titulo: 'Lugar', campoRequerido: false, maxCaracteres: 40, icono: const Icon(Icons.place),),
                          CuadroDeTexto(controlador: controladorCosto, titulo: 'Costo', esDouble: true, maxCaracteres: 7, icono: const Icon(Icons.attach_money), valorDebeSermayorA: 0,),
                          SeleccionadorDeFecha(controlador: controladorFecha, titulo: 'Fecha', funcionAlPresionar: pressedFecha),
                        
                          ElevatedButton( // Botón Agregar/Editar Gasto.
                            onPressed: () {
                              if (!(_formKey.currentState!.validate())) return; // Comprueba si todos los campos son válidos.
                              if (!widget.esEditarGasto) {
                                context.read<VehiculoBloc>().add(AgregadoGasto(gasto: obtenerGasto())); // Agrega Gasto.
                                return;
                              }
                              context.read<VehiculoBloc>().add(EditadoGasto(gasto: obtenerGasto())); // Edita Gasto.
                            },
                            child: Text(obtenerTexto()),
                          ),
                        ],
                      ),
                    )
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

class SeleccionadorEtiqueta extends StatefulWidget {
  const SeleccionadorEtiqueta({
    super.key,
    required this.etiquetaSeleccionada,
    required this.titulo, 
    required this.esEditarGasto, 
    required this.controladorMecanico, 
    required this.listaMecanicoPorEtiqueta,
  });

  final TextEditingController etiquetaSeleccionada;
  final String titulo;
  final bool esEditarGasto;
  final TextEditingController controladorMecanico;
  final List<Map<String, Object?>> listaMecanicoPorEtiqueta;

  @override
  State<SeleccionadorEtiqueta> createState() => _SeleccionadorEtiquetaState();
}

class _SeleccionadorEtiquetaState extends State<SeleccionadorEtiqueta>{
  
  int? get idEtiquetaSeleccionada => int.tryParse(widget.etiquetaSeleccionada.text); 
  bool esSinEtiqueta() => (widget.etiquetaSeleccionada.text == idSinEtiqueta.toString()) && widget.esEditarGasto;  
  final double anchuraDelSeleccionador = 170;
  
  int? etiquetaSeleccionadaOriginal;

  @override
  Widget build(BuildContext context)  {
    etiquetaSeleccionadaOriginal ??= int.tryParse(widget.etiquetaSeleccionada.text);
    int etiquetaSeleccionada;
    var state = context.watch<VehiculoBloc>().state;
    bool agregadaEtiquetaDesdeGasto = (state as PlantillaGasto).agregadaEtiquetaDesdeGasto;
    Future<List<Etiqueta>>? misEtiquetas = context.watch<VehiculoBloc>().misEtiquetas;

    int valorIdEtiquetaInicial(List<Etiqueta> etiquetas) {
      if(agregadaEtiquetaDesdeGasto && etiquetas.isNotEmpty) {
        agregadaEtiquetaDesdeGasto = false;
        int maxIdEtiqueta = 0;
        for (var etiqueta in etiquetas) {
          if (etiqueta.id >= maxIdEtiqueta) maxIdEtiqueta = etiqueta.id;
        }
        return maxIdEtiqueta;
      }
      if ((esSinEtiqueta()) && etiquetas.isNotEmpty) return idSinEtiqueta;
      if(idEtiquetaSeleccionada != null && idEtiquetaSeleccionada != valorNoTieneEtiquetaConMayorOcurrencias) return idEtiquetaSeleccionada!; 
      return (etiquetas.isNotEmpty? etiquetas.first.id:valorNoHayEtiquetasCreadas);
    }


    return Column(
      children: [
        TituloComponente(titulo: widget.titulo),
        SizedBox(
          width: anchuraDelSeleccionador,
          child: FutureBuilder<List<Etiqueta>>(
            future: misEtiquetas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final etiquetas = snapshot.data?? [];
                etiquetaSeleccionada = valorIdEtiquetaInicial(etiquetas);
                
                return DropdownButtonFormField(
                  validator: (value) {
                    if (value != null && value == valorNoHayEtiquetasCreadas) return 'Agregue una etiqueta';
                    
                    // En caso de no seleccionar una etiqueta y dejar la que ya esta seleccionada, se asigna el valor manualmente.
                    widget.etiquetaSeleccionada.text = value.toString();
                    return null;
                  },
                  value: etiquetaSeleccionada,
                  items: [
                    if(etiquetaSeleccionadaOriginal == idSinEtiqueta) const DropdownMenuItem(value: idSinEtiqueta, child: Text(nombreSinEtiqueta),), // Opción 'Sin etiqueta'. En caso de que esa sea la que ya tenga,
                    for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: SizedBox(width: (anchuraDelSeleccionador-30), child: Text(etiqueta.nombre, overflow: TextOverflow.ellipsis)),)
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.etiquetaSeleccionada.text = value.toString();

                      // IA para rellenar el TextField con el mecánico con más coincidencias dependiendo de la etiqueta seleccionada en el DropDownButton.
                      // Si se encuentra editando el gasto, no cambia al Mecánico.
                      //if(!widget.esEditarGasto) widget.controladorMecanico.text = obtenerMecanicoConMayorOcurrenciasDeEtiqueta(widget.listaMecanicoPorEtiqueta, value!);
                    });
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

}

class BotonCrearEtiqueta extends StatelessWidget {
  BotonCrearEtiqueta({
    super.key, 
    required this.funcionObtenerGasto, 
    required this.esEditarGasto, 
    required this.idVehiculo,
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController controladorNuevaEtiqueta = TextEditingController();
  final Function funcionObtenerGasto;
  final bool esEditarGasto;
  final int idVehiculo;

  Future<String?> cuadroDeDialogoAgregarEtiqueta(BuildContext context) {
    double alturaDelCuadroDeDialogo = 70;

    return showDialog<String>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Nueva etiqueta'),
        content: Form(
          key: _formKey,
          child: SizedBox(height: alturaDelCuadroDeDialogo, child: CuadroDeTextoEtiqueta(controlador: controladorNuevaEtiqueta, campoRequerido: true, focusTecaldo: true, icono: iconoEtiqueta,)),
        ),
        actions: [
          TextButton( // Botón Agregar Nueva Etiqueta.
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(controladorNuevaEtiqueta.text.trim());
              }
            }, 
            child: const Text('Agregar')
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return TextButton( // Botón Agregar Etiqueta.
      onPressed: () async {
        controladorNuevaEtiqueta.clear(); // Limpiar el texto del controlador.
        final nuevaEtiqueta = await cuadroDeDialogoAgregarEtiqueta(context);
        if (nuevaEtiqueta == null || nuevaEtiqueta.isEmpty) return;
        Gasto gastoSinGuardar = funcionObtenerGasto();
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(AgregadoEtiquetaDesdeGasto(nombreEtiqueta: nuevaEtiqueta, idVehiculo: idVehiculo, gasto: gastoSinGuardar, esEditarGasto: esEditarGasto));
      }, 
      child: const Text('Agregar Etiqueta'));
  }
}

class CuadroDeTextoEtiqueta extends StatelessWidget {
  const CuadroDeTextoEtiqueta({
    super.key,
    required this.controlador,
    this.titulo, 
    this.campoRequerido = true,
    this.maxCaracteres = 20, 
    this.minCaracteres,
    this.focusTecaldo = false, 
    this.icono,
  });

  final TextEditingController controlador;
  final String? titulo;
  final bool campoRequerido;
  final int maxCaracteres;
  final int? minCaracteres;
  final bool focusTecaldo;
  final Icon? icono;

  bool esNumerico(String? s) {
    if(s == null) return false;    
    return double.tryParse(s) != null;
  }
  InputDecoration obtenerDecoracion({Icon? icono}){
    if (campoRequerido) return obtenerDecoracionCampoObligatorio(hintText: 'Ej: Gasolina', icono: icono);
    return obtenerDecoracionCampoOpcional(hintText: 'Ej: Gasolina', icono: icono);
  }
  bool existeEtiqueta(List<Etiqueta> etiquetas, String etiquetaRecibida){
    for (var etiqueta in etiquetas) {
      if(etiqueta.nombre.equalsIgnoreCase(etiquetaRecibida)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@#%&/\><:,.;_~`+=' 
      "'" 
      ']'
    );
    bool esPrimerClic = true;
    Future <List<Etiqueta>>? misEtiquetas = context.watch<VehiculoBloc>().misEtiquetas;

    return FutureBuilder<List<Etiqueta>>(
      future: misEtiquetas, 
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
          return const WidgetCargando();
        } else {
          final etiquetas = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(titulo != null) TituloComponente(titulo: titulo!),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  String valorNormalizado = (value??'').trim();
                  if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
                  if(esNumerico(valorNormalizado)) return 'Campo inválido';
                  if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
                  if(minCaracteres != null && (valorNormalizado.length < minCaracteres!)) return 'Debe tener al menos $minCaracteres caracteres';
                  if (existeEtiqueta(etiquetas, valorNormalizado)) return 'Etiqueta ya existente';
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxCaracteres,
                controller: controlador,
                decoration: obtenerDecoracion(icono: icono),
                keyboardType: TextInputType.text,
                autofocus: focusTecaldo,
                onTap: () { 
                  if(!esPrimerClic) return;
                  controlador.selectAll(); // Seleccionar todo el texto.
                  esPrimerClic = !esPrimerClic;
                },
              ),
            ],
          );
        }
      },
    );
  }
}

/* --------------------------------------------------------------------------------- */

/* ----------------------------------- MIS GASTOS ----------------------------------- */
class WidgetMisGastos extends StatefulWidget {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaSeleccionadaFinal;
  final DateTime fechaSeleccionadaInicial;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;
  final int idVehiculoSeleccionado;
  final Future <List<Vehiculo>>? misVehiculos;
  final String filtroMecanico;

   const WidgetMisGastos({
    super.key, 
    this.misGastos, 
    required this.fechaSeleccionadaFinal, 
    required this.fechaSeleccionadaInicial, 
    required this.misEtiquetas, 
    required this.idEtiquetaSeleccionada,
    required this.idVehiculoSeleccionado,
    required this.misVehiculos, 
    required this.filtroMecanico,
  }); 

  @override
  State<WidgetMisGastos> createState() => _WidgetMisGastosState();
}

class _WidgetMisGastosState extends State<WidgetMisGastos> {
  TextEditingController controladorMecanico = TextEditingController();
  bool filtrosVisibles = true;
  RepresentacionGastos representacionGasto = RepresentacionGastos.lista;

  // Métodos
  String normalizarNumeroA2DigitosFecha(int numeroRecibido){
    String numeroNormalizado = '';
    if (numeroRecibido.toString().length == 1) numeroNormalizado += '0';
    return numeroNormalizado += numeroRecibido.toString();
  }
  bool enIntervaloFecha(String fecha) {
    DateTime fechaFinalNormalizada = DateTime.parse('${widget.fechaSeleccionadaFinal.year}-${normalizarNumeroA2DigitosFecha(widget.fechaSeleccionadaFinal.month)}-${normalizarNumeroA2DigitosFecha(widget.fechaSeleccionadaFinal.day)} 23:59:59.990');
    return ((DateTime.parse(fecha)).isAfter(widget.fechaSeleccionadaInicial) && ((DateTime.parse(fecha)).isBefore(fechaFinalNormalizada)));
  }

  List<Gasto> filtrarListaGastos(List<Gasto> gastos) {
    List<Gasto> gastosRecibidos = gastos.copiar();
    if (representacionGasto != RepresentacionGastos.lista) return gastosRecibidos; // No filtrar si no es la representación de la Lista.
    
    if (widget.idEtiquetaSeleccionada != valorOpcionTodas) {
      gastosRecibidos.removeWhere((element) => (element.etiqueta != widget.idEtiquetaSeleccionada));  // Filtrar por etiqueta  
    }
    String filtroMecanico = controladorMecanico.text.trim();
    if (filtroMecanico.isNotEmpty) { // Filtrar por mecánico
      gastosRecibidos.removeWhere((element) {
        String mecanicoRecibido = element.mecanico;
        mecanicoRecibido = mecanicoRecibido.isEmpty?valorSinMecanico:mecanicoRecibido; // Asignar valor 'Sin mecánico' en caso de no tener asignado uno.
        return (!mecanicoRecibido.containsIgnoreCase(filtroMecanico) || (mecanicoRecibido.isEmpty));
      }); 
    }
    return gastosRecibidos;
  }
  Future<List<Gasto>>? obtenerListaGastos() async {
    List<Gasto> lista = await widget.misGastos??[];
    lista = filtrarListaGastos(lista);
    return Future(() => lista);
  }

  double sumarGastos(List<Gasto> gastos) {
    double gastosAcumulados = 0.0;
    if (gastos.isEmpty) return gastosAcumulados;
    for (var gasto in gastos) {
      gastosAcumulados+= gasto.costo;
    }
    return gastosAcumulados;
  }

  void escuchador(){// Event listener del controladorMecanico
    context.read<VehiculoBloc>().add(FiltradoGastosPorMecanico(mecanico: controladorMecanico.text));
    // Le quité el Set State, puesto que cada vez que con cada estado emitido se recarga la pantalla completa.
  }
  
  cambiarRepresentacionDeGastos(){
    return (valor) {
      setState(() {
        representacionGasto = valor.first;
      });
    };
  }

  @override
  void dispose() {
    controladorMecanico.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    controladorMecanico.addListener(escuchador);
    filtrosVisibles = context.watch<VehiculoBloc>().filtrosGastosVisibles;
    controladorMecanico.text = widget.filtroMecanico;

    Future<List<Gasto>>? misGastosGlobales = context.watch<VehiculoBloc>().misGastosGlobales; // Lista con los gastos hitoricos de un vehiculo.
    representacionGasto = context.watch<VehiculoBloc>().representacionGasto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        leading: IconButton( // Botón Volver a Vehículos.
          onPressed: () {
            //context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
            context.read<VehiculoBloc>().add(ClickeadoRegresarDesdeGastos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
        actions: [
          IconButton( // Botón Consultar Gastos Archivados.
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoConsultarGastosArchivados());
            },
            icon: const Icon(Icons.folder),
          ),
          IconButton( // Botón 'Toggle' visibilidad de Filtros.
            onPressed: () {
              filtrosVisibles = !filtrosVisibles;
              context.read<VehiculoBloc>().add((VisibilitadoFiltros(estanVisibles: filtrosVisibles)));
            },
            icon: !filtrosVisibles?const Icon(Icons.filter_alt_outlined):const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisGastos),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (filtrosVisibles) Filtros(widget: widget, controladorMecanico: controladorMecanico, representacionGasto: representacionGasto), // Filtros de MisGastos.
          Expanded(
            child: switch (representacionGasto) {
              RepresentacionGastos.lista => ListaGastos(misGastos: obtenerListaGastos()),
              RepresentacionGastos.grafica => Graficas(misGastos: obtenerListaGastos(), misGastosGlobales: misGastosGlobales,),
              RepresentacionGastos.reporte => Reporte(misGastosGlobales: misGastosGlobales),
            }
          ),
          if (representacionGasto == RepresentacionGastos.lista) TotalGastos(listaGastos: obtenerListaGastos()), // Muestra el total de gastos '$'
          BotonRepresentacionGastos(representacionGasto: representacionGasto, cambiarRepresentacionDeGastos: cambiarRepresentacionDeGastos,)
        ],
      ),
    );
  }
}

class BotonRepresentacionGastos extends StatefulWidget {
  const BotonRepresentacionGastos({
    super.key,
    required this.representacionGasto, 
    required this.cambiarRepresentacionDeGastos,
  });

  final RepresentacionGastos representacionGasto;
  final Function cambiarRepresentacionDeGastos;

  @override
  State<BotonRepresentacionGastos> createState() => _BotonRepresentacionGastosState();
}

class _BotonRepresentacionGastosState extends State<BotonRepresentacionGastos> {
  RepresentacionGastos? representacionGasto;

  @override
  Widget build(BuildContext context) {
    representacionGasto??= widget.representacionGasto;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 40,
        width: 300,
        child: SegmentedButton(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: RepresentacionGastos.lista, label: Text('Lista'), icon: Icon(Icons.list)),
            ButtonSegment(value: RepresentacionGastos.grafica, label: Text('Grafica'), icon: Icon(Icons.auto_graph_sharp)),
            ButtonSegment(value: RepresentacionGastos.reporte, label: Text('Reporte'), icon: Icon(Icons.calendar_today)),
          ], 
          selected: {widget.representacionGasto},
          //onSelectionChanged: widget.cambiarRepresentacionDeGastos(),
          onSelectionChanged: (valor) {
            context.read<VehiculoBloc>().add(CambiadaRepresentacionGastos(representacionGastos: valor.first));
          },
        ),
      ),
    );
  }
}

class TotalGastos extends StatelessWidget {
  const TotalGastos({super.key, required this.listaGastos});

  final Future<List<Gasto>>? listaGastos;

  double sumarGastos(List<Gasto> gastos) {
    double gastosAcumulados = 0.0;
    if (gastos.isEmpty) return gastosAcumulados;
    for (var gasto in gastos) {
      gastosAcumulados+= gasto.costo;
    }
    return gastosAcumulados;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: listaGastos, 
      builder: (context, snapshot) {
        if (snapshot.hasData){
          final gastos = snapshot.data?? [];
          double gastosTotales = sumarGastos(gastos);
          
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total: \$${gastosTotales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold),),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

// Filtros
class Filtros extends StatelessWidget {
  const Filtros({
    super.key,
    required this.widget,
    required this.controladorMecanico, 
    required this.representacionGasto,
  });

  final WidgetMisGastos widget;
  final TextEditingController controladorMecanico;
  final RepresentacionGastos representacionGasto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TituloGrande(titulo: 'Filtros'),
        if (representacionGasto != RepresentacionGastos.reporte) FiltroParaRangoFechas(fechaSeleccionadaInicial: widget.fechaSeleccionadaInicial, fechaSeleccionadaFinal: widget.fechaSeleccionadaFinal),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (representacionGasto == RepresentacionGastos.lista) FiltroParaEtiqueta(misEtiquetas: widget.misEtiquetas, idEtiquetaSeleccionada: widget.idEtiquetaSeleccionada, titulo: 'Etiqueta'),
            //FiltroParaVehiculo(idVehiculoSeleccionado: widget.idVehiculoSeleccionado, titulo: 'Vehículo', misVehiculos: widget.misVehiculos),
            FiltroParaVehiculo(listaVehiculos: widget.misVehiculos, titulo: 'Vehículo', idVehiculoSeleccionado: widget.idVehiculoSeleccionado,),
          ],
        ),
        if (representacionGasto == RepresentacionGastos.lista) FiltroParaMecanico(controladorMecanico: controladorMecanico, titulo: 'Mecánico', campoRequerido: false),
      ],
    );
  }
}

// ignore: must_be_immutable
class FiltroParaRangoFechas extends StatelessWidget {
  FiltroParaRangoFechas({
    super.key, 
    required this.fechaSeleccionadaInicial,
    required this.fechaSeleccionadaFinal, 
  });

  final TextEditingController controladorFechaInicial = TextEditingController();
  final TextEditingController controladorFechaFinal = TextEditingController();
  
  DateTime fechaSeleccionadaInicial;
  DateTime fechaSeleccionadaFinal;

  VoidCallback funcionAlPresionarFechaInicial(BuildContext context){
    return () async {
      DateTime? nuevaFecha = await showDatePicker(
        context: context, 
        initialDate: fechaSeleccionadaInicial,
        firstDate: DateTime(1970), 
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly
      );
      if (nuevaFecha == null) return;
      if (!((nuevaFecha.isBefore(fechaSeleccionadaFinal) || nuevaFecha.isAtSameMomentAs(fechaSeleccionadaFinal)))) {
        // ignore: use_build_context_synchronously
        mostrarToast(context, 'Fecha Inicial debe ser menor a la Fecha Final');
        return;
      }
        fechaSeleccionadaInicial = nuevaFecha;
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(FiltradoGastosPorFecha(fechaInicial: fechaSeleccionadaInicial, fechaFinal: fechaSeleccionadaFinal));
      
    };
  }
  VoidCallback funcionAlPresionarFechaFinal(BuildContext context){
    return () async {
      DateTime? nuevaFecha = await showDatePicker(
        context: context, 
        initialDate: fechaSeleccionadaFinal,
        firstDate: DateTime(1970), 
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly
      );
      if (nuevaFecha == null) return;
      if (!((nuevaFecha.isAfter(fechaSeleccionadaInicial) || nuevaFecha.isAtSameMomentAs(fechaSeleccionadaInicial)))) {
        // ignore: use_build_context_synchronously
        mostrarToast(context, 'Fecha Final debe ser mayor a la Fecha inicial');
        return;
      }
        //Formato: 2023-01-01 00:00:00.000
        DateTime fechaNormalizada = DateTime.parse('${nuevaFecha.year}-${normalizarNumeroA2DigitosFecha(nuevaFecha.month)}-${normalizarNumeroA2DigitosFecha(nuevaFecha.day)} 23:59:59.999');        
        fechaSeleccionadaFinal = fechaNormalizada;
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(FiltradoGastosPorFecha(fechaInicial: fechaSeleccionadaInicial, fechaFinal: fechaSeleccionadaFinal));    
      
    };
  }
  
  String normalizarNumeroA2DigitosFecha(int numero){
    String numeroRecibido = '';
    if (numero.toString().length == 1) numeroRecibido += '0';
    return numeroRecibido += numero.toString();
  }

  void inicializarTextBoxesConFechas() {
    controladorFechaInicial.text = DateFormat.yMMMd().format(fechaSeleccionadaInicial);
    controladorFechaFinal.text = DateFormat.yMMMd().format(fechaSeleccionadaFinal);
  }

  @override
  Widget build(BuildContext context) {
    inicializarTextBoxesConFechas();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SeleccionadorDeFecha(controlador: controladorFechaInicial, titulo: 'Fecha Inicial', funcionAlPresionar: funcionAlPresionarFechaInicial(context),),
            SeleccionadorDeFecha(controlador: controladorFechaFinal, titulo: 'Fecha Final', funcionAlPresionar: funcionAlPresionarFechaFinal(context),),            
          ],
        ),
        
      ],
    );
  }
}

class FiltroParaEtiqueta extends StatelessWidget {
  const FiltroParaEtiqueta({
    super.key, 
    required this.misEtiquetas, 
    required this.idEtiquetaSeleccionada, 
    required this.titulo
  });
  
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;
  final String titulo;
  final double anchura = 160;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TituloComponente(titulo: titulo),
        SizedBox(
          width: anchura,
          child: FutureBuilder<List<Etiqueta>>(
            future: misEtiquetas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final etiquetas = snapshot.data?? [];
                
                return DropdownButtonFormField(
                  validator: (value) {
                    if ((value != null && (value == idSinEtiqueta || value == valorNoHayEtiquetasCreadas)) || value == valorOpcionTodas) return 'Valor requerido';
                    return null;
                  },
                  value: idEtiquetaSeleccionada,
                  items: [
                    const DropdownMenuItem(value: valorOpcionTodas, child: Text('Todas')),
                    const DropdownMenuItem(value: idSinEtiqueta, child: Text(nombreSinEtiqueta),),
                    for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: SizedBox(width: (anchura-30), child: Text(etiqueta.nombre, overflow: TextOverflow.ellipsis,)),)
                  ],
                  onChanged: (value) {
                    context.read<VehiculoBloc>().add(FiltradoGastosPorEtiqueta(idEtiqueta: value!));
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class FiltroParaMecanico extends StatelessWidget {
  const FiltroParaMecanico({super.key, required this.controladorMecanico, required this.titulo, required this.campoRequerido});

  final TextEditingController controladorMecanico;
  final String titulo;
  final bool campoRequerido;

  @override
  Widget build(BuildContext context) {
    return CuadroDeTexto(controlador: controladorMecanico, titulo: titulo, campoRequerido: false, icono: const Icon(Icons.build), validarCampo: false,);
  }
}

class FiltroParaVehiculo extends StatefulWidget {
  const FiltroParaVehiculo({super.key, required this.listaVehiculos, required this.idVehiculoSeleccionado, required this.titulo});

  final Future<List<Vehiculo>>? listaVehiculos;
  final int idVehiculoSeleccionado;
  final String titulo;

  @override
  State<FiltroParaVehiculo> createState() => _FiltroParaVehiculoState();
}

class _FiltroParaVehiculoState extends State<FiltroParaVehiculo> {
  final TextEditingController textEditingController = TextEditingController(); // Controlador propio de este widget. NO ALTERAR.
  final Vehiculo opcionTodosLosVehiculos = const Vehiculo(id: valorOpcionTodas, matricula: "Todos", marca: "", modelo: "", color: "", ano: 2000); // Opción por omisión 'Todos'
  Vehiculo? vehiculoSeleccionado;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TituloComponente(titulo: widget.titulo),
        ),
        FutureBuilder<List<Vehiculo>>(
          future: widget.listaVehiculos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const WidgetCargando();
            } else{
              final vehiculos = snapshot.data?? [];
              List<Vehiculo> listaVehiculos = vehiculos.copiar();
              listaVehiculos.insert(0,opcionTodosLosVehiculos);

              /* ------------------------------ METODO PARA EVITAR DUPLICADOS ------------------------------ */
              // Originalmente se usa la 'listaVehiculos'.
              // Esto es ineficiente, debido a que desde SQL la listaVehiculos no debe tener duplicados. 
              // Una vez que este seguro que nunca llegara un duplicado, eliminar esta seccion.
               List<Vehiculo> listaSinDuplicados = listaVehiculos.toSet().toList().copiar();
              /* -------------------------------------------------------------.------------------------------ */

              // Reemplazar listaSinDuplicados por listaVehiculos
              vehiculoSeleccionado = listaSinDuplicados.where((element) => element.id == widget.idVehiculoSeleccionado).toList().first;

              return DropdownButtonHideUnderline(
                child: DropdownButton2<Vehiculo>(
                  isExpanded: true,
                  hint: Text(
                    'Vehiculo...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: listaSinDuplicados
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.id != valorOpcionTodas) Text(
                                  item.modelo,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ),
                                Text(
                                  item.matricula,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                
                              ],
                            ),
                          ))
                      .toList(),
                  value: vehiculoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      vehiculoSeleccionado = value;
                      //controladorVehiculo.text = vehiculoSeleccionado!.id.toString(); // Actualizar el controlador.
                      context.read<VehiculoBloc>().add(FiltradoGastosPorVehiculo(idVehiculo: value!.id));
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    width: widthDeComponente,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: alturaMaximaSearchbar,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                  dropdownSearchData: DropdownSearchData(
                    searchController: textEditingController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        right: 8,
                        left: 8,
                      ),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        controller: textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'Vehículo...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return ((item.value as Vehiculo).matricula.toString().containsIgnoreCase(searchValue) // Filtrar por matrícula.
                        || (item.value as Vehiculo).modelo.toString().containsIgnoreCase(searchValue)); // o por modelo.
                    },
                  ),
                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      textEditingController.clear();
                    }
                  },
                ),
              );
            }
          }
        ),
      ],
    );
  }
}

// Lista
class ListaGastos extends StatelessWidget {
  const ListaGastos({
    super.key,
    required this.misGastos,
  });

  final Future<List<Gasto>>? misGastos;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Gasto>>(
      future: misGastos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const WidgetCargando();
        } else{
          final gastos = snapshot.data?? []; // Recibe la lista ya filtrada desde SQL
          
          return gastos.isEmpty
            ? const Center(
              child: Text(
                'Sin gastos...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => 
                  const SizedBox(height: 12,), 
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                final gasto = gastos[index];
                return TileGasto(gasto: gasto);
              }, 
            );
          //(representacionGasto == RepresentacionGastos.lista)? ListaGastos(gastos: gastos): Graficas(misgastos: gastos,);
        }
      },
    );
    
  }
}

class TileGasto extends StatelessWidget {
  const TileGasto({
    super.key,
    required this.gasto, 
  });

  final Gasto gasto;
  
  String get obtenerMecanico => (gasto.mecanico.isNotEmpty)? gasto.mecanico:valorSinMecanico;

  @override
  Widget build(BuildContext context) {
    DateTime nuevaFecha = DateTime.parse(gasto.fecha);

    return ListTile(
      title: Text(
        gasto.nombreEtiqueta??'',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat.yMMMd().format(nuevaFecha)),
          Text(gasto.nombreVehiculo??''),
          Text(obtenerMecanico),
          Text('\$${gasto.costo}'),
        ],
      ),
      trailing: BotonesTileGasto(gasto: gasto),
      onTap: null,
    );
  }
}

class BotonesTileGasto extends StatelessWidget {
  const BotonesTileGasto({
    super.key,
    required this.gasto,
  });

  final Gasto gasto;

  Function eliminarGasto(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadoGasto(id: gasto.id));
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: dialogoAlerta(context: context, texto: '¿Seguro de eliminar este gasto?', funcionAlProceder: eliminarGasto(context), titulo: 'Eliminar'), 
            icon: const Icon(Icons.delete, color: colorIcono)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarGasto(gasto: gasto));
            }, 
            icon: const Icon(Icons.edit, color: colorIcono)
          ),
        ],
      ),
    );
  }
}

// Grafica
class Graficas extends StatelessWidget {
  const Graficas({super.key, required this.misGastos, required this.misGastosGlobales});

  final double radio = 235;
  final Future<List<Gasto>>? misGastos;
  final Future<List<Gasto>>? misGastosGlobales;
  

  @override
  Widget build(BuildContext context) {
    final List<Color> colores = [
      Colors.blueGrey, Colors.cyan, Colors.amber, Colors.red, 
      Colors.purple, Colors.grey, Colors.green, Colors.orange, Colors.brown, Colors.lightBlue,
    ];
    
    //Para tener solo la gráfica de etiquetas
    /*return GraficaCircular(
      totalGastos: totalGastos, 
      radio: radio, 
      pieCharts: pieCharts, 
      gastoPorElemento: gastoPorEtiqueta, 
      colorPorElemento: colorPorEtiqueta,
      titulo: 'Relación por etiqueta'
    );*/

    // Para tener multiples graficas
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            GraficaRelacionEtiquetas(misGastos: misGastos, colores: colores, radio: radio),
            GraficaRelacionVehiculos(misGastosGlobales: misGastosGlobales, colores: colores, radio: radio),
          ],
        ),
      ),
    );
  }

  
}

class GraficaRelacionEtiquetas extends StatelessWidget {
  const GraficaRelacionEtiquetas({
    super.key,
    required this.misGastos,
    required this.colores,
    required this.radio,
  });

  final Future<List<Gasto>>? misGastos;
  final List<Color> colores;
  final double radio;

  @override
  Widget build(BuildContext context) {
    void llenarListasEtiquetas(List<Gasto> misGastos, Map<String, double> gastoPorEtiqueta, Map<String, Color> colorPorEtiqueta, List<Color> colores) {
      int idColor = 0;
      for (var gasto in misGastos) {
        gastoPorEtiqueta[gasto.nombreEtiqueta!] = (gastoPorEtiqueta[gasto.nombreEtiqueta!]??0) + gasto.costo;
        if (!colorPorEtiqueta.containsKey(gasto.nombreEtiqueta)) {
          colorPorEtiqueta[gasto.nombreEtiqueta!] = colores[idColor];
          idColor++; if (idColor > colores.length-1) idColor = 0;
        }
      }
    }    
    void llenarPieCharts(Map<String, double> gastoPorEtiqueta, List<PieChartSectionData> pieCharts, Map<String, Color> colorPorEtiqueta, double totalGastosEtiquetas) {
      gastoPorEtiqueta.forEach((key, value) {
        pieCharts.add(
          PieChartSectionData(
            value: value, 
            color: colorPorEtiqueta[key],
            showTitle: true,
            title: '${((value*100)/totalGastosEtiquetas).toStringAsFixed(1)}%',
          )
        );
        //totalGastosEtiquetas += value;
      });
  }
    
    return FutureBuilder<List<Gasto>>( // Gráfica para Etiquetas
        future: misGastos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final gastos = snapshot.data?? [];

            int filtroIdVehiculo = context.watch<VehiculoBloc>().filtroGastosIdVehiculo;
            if (filtroIdVehiculo != valorOpcionTodas) gastos.removeWhere((element) => (element.vehiculo != filtroIdVehiculo));  // Filtrar por vehículo  
    
            /* ------------------------------------------------------------------------------------------------------------------ */
            // Para Etiquetas
            Map<String, Color> colorPorEtiqueta = {};
            Map<String, double> gastoPorEtiqueta = {};
            llenarListasEtiquetas(gastos, gastoPorEtiqueta, colorPorEtiqueta, colores);
    
            double totalGastosEtiquetas = 0;
            List<PieChartSectionData> pieCharts = [];
            gastoPorEtiqueta.forEach((key, value) {totalGastosEtiquetas += value;}); // Obtener total de gastos.
            llenarPieCharts(gastoPorEtiqueta, pieCharts, colorPorEtiqueta, totalGastosEtiquetas);
    
            // Reordenar mapa por cantidad de gasto
            gastoPorEtiqueta = Map.fromEntries(gastoPorEtiqueta.entries.toList()..sort((e1,e2) => e2.value.compareTo(e1.value)));
            /* ------------------------------------------------------------------------------------------------------------------ */
            const String titulo = 'Relación por etiqueta';

            return gastos.isEmpty
              ? 
              GraficaCircularVacia(totalGastos: totalGastosEtiquetas, radio: radio, titulo: titulo,)
              :
              GraficaCircular(
                totalGastos: totalGastosEtiquetas, 
                radio: radio, 
                pieCharts: pieCharts, 
                gastoPorElemento: gastoPorEtiqueta, 
                colorPorElemento: colorPorEtiqueta,
                titulo: titulo
              );
          }
        },
      );
  }
}

class GraficaRelacionVehiculos extends StatelessWidget {
  const GraficaRelacionVehiculos({
    super.key,
    required this.misGastosGlobales,
    required this.colores,
    required this.radio,
  });

  final Future<List<Gasto>>? misGastosGlobales;
  final List<Color> colores;
  final double radio;

  @override
  Widget build(BuildContext context) {
    int filtroIdVehiculo = context.watch<VehiculoBloc>().filtroGastosIdVehiculo;
    int idColor = 0;
    String? vehiculoSeleccionado;
    const int idColorPrincipal = 1;
    const int idColorSecundario = 0;
    
    int obtenerIDColor(int idVehiculo){
      if (filtroIdVehiculo == valorOpcionTodas) return idColor;
      if (idVehiculo == filtroIdVehiculo) return idColorPrincipal;
      return idColorSecundario;
    }
    void llenarListasVehiculos(List<Gasto> misGastos, Map<String, double> gastoPorVehiculo, Map<String, Color> colorPorVehiculo, List<Color> colores) {        
      if (filtroIdVehiculo == valorOpcionTodas){
        for (var gasto in misGastos) {
          gastoPorVehiculo[gasto.nombreVehiculo!] = (gastoPorVehiculo[gasto.nombreVehiculo!]??0) + gasto.costo;
          if (vehiculoSeleccionado == null && gasto.vehiculo == filtroIdVehiculo) vehiculoSeleccionado = gasto.nombreVehiculo; // Establecer nombreVehiculo seleccionado en filtro
          if (!colorPorVehiculo.containsKey(gasto.nombreVehiculo)) {
            colorPorVehiculo[gasto.nombreVehiculo!] = colores[obtenerIDColor(gasto.vehiculo)];
            idColor++; if (idColor > colores.length-1) idColor = 0;
          }
        }
        return;
      }
      
      const String otrosVehiculos = 'Otros';
      for (var gasto in misGastos) {
        if (vehiculoSeleccionado == null && gasto.vehiculo == filtroIdVehiculo) { // Establecer nombreVehiculo seleccionado en filtro
          vehiculoSeleccionado = gasto.nombreVehiculo;
        } 
        if (gasto.nombreVehiculo != vehiculoSeleccionado) {
           gastoPorVehiculo[otrosVehiculos] = (gastoPorVehiculo[otrosVehiculos]??0) + gasto.costo;
           continue;
        }
        if (vehiculoSeleccionado != null) gastoPorVehiculo[vehiculoSeleccionado!] = (gastoPorVehiculo[vehiculoSeleccionado]??0) +gasto.costo;
      }
      if (vehiculoSeleccionado == null) {
        vehiculoSeleccionado = mensajeSinRelacion;
        gastoPorVehiculo[vehiculoSeleccionado!] = 0.0;
      }
      colorPorVehiculo[vehiculoSeleccionado!] = colores[idColorPrincipal];
      colorPorVehiculo[otrosVehiculos] = colores[idColorSecundario];
    }
    void llenarPieCharts(Map<String, double> gastoPorVehiculo, List<PieChartSectionData> pieChartsVehiculos, Map<String, Color> colorPorVehiculo, double totalGastosVehiculos) {
      gastoPorVehiculo.forEach((key, value) {
        pieChartsVehiculos.add(
          PieChartSectionData(
            value: value, 
            color: colorPorVehiculo[key],
            showTitle: true,
            title: '${((value*100)/totalGastosVehiculos).toStringAsFixed(1)}%',
          )
        );
        //totalGastosVehiculos += value;
      });
    }

    return FutureBuilder( // Gráfica para vehículos
      future: misGastosGlobales, 
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final gastosRecibidos = snapshot.data?? [];

            List<Gasto> misGastosGlobales = gastosRecibidos.toList().copiar();

            DateTime fechaInicial = context.watch<VehiculoBloc>().filtroGastosFechaInicial;
            DateTime fechaFinal = context.watch<VehiculoBloc>().filtroGastosFechaFinal;
            misGastosGlobales.removeWhere((element) => (DateTime.parse(element.fecha).isBefore(fechaInicial) 
              ||   DateTime.parse(element.fecha).isAfter(fechaFinal)));  // Filtrar por Fecha  
    
            /* ------------------------------------------------------------------------------------------------------------------ */
            // Para Vehiculos
            Map<String, Color> colorPorVehiculo = {};
            Map<String, double> gastoPorVehiculo = {};
            llenarListasVehiculos(misGastosGlobales, gastoPorVehiculo, colorPorVehiculo, colores);
    
            double totalGastosVehiculos = 0;
            List<PieChartSectionData> pieChartsVehiculos = [];
            gastoPorVehiculo.forEach((key, value) {totalGastosVehiculos += value;}); // Obtener total de gastos.
            llenarPieCharts(gastoPorVehiculo, pieChartsVehiculos, colorPorVehiculo, totalGastosVehiculos);
    
            // Reordenar mapa por cantidad de gasto
            gastoPorVehiculo = Map.fromEntries(gastoPorVehiculo.entries.toList()..sort((e1,e2) => e2.value.compareTo(e1.value)));

            // En caso de que no tenga relación en la gráfica (que no tenga gastos) crear una relación de 'Sin datos'.
            Map<String, double>? gastosVehiculoSeleccionado;
            if (gastoPorVehiculo.entries.isNotEmpty && filtroIdVehiculo != valorOpcionTodas && vehiculoSeleccionado != null) {
              gastosVehiculoSeleccionado = {vehiculoSeleccionado!: gastoPorVehiculo[vehiculoSeleccionado]!};
            }
            if (gastosVehiculoSeleccionado == null && filtroIdVehiculo != valorOpcionTodas) {
              gastosVehiculoSeleccionado = {mensajeSinRelacion: 0.0};
              colorPorVehiculo[mensajeSinRelacion] = colores[idColorPrincipal];
            }
            
            /* ------------------------------------------------------------------------------------------------------------------ */
            const String titulo = 'Relación por vehículo';

            return misGastosGlobales.isEmpty
              ? 
              GraficaCircularVacia(totalGastos: totalGastosVehiculos, radio: radio, titulo: titulo)
              :
              GraficaCircular(
                totalGastos: totalGastosVehiculos, 
                radio: radio, 
                pieCharts: pieChartsVehiculos, 
                gastoPorElemento: gastoPorVehiculo, 
                colorPorElemento: colorPorVehiculo,
                titulo: titulo,
                simbologia: gastosVehiculoSeleccionado,
              );
            }
         
      },
    );
  }

  
}

class GraficaCircular extends StatelessWidget {
  const GraficaCircular({
    super.key,
    required this.totalGastos,
    required this.radio,
    required this.pieCharts,
    required this.gastoPorElemento,
    required this.colorPorElemento, 
    required this.titulo, 
    this.simbologia,
  });

  final double totalGastos;
  final double radio;
  final List<PieChartSectionData> pieCharts;
  final Map<String, double> gastoPorElemento;
  final Map<String, Color> colorPorElemento;
  final String titulo;
  final Map<String, double>? simbologia;

  Map<String, double> obtenerSimbologia(){
    if (simbologia != null) return simbologia!;
    return gastoPorElemento;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 280), child: Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)), // Titulo de la Gráfica
            
            Column( // Datos en el centro
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                Text('\$ ${totalGastos.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18),),
              ],
            ),
            // Pie chart / Gráfica
            SizedBox(
              width: radio,
              height: radio,
              child: PieChart(
                swapAnimationDuration: const Duration(milliseconds: 750),
                swapAnimationCurve: Curves.easeInOutQuint,
                PieChartData(
                  sections: pieCharts,
                ),
              ),
            ),
            // Simbología de elementos por colores
            Container( 
              margin: const EdgeInsets.fromLTRB(0, 340, 0, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(var elemento in obtenerSimbologia().keys) Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Indicator(
                        color: colorPorElemento[elemento]!,
                        text: '$elemento \n \$${(gastoPorElemento[elemento]??0.0).toStringAsFixed(2)}',
                        isSquare: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GraficaCircularVacia extends StatelessWidget {
  const GraficaCircularVacia({
    super.key,
    required this.totalGastos,
    required this.radio, 
    required this.titulo,
  });

  final double totalGastos;
  final double radio;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return GraficaCircular(
      totalGastos: totalGastos, 
      radio: radio, 
      pieCharts: [
        PieChartSectionData(
        value: 1, // Es un valor placebo, pero si pongo 0 no sale nada.
        color: colorReporteSinGastos,
        showTitle: true,
        title: '0%',
      )
      ], 
      gastoPorElemento:  const {mensajeSinRelacion:0}, 
      colorPorElemento: const {mensajeSinRelacion: colorReporteSinGastos},
      titulo: titulo
    );
  }
}

// Reporte
class Reporte extends StatefulWidget {
  const Reporte({super.key, required this.misGastosGlobales});
  final Future<List<Gasto>>? misGastosGlobales;

  @override
  State<Reporte> createState() => _ReporteState();
}

class _ReporteState extends State<Reporte> {
  
  TipoReporte tipoReporte = TipoReporte.year;
  int anoAMostrarReporte = 0;
  int mesAMostrarReporte = 0;

  
  final List<String> meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
  String obtenerMes(int mes) => meses.elementAt(mes-1);

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    tipoReporte = context.watch<VehiculoBloc>().tipoReporte;
    anoAMostrarReporte = context.watch<VehiculoBloc>().anoAMostrarReporte;
    mesAMostrarReporte = context.watch<VehiculoBloc>().mesAMostrarReporte;

    /* ---------------------------------- TRABAJO ACTUAL ---------------------------------- */
    Map<int, Map<int, Map<int, double>>> reporteHistorico;
    
    Map<int, Map<int, Map<int, double>>> generarReporte(List<Gasto> misGastosGlobales) {
      Map<int, double> gastosPorDia = {}; // Relacion (temporal) gastos por dia
      Map<int, Map<int,double>> diasPorMes = {}; // Relacion (temporal) dias por mes
      Map<int,Map<int, Map<int,double>>> mesesPorAno = {}; // Relacion meses por año

      int mesActual = 0;
      int anoActual = 0;
      for (var gasto in misGastosGlobales) { 
        var fechaDateTime = DateTime.parse(gasto.fecha);
        var year = fechaDateTime.year;
        var mes = fechaDateTime.month;
        var dia = fechaDateTime.day;
      
        // Limpiar mapas al cambio de mes y/o año
        if (mesActual != mes) {
          gastosPorDia.clear();
          mesActual = mes;
        }
        if (anoActual != year) {
          gastosPorDia.clear(); // Por si cambia de año, pero no de mes.
          diasPorMes.clear();
          anoActual = year;
        }
        
        gastosPorDia[dia] = (gastosPorDia[dia]??0) + gasto.costo;
        diasPorMes[mes] = Map.from(gastosPorDia);
        mesesPorAno[year] = Map.from(diasPorMes); // Reporte 
      }
      return Map.from(mesesPorAno);
    }

    Map<int, Map<int, Map<int, double>>> normalizarTodosLosMesesAAno(Map<int, Map<int, Map<int, double>>> reporteRecibido, int ano) {
      Map<int, Map<int, Map<int, double>>> reporteNormalizado = Map.from(reporteRecibido);
      for (var mes = 1; mes <= 12; mes++) {
        if (DateTime.now().year == ano && (mes > DateTime.now().month)) break;
        if (reporteNormalizado[ano]?[mes] == null) reporteNormalizado[ano]?[mes] = {1:0}; // En caso de que no existan registros del mes, se agrega por omision el dia 1 con gasto 0.
      }
      reporteNormalizado[ano] = Map.fromEntries(
        reporteNormalizado[ano]!.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))); // Reacomoda el mapa por orden del numero de mes.

      return reporteNormalizado;
    }
    Map<int, Map<int, Map<int, double>>> normalizarTodosLosDiasAMes(Map<int, Map<int, Map<int, double>>> reporteRecibido, int ano, int mes) {
      Map<int, Map<int, Map<int, double>>> reporteNormalizado = Map.from(reporteRecibido);
      final List<int> mesesCon31Dias = [1,3,5,7,8,10,12];
      for (var dia = 1; dia <= 31; dia++) {
        if (DateTime.now().year == ano && DateTime.now().month == mes &&  (dia > DateTime.now().day)) break;
        if (mes == 2 && dia == 29) break;
        if (!mesesCon31Dias.contains(mes) && dia == 31) break;
        if (reporteNormalizado[ano]?[mes]?[dia] == null) reporteNormalizado[ano]![mes]![dia] = 0.0;
      }
      //print(reporteNormalizado[ano]?[mes]!.remove(0));

      reporteNormalizado[ano]?[mes] = Map.fromEntries(
        reporteNormalizado[ano]![mes]!.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))); // Reacomoda el mapa por orden del numero de mes.

      return reporteNormalizado;
    }


    Map<int, Map<int, Map<int, double>>> llenarFechasFaltantes(Map<int, Map<int, Map<int, double>>> reporteRecibido){
      // Normalizar que un año tenga todos los meses y dias aunque no tengan gastos
      Map<int, Map<int, Map<int, double>>> reporteNormalizado = Map.from(reporteRecibido);
      for (var year in reporteNormalizado.keys) {
        reporteNormalizado = Map.from(normalizarTodosLosMesesAAno(reporteNormalizado, year));
        for (var mes in reporteNormalizado[year]!.keys) {
          reporteNormalizado = Map.from(normalizarTodosLosDiasAMes(reporteNormalizado,year, mes));
        }
      }
      return reporteNormalizado;
    }

   
    //print('---> Dias por Mes: $diasPorMes');
    //print('--> Meses por Ano: $mesesPorAno');

    //print('--> Registros del año 2022: ${mesesPorAno[2022]}');
    //print('--> Registros del mes 12 del año 2022: ${mesesPorAno[2022]?[12]}');
    //print('--> Registros del dia 31 del mes 12 del año 2022: ${mesesPorAno[2022]?[12]?[31]}');

   
    double obtenerGastosPorAno(Map<int, Map> mesesPorAno, int ano) {
      double sumatoria = 0;
      for (int mes = 1; mes <= 12; mes++) {
        for (var gasto in Map.from(mesesPorAno[ano]![mes]??{mes:0}).values) {
          sumatoria += gasto;
        }
      }
      return sumatoria;
    }
    double obtenerGastosPorMesYAno(Map<int, Map> mesesPorAno, int ano, int mes) {
      double sumatoria = 0;
      for (int dia = 1; dia <= 31; dia++) {
        double gasto = mesesPorAno[ano]![mes]![dia]??0.0;
        sumatoria += gasto;
      }
      return sumatoria;
    }
    double obtenerGastosPorDiaMesYAno(Map<int, Map> mesesPorAno, int ano, int mes, int dia) {
      double gasto = ((mesesPorAno[ano]![mes]??{mes:0.0})[dia]??0.0).toDouble();
      return gasto;
    }

    Padding obtenerTituloReporte(){
      String titulo;
      String? subtitulo;
       switch (tipoReporte) {
         case TipoReporte.year:
            titulo = 'Anual';
            break;
          case TipoReporte.month:
            titulo =  'Mensual';
            subtitulo = anoAMostrarReporte.toString();
            break;
          case TipoReporte.day:
            titulo = 'Diario';
            subtitulo = '${obtenerMes(mesAMostrarReporte)} - $anoAMostrarReporte';
            break;
         default:
            titulo = '';
            break;
       }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TituloGrande(titulo: titulo),
            if (subtitulo != null) Text(subtitulo, style: const TextStyle(fontWeight: FontWeight.w300),)
      
          ],
        ),
      );
    }

     void animacionDeSubida() {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 400),
      );
    }
    /* ------------------------------------------------------------------------------------ */

    return FutureBuilder(
      future: widget.misGastosGlobales, 
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final gastosRecibidos = snapshot.data?? [];

            // Clono la lista recibida porque al operar con ella, los cambios se reflejarian en las demas graficas que hagan referencia a la misma lista, por algun razón...
            List<Gasto> misGastos = gastosRecibidos.toList().copiar();
            
            int filtroIdVehiculo = context.watch<VehiculoBloc>().filtroGastosIdVehiculo;
            if (filtroIdVehiculo != valorOpcionTodas) misGastos.removeWhere((element) => (element.vehiculo != filtroIdVehiculo));  // Filtrar por vehículo  

            // Si no tiene gastos...
            if (misGastos.isEmpty) {
              return const Center(
                child: Text(
                  'Sin gastos...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              );
             }

            reporteHistorico = Map.from(generarReporte(misGastos));
            reporteHistorico = Map.from(llenarFechasFaltantes(reporteHistorico));

            animacionDeSubida(); // Hace que el scroll se suba en caso de que haya quedado abajo en el estado anterior.

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: obtenerTituloReporte() // Titulo del Reporte
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          // Reporte Anual
                          if (tipoReporte == TipoReporte.year) for (var year in reporteHistorico.keys) Column(
                            children: [
                              const Divider(
                                  thickness: 2,
                                ),
                              ListTile( // Mostrar gastos por años
                                  title: Text(year.toString(), style: const TextStyle( fontWeight: FontWeight.bold),),
                                  subtitle: Text(
                                    '\$ ${obtenerGastosPorAno(reporteHistorico, year).toStringAsFixed(2)}',
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 196, 248, 212),
                                    child: Icon(Icons.calendar_month, color: Colors.blueGrey,)
                                  ),
                                  trailing: const Icon(Icons.pageview_sharp),
                                  onTap: () {
                                    setState(() {
                                      tipoReporte = TipoReporte.month;
                                      anoAMostrarReporte = year;
                                    });
                                    context.read<VehiculoBloc>().add(CambiadoTipoReporte(tipoReporte: tipoReporte));
                                    context.read<VehiculoBloc>().add(CambiadoAnoAMostrarReporte(anoAMostrarReporte: anoAMostrarReporte));
                                  },
                                ),
                                const Divider(
                                  thickness: 2,
                                ),
                            ],
                          ),
                            // Reporte Mensual
                            if (tipoReporte == TipoReporte.month) for (var month in reporteHistorico[anoAMostrarReporte]!.keys) Column(
                              children: [
                                const Divider(
                                  thickness: 2,
                                ),
                                ListTile( // Mostrar gastos por meses
                                  title: Text(obtenerMes(month), style: const TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text('\$ ${obtenerGastosPorMesYAno(reporteHistorico, anoAMostrarReporte, month).toStringAsFixed(2)}',),
                                  leading: CircleAvatar(
                                    backgroundColor: (obtenerGastosPorMesYAno(reporteHistorico, anoAMostrarReporte, month) <= 0)? colorReporteSinGastos:colorReporteConGastos,
                                    child: Text(month.toString(), style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w300),),
                                  ),
                                  trailing: const Icon(Icons.pageview_sharp),
                                  onTap: () {
                                    setState(() {
                                      tipoReporte = TipoReporte.day;
                                      mesAMostrarReporte = month;
                                    });
                                    context.read<VehiculoBloc>().add(CambiadoTipoReporte(tipoReporte: tipoReporte));
                                    context.read<VehiculoBloc>().add(CambiadoMesAMostrarReporte(mesAMostrarReporte: mesAMostrarReporte));
                                  },
                                ),
                                const Divider(
                                  thickness: 2,
                                ),
                              ],
                            ),
                            // Reporte Diario
                            Wrap(
                            direction: Axis.horizontal,
                            children: 
                            [
                              if (tipoReporte == TipoReporte.day) for (var day in reporteHistorico[anoAMostrarReporte]![mesAMostrarReporte]!.keys) 
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Card(
                                  color: (obtenerGastosPorDiaMesYAno(reporteHistorico, anoAMostrarReporte, mesAMostrarReporte, day) <= 0)? colorReporteSinGastos:null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(day.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                                      Text('\$ ${obtenerGastosPorDiaMesYAno(reporteHistorico, anoAMostrarReporte, mesAMostrarReporte, day).toStringAsFixed(2)}', 
                                        style: const TextStyle(fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      },
    );
  }
}

/* ------------------------------------------------------------------------------ */



