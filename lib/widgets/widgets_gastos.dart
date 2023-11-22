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

/* ----------------------------------- GASTOS ----------------------------------- */
// Variables Globales
// IA
Future<List<Map<String, Object?>>>? listaMecanicoPorEtiquetaGlobal;

// Métodos IA
int obtenerEtiquetaConMayorOcurrencias(List<Map<String, Object?>> listaMecanicoPorEtiqueta) {
  if(listaMecanicoPorEtiqueta.isEmpty) return valorNoTieneEtiquetaConMayorOcurrencias;
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

class WidgetPlantillaGasto extends StatefulWidget {
  final Gasto? gasto;
  final int idVehiculo;
  final Future <List<Etiqueta>>? misEtiquetas;
  final Future<List<Map<String, Object?>>>? listaMecanicoPorEtiqueta;

  const WidgetPlantillaGasto({super.key, required this.idVehiculo, this.gasto, required this.misEtiquetas, this.listaMecanicoPorEtiqueta});

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

  String obtenerTexto() => '${(!esEditarGasto)? 'Agregar':'Editar'} Gasto';
  bool get esEditarGasto => widget.gasto != null;

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
      mecanico: controladorMecanico.text.trim(),
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
    listaMecanicoPorEtiquetaGlobal = widget.listaMecanicoPorEtiqueta;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        leading: IconButton(
          onPressed: () {
            if (widget.gasto == null) {
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
              future: listaMecanicoPorEtiquetaGlobal, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final listaMecanicoPorEtiqueta = snapshot.data?? [];
                  
                  // Procedimiento para IA de obtener mecánico por etiqueta.
                  int idEtiquetaConMayorOcurrencias = obtenerEtiquetaConMayorOcurrencias(listaMecanicoPorEtiqueta);
                  String mecanicoConMayorOcurrenciasDeEtiqueta = obtenerMecanicoConMayorOcurrenciasDeEtiqueta(listaMecanicoPorEtiqueta, idEtiquetaConMayorOcurrencias);
                  if(!esEditarGasto) controladorMecanico.text = mecanicoConMayorOcurrenciasDeEtiqueta;
                  if(!esEditarGasto) controladorEtiqueta.text = idEtiquetaConMayorOcurrencias.toString(); 
                    
                  return SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          CuadroDeTexto(controlador: controladorVehiculo, titulo: 'Vehiculo', esSoloLectura: true,),
                          SeleccionadorEtiqueta(etiquetaSeleccionada: controladorEtiqueta, titulo: 'Etiqueta', misEtiquetas: widget.misEtiquetas, esEditarGasto: (widget.gasto != null),controladorMecanico: controladorMecanico),
                          CuadroDeTexto(controlador: controladorMecanico, titulo: 'Mecanico', campoRequerido: false, icono: const Icon(Icons.build),),
                          CuadroDeTexto(controlador: controladorLugar, titulo: 'Lugar', campoRequerido: false, maxCaracteres: 40, icono: const Icon(Icons.place),),
                          CuadroDeTexto(controlador: controladorCosto, titulo: 'Costo', esDouble: true, maxCaracteres: 7, icono: const Icon(Icons.attach_money),),
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
    required this.misEtiquetas,
    this.esEditarGasto = false, 
    required this.controladorMecanico,
  });

  final TextEditingController etiquetaSeleccionada;
  final String titulo;
  final Future <List<Etiqueta>>? misEtiquetas;
  final bool esEditarGasto;
  final TextEditingController controladorMecanico;

  @override
  State<SeleccionadorEtiqueta> createState() => _SeleccionadorEtiquetaState();
}

class _SeleccionadorEtiquetaState extends State<SeleccionadorEtiqueta>{
 
  int? get idEtiquetaSeleccionada => int.tryParse(widget.etiquetaSeleccionada.text); 
  final double anchura = 170;

  @override
  Widget build(BuildContext context)  {
    bool esSinEtiqueta() => (widget.etiquetaSeleccionada.text == idSinEtiqueta.toString()) && widget.esEditarGasto;
    int valorIdEtiquetaInicial(List<Etiqueta> etiquetas) {
      if ((esSinEtiqueta()) && etiquetas.isNotEmpty) return idSinEtiqueta;
      if(idEtiquetaSeleccionada != null && idEtiquetaSeleccionada != valorNoTieneEtiquetaConMayorOcurrencias) return idEtiquetaSeleccionada!; 
      return (etiquetas.isNotEmpty? etiquetas.first.id:valorNoHayEtiquetasCreadas);
    }

    return Column(
      children: [
        TituloComponente(titulo: widget.titulo),
        SizedBox(
          width: anchura,
          child: FutureBuilder<List<Etiqueta>>(
            future: widget.misEtiquetas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final etiquetas = snapshot.data?? [];
                
                return FutureBuilder(
                  future: listaMecanicoPorEtiquetaGlobal, 
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting){
                      return const WidgetCargando();
                    } else{
                      final listaMecanicoPorEtiqueta = snapshot.data?? [];

                      return DropdownButtonFormField(
                        validator: (value) {
                          if (value != null && value == valorNoHayEtiquetasCreadas) return 'Valor requerido';
                          
                          // En caso de no seleccionar una etiqueta y dejar la que ya esta seleccionada, se asigna el valor manualmente.
                          widget.etiquetaSeleccionada.text = value.toString();
                          return null;
                        },
                        value: valorIdEtiquetaInicial(etiquetas),
                        items: [
                          if(idEtiquetaSeleccionada == idSinEtiqueta) const DropdownMenuItem(value: idSinEtiqueta, child: Text(nombreSinEtiqueta),),
                          for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: SizedBox(width: (anchura-30), child: Text(etiqueta.nombre, overflow: TextOverflow.ellipsis)),)
                        ],
                        onChanged: (value) {
                          setState(() {
                            widget.etiquetaSeleccionada.text = value.toString();
                      
                            widget.controladorMecanico.text = obtenerMecanicoConMayorOcurrenciasDeEtiqueta(listaMecanicoPorEtiqueta, value!);
                          });
                        },
                      );
                    }
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

class WidgetMisGastos extends StatefulWidget {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaSeleccionadaFinal;
  final DateTime fechaSeleccionadaInicial;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;
  final int idVehiculoSeleccionado;
  final Future <List<Vehiculo>>? misVehiculos;

   const WidgetMisGastos({
    super.key, 
    this.misGastos, 
    required this.fechaSeleccionadaFinal, 
    required this.fechaSeleccionadaInicial, 
    required this.misEtiquetas, 
    required this.idEtiquetaSeleccionada,
    required this.idVehiculoSeleccionado,
    required this.misVehiculos,
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

  void escuchador(){
    setState(() {

    });
  }
  
  @override
  void dispose() {
    controladorMecanico.dispose();
    super.dispose();
  }


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
    controladorMecanico.addListener(escuchador);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisGastos),
      body: Column(
        children: [
          FiltroParaFecha(fechaSeleccionadaInicial: widget.fechaSeleccionadaInicial, fechaSeleccionadaFinal: widget.fechaSeleccionadaFinal),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FiltroParaEtiqueta(misEtiquetas: widget.misEtiquetas, idEtiquetaSeleccionada: widget.idEtiquetaSeleccionada),
              FiltroParaVehiculo(idVehiculoSeleccionado: widget.idVehiculoSeleccionado, titulo: 'Vehículo', misVehiculos: widget.misVehiculos),
            ],
          ),
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
          TotalGastos(listaGastos: obtenerListaGastos())
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
        initialEntryMode: DatePickerEntryMode.calendarOnly
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
        initialEntryMode: DatePickerEntryMode.calendarOnly
      );
      if (nuevaFecha != null) {
        //2023-01-01 00:00:00.000
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

  final double anchura = 160;

  @override
  Widget build(BuildContext context)  {
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

class FiltroParaVehiculo extends StatelessWidget{
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
    return SeleccionadorVehiculo(titulo: titulo, misVehiculos: misVehiculos, idVehiculoSeleccionado: idVehiculoSeleccionado);
  }
}

class SeleccionadorVehiculo extends StatelessWidget {
  const SeleccionadorVehiculo({
    super.key,
    required this.titulo,
    required this.misVehiculos,
    required this.idVehiculoSeleccionado,
  });

  final String titulo;
  final Future<List<Vehiculo>>? misVehiculos;
  final int idVehiculoSeleccionado;

  @override
  Widget build(BuildContext context) {
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
}
/* ------------------------------------------------------------------------------ */