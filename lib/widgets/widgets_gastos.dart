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
                  // Solo se actualiza el mecanico si es en 'Agregar Gasto' y NO acaba de agregar una etiqueta por medio de esta Plantilla. Y no ha escrito nada en mecánico.
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
        return etiquetas.last.id;
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

                      // Si se encuentra editando el gasto, no cambia al Mecánico.
                      if(!widget.esEditarGasto) widget.controladorMecanico.text = obtenerMecanicoConMayorOcurrenciasDeEtiqueta(widget.listaMecanicoPorEtiqueta, value!);
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
    if (widget.idEtiquetaSeleccionada != valorOpcionTodas) gastosRecibidos.removeWhere((element) => (element.etiqueta != widget.idEtiquetaSeleccionada)); // Filtrar por etiqueta  
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
  
  @override
  void dispose() {
    controladorMecanico.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controladorMecanico.addListener(escuchador);
    filtrosVisibles = context.watch<VehiculoBloc>().filtrosVisibles;
    controladorMecanico.text = widget.filtroMecanico;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        leading: IconButton( // Botón Volver a Vehículos.
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
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
        children: [
          if (filtrosVisibles) Filtros(widget: widget, controladorMecanico: controladorMecanico), // Filtros de MisGastos.
          Expanded(
            child: 
            FutureBuilder<List<Gasto>>(
              future: obtenerListaGastos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final gastos = snapshot.data?? [];
                  
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
                }
              },
            ),
          ),
          TotalGastos(listaGastos: obtenerListaGastos()), // Muestra el total de gastos '$'
        ],
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

class Filtros extends StatelessWidget {
  const Filtros({
    super.key,
    required this.widget,
    required this.controladorMecanico,
  });

  final WidgetMisGastos widget;
  final TextEditingController controladorMecanico;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        ),
        FiltroParaRangoFechas(fechaSeleccionadaInicial: widget.fechaSeleccionadaInicial, fechaSeleccionadaFinal: widget.fechaSeleccionadaFinal),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FiltroParaEtiqueta(misEtiquetas: widget.misEtiquetas, idEtiquetaSeleccionada: widget.idEtiquetaSeleccionada, titulo: 'Etiqueta'),
            //FiltroParaVehiculo(idVehiculoSeleccionado: widget.idVehiculoSeleccionado, titulo: 'Vehículo', misVehiculos: widget.misVehiculos),
            FiltroParaVehiculo(listaVehiculos: widget.misVehiculos, titulo: 'Vehículo', idVehiculoSeleccionado: widget.idVehiculoSeleccionado,),
          ],
        ),
        FiltroParaMecanico(controladorMecanico: controladorMecanico, titulo: 'Mecánico', campoRequerido: false),
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
      if (nuevaFecha != null && (nuevaFecha.isBefore(fechaSeleccionadaFinal) || nuevaFecha.isAtSameMomentAs(fechaSeleccionadaFinal))) {
        fechaSeleccionadaInicial = nuevaFecha;
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(FiltradoGastosPorFecha(fechaInicial: fechaSeleccionadaInicial, fechaFinal: fechaSeleccionadaFinal));
      }
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
      if (nuevaFecha != null  && (nuevaFecha.isAfter(fechaSeleccionadaInicial) || nuevaFecha.isAtSameMomentAs(fechaSeleccionadaInicial))) {
        //Formato: 2023-01-01 00:00:00.000
        DateTime fechaNormalizada = DateTime.parse('${nuevaFecha.year}-${normalizarNumeroA2DigitosFecha(nuevaFecha.month)}-${normalizarNumeroA2DigitosFecha(nuevaFecha.day)} 23:59:59.999');        
        fechaSeleccionadaFinal = fechaNormalizada;
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(FiltradoGastosPorFecha(fechaInicial: fechaSeleccionadaInicial, fechaFinal: fechaSeleccionadaFinal));    
      }
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

/*class FiltroParaVehiculo extends StatelessWidget{
  const FiltroParaVehiculo({
    super.key,
    required this.idVehiculoSeleccionado,
    required this.titulo, 
    required this.misVehiculos
  });

  final int idVehiculoSeleccionado;
  final String titulo;
  final Future <List<Vehiculo>>? misVehiculos;

  @override
  Widget build(BuildContext context)  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TituloComponente(titulo: titulo),
          SizedBox(
            width: 160,
            child: FutureBuilder<List<Vehiculo>>(
              future: misVehiculos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final vehiculos = snapshot.data?? [];
                  
                  return DropdownButtonFormField(
                    validator: (value) {
                      if ((value != null) && value == valorOpcionTodas) return 'Valor requerido';
                      return null;
                    },
                    value: idVehiculoSeleccionado,
                    items: [
                      const DropdownMenuItem(value: valorOpcionTodas, child: Text('Todos')),
                      for(var vehiculo in vehiculos) DropdownMenuItem(value: vehiculo.id, child: Text(vehiculo.matricula),)
                    ],
                    onChanged: (value) {
                      context.read<VehiculoBloc>().add(FiltradoGastosPorVehiculo(idVehiculo: value!));
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}*/

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

              vehiculoSeleccionado = listaVehiculos.where((element) => element.id == widget.idVehiculoSeleccionado).toList().first;

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
                  items: listaVehiculos
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.matricula,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
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
                    maxHeight: 200,
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
                          hintText: 'Matricula...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return ((item.value as Vehiculo).matricula.toString().containsIgnoreCase(searchValue)); // Filtrar por matrícula.
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

/* ------------------------------------------------------------------------------ */
