import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* ----------------------------------- GASTOS ----------------------------------- */
class WidgetPlantillaGasto extends StatefulWidget {
  final Gasto? gasto;
  final int idVehiculo;
  final Future <List<Etiqueta>>? misEtiquetas;

  const WidgetPlantillaGasto({super.key, required this.idVehiculo, this.gasto, required this.misEtiquetas});

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
  String idVehiculo = "";

  String obtenerTexto() => '${(widget.gasto == null)? 'Agregar':'Editar'} Gasto';
  void inicializarValoresDeControladores(){
    idVehiculo = (widget.gasto?.vehiculo??widget.idVehiculo.toString()).toString();
    controladorVehiculo.text = idVehiculo;
    controladorEtiqueta.text = (widget.gasto?.etiqueta??'').toString();
    controladorMecanico.text = widget.gasto?.mecanico??'';
    controladorLugar.text = widget.gasto?.lugar??'';
    controladorCosto.text = (widget.gasto?.costo??'').toString();
    DateTime fechaRecibida = DateTime.parse(widget.gasto?.fecha??fechaSeleccionada.toIso8601String());
    controladorFecha.text = DateFormat.yMMMd().format(fechaRecibida); // Esto es solo para mostrar la fecha en el TextBox
    fechaSeleccionada = fechaRecibida; // Esta es la fecha que se guardará en la BaseDeDatos
  }
  Gasto obtenerGasto(){
    return Gasto(
      id: (widget.gasto?.id)??0, 
      vehiculo: int.parse(idVehiculo),
      etiqueta: int.parse(controladorEtiqueta.text),
      mecanico: controladorMecanico.text,
      lugar: controladorLugar.text,
      costo: double.parse(controladorCosto.text),
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

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();
    var pressedFecha = funcionAlPresionarFecha();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.gasto == null) {
                context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
                return;
              }
              context.read<VehiculoBloc>().add(ClickeadoregresarAConsultarGastos());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: Vehiculos().obtenerNombreVehiculoDeId(int.parse(controladorVehiculo.text)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final nombreVehiculo = snapshot.data?? '';
            controladorVehiculo.text = nombreVehiculo;
            
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CuadroDeTexto(controlador: controladorVehiculo, titulo: 'Vehiculo', esSoloLectura: true,),
                  SeleccionadorEtiqueta(etiquetaSeleccionada: controladorEtiqueta, titulo: 'Etiqueta', misEtiquetas: widget.misEtiquetas, esEditarGasto: (widget.gasto != null),),
                  CuadroDeTexto(controlador: controladorMecanico, titulo: 'Mecanico', campoRequerido: false,),
                  CuadroDeTexto(controlador: controladorLugar, titulo: 'Lugar', campoRequerido: false, maxCaracteres: 40,),
                  CuadroDeTexto(controlador: controladorCosto, titulo: 'Costo', esDouble: true, maxCaracteres: 10,),
                  SeleccionadorDeFecha(controlador: controladorFecha, titulo: 'Fecha', funcionAlPresionar: pressedFecha),
                
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.gasto == null) {
                          context.read<VehiculoBloc>().add(AgregadoGasto(gasto: obtenerGasto()));
                          return;
                        }
                        context.read<VehiculoBloc>().add(EditadoGasto(gasto: obtenerGasto()));
                      }
                    },
                    child: Text(obtenerTexto()),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class SeleccionadorEtiqueta extends StatefulWidget {
  SeleccionadorEtiqueta({
    super.key,
    required this.etiquetaSeleccionada,
    required this.titulo, 
    required this.misEtiquetas,
    this.esEditarGasto = false,
  });

  TextEditingController etiquetaSeleccionada;
  final String titulo;
  final Future <List<Etiqueta>>? misEtiquetas;
  final bool esEditarGasto;

  @override
  State<SeleccionadorEtiqueta> createState() => _SeleccionadorEtiquetaState();
}

class _SeleccionadorEtiquetaState extends State<SeleccionadorEtiqueta>{
  
  int? obtenerIdEtiquetaSeleccionada() {
    int? idEtiqueta = int.tryParse(widget.etiquetaSeleccionada.text);
    idEtiqueta = ((idEtiqueta != null) && (idEtiqueta == valorEtiquetaNula))?null:idEtiqueta;
    return idEtiqueta;
  }

  @override
  Widget build(BuildContext context)  {
    int? idEtiquetaSeleccionada = obtenerIdEtiquetaSeleccionada();
    
    bool esNulaEtiqueta() => idEtiquetaSeleccionada == null && widget.esEditarGasto;
    int valorIdEtiquetaInicial(List<Etiqueta> etiquetas) {
      if ((esNulaEtiqueta()) && etiquetas.isNotEmpty) return valorEtiquetaNula;
      return (idEtiquetaSeleccionada != null)?idEtiquetaSeleccionada:(etiquetas.isNotEmpty? etiquetas.first.id:valorNoHayEtiquetasCreadas);
    }
    String obtenerEtiquetaSeleccionada() => (idEtiquetaSeleccionada == null)?'':idEtiquetaSeleccionada.toString();
    
    return Column(
      children: [
        Text(widget.titulo),
        SizedBox(
          width: 160,
          child: FutureBuilder<List<Etiqueta>>(
            future: widget.misEtiquetas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final etiquetas = snapshot.data?? [];
                
                return DropdownButtonFormField(
                  validator: (value) {
                    if (value != null && value == valorNoHayEtiquetasCreadas) return 'Valor requerido';
                    
                    // En caso de no seleccionar una etiqueta y dejar la que ya esta seleccionada, se asigna el valor manualmente.
                    if (obtenerEtiquetaSeleccionada().isEmpty) widget.etiquetaSeleccionada.text = value.toString();
                    return null;
                  },
                  value: valorIdEtiquetaInicial(etiquetas),
                  items: [
                    if(esNulaEtiqueta()) const DropdownMenuItem(value: valorEtiquetaNula, child: Text(nombreEtiquetaNula),),
                    for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: Text(etiqueta.nombre),)
                  ],
                  onChanged: (value) {
                     setState(() {
                      widget.etiquetaSeleccionada.text = value.toString();
                    });
                  },
                );
              }
            },
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoAdministrarEtiquetas());
          }, 
          child: const Text('Administrar Etiquetas')
        ),
      ],
    );
  }
}

class WidgetMisGastos extends StatefulWidget {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaSeleccionadaFinal;
  final DateTime fechaSeleccionadaInicial;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;

   const WidgetMisGastos({
    super.key, 
    this.misGastos, 
    required this.fechaSeleccionadaFinal, 
    required this.fechaSeleccionadaInicial, 
    required this.misEtiquetas, 
    required this.idEtiquetaSeleccionada
  }); 

  @override
  State<WidgetMisGastos> createState() => _WidgetMisGastosState();
}

class _WidgetMisGastosState extends State<WidgetMisGastos> {
  TextEditingController controladorMecanico = TextEditingController();

  String normalizarNumeroA2DigitosFecha(int numeroRecibido){
    String numeroNormalizado = '';
    if (numeroRecibido.toString().length == 1) numeroNormalizado += '0';
    return numeroNormalizado += numeroRecibido.toString();
  }
  bool enIntervaloFecha(String fecha) {
    DateTime fechaFinalNormalizada = DateTime.parse('${widget.fechaSeleccionadaFinal.year}-${normalizarNumeroA2DigitosFecha(widget.fechaSeleccionadaFinal.month)}-${normalizarNumeroA2DigitosFecha(widget.fechaSeleccionadaFinal.day)} 23:59:59.999');
    return ((DateTime.parse(fecha)).isAfter(widget.fechaSeleccionadaInicial) && ((DateTime.parse(fecha)).isBefore(fechaFinalNormalizada)));
  }

  List<Gasto> filtrarListaGastos(List<Gasto> gastos) {
    List<Gasto> gastosRecibidos = gastos.copiar();
    if (widget.idEtiquetaSeleccionada != valorEtiquetaTodas) gastosRecibidos.removeWhere((element) => (element.etiqueta != widget.idEtiquetaSeleccionada)); // Filtrar por etiqueta    
    String filtroMecanico = controladorMecanico.text.trim();
    if (filtroMecanico.isNotEmpty) gastosRecibidos.removeWhere((element) => (!element.mecanico.containsIgnoreCase(filtroMecanico) || (element.mecanico.isEmpty))); // Filtrar por mecánico
    return gastosRecibidos;
  }
  Future<List<Gasto>>? obtenerListaGastos() async {
    List<Gasto> lista = await widget.misGastos??[];
    lista = filtrarListaGastos(lista);
    return Future(() => lista);
  }

  void escuchador(){
    //print(controlador.text);
    setState(() {
      //reglas = establecerReglas();
    });
  }

  @override
  Widget build(BuildContext context) {
    controladorMecanico.addListener(escuchador);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: Column(
        children: [
          FiltroParaFecha(fechaSeleccionadaInicial: widget.fechaSeleccionadaInicial, fechaSeleccionadaFinal: widget.fechaSeleccionadaFinal),
          FiltroParaEtiqueta(misEtiquetas: widget.misEtiquetas, idEtiquetaSeleccionada: widget.idEtiquetaSeleccionada),
          FiltroParaMecanico(controladorMecanico: controladorMecanico, titulo: 'Mecánico', campoRequerido: false),
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
        ],
      ),
    );
  }
  @override
  void dispose() {
    controladorMecanico.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class FiltroParaFecha extends StatelessWidget {
  FiltroParaFecha({
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
      );
      if (nuevaFecha != null) {
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
      );
      if (nuevaFecha != null) {
        fechaSeleccionadaFinal = nuevaFecha;
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(FiltradoGastosPorFecha(fechaInicial: fechaSeleccionadaInicial, fechaFinal: fechaSeleccionadaFinal));    
      }
    };
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
    required this.idEtiquetaSeleccionada
  });
  
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FiltroSeleccionadorEtiqueta(idEtiquetaSeleccionada: idEtiquetaSeleccionada, titulo: 'Etiqueta', misEtiquetas: misEtiquetas),
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
    return CuadroDeTexto(controlador: controladorMecanico, titulo: titulo, campoRequerido: false);
  }
}

class TileGasto extends StatelessWidget {
  const TileGasto({
    super.key,
    required this.gasto, 
  });

  final Gasto gasto;
  
  String get obtenerMecanico => (gasto.mecanico.isNotEmpty)? gasto.mecanico:'Sin mecánico';

  @override
  Widget build(BuildContext context) {
    DateTime nuevaFecha = DateTime.parse(gasto.fecha);
    Future<String> nombreEtiqueta = Etiquetas().obtenerNombreEtiquetaDeId(gasto.etiqueta);

    return FutureBuilder<String>(
      future: nombreEtiqueta,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const WidgetCargando();
        } else{
          final etiqueta = snapshot.data?? nombreEtiquetaNula;
          
          return ListTile(
            title: Text(
              etiqueta,
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
            onTap: () {
            },
          );
        }
      }
    );
  }
}

class BotonesTileGasto extends StatelessWidget {
  const BotonesTileGasto({
    super.key,
    required this.gasto,
  });

  final Gasto gasto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(EliminadoGasto(id: gasto.id));
            }, 
            icon: const Icon(Icons.delete, color: Colors.red)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarGasto(gasto: gasto));
            }, 
            icon: const Icon(Icons.edit, color: Colors.red)
          ),
        ],
      ),
    );
  }
}

class FiltroSeleccionadorEtiqueta extends StatelessWidget{
  const FiltroSeleccionadorEtiqueta({
    super.key,
    required this.idEtiquetaSeleccionada,
    required this.titulo, 
    required this.misEtiquetas
  });

  final int idEtiquetaSeleccionada;
  final String titulo;
  final Future <List<Etiqueta>>? misEtiquetas;

  @override
  Widget build(BuildContext context)  {
    return Column(
      children: [
        Text(titulo),
        SizedBox(
          width: 160,
          child: FutureBuilder<List<Etiqueta>>(
            future: misEtiquetas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final etiquetas = snapshot.data?? [];
                
                return DropdownButtonFormField(
                  validator: (value) {
                    if ((value != null && (value == valorEtiquetaNula || value == valorNoHayEtiquetasCreadas)) || value == valorEtiquetaTodas) return 'Valor requerido';
                    return null;
                  },
                  value: idEtiquetaSeleccionada,
                  items: [
                    const DropdownMenuItem(value: valorEtiquetaTodas, child: Text('Todas')),
                    const DropdownMenuItem(value: valorEtiquetaNula, child: Text(nombreEtiquetaNula),),
                    for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: Text(etiqueta.nombre),)
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

/* ------------------------------------------------------------------------------ */