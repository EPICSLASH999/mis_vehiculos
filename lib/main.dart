import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/tablas/etiquetas.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/gasto.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';

void main() {
  runApp(const AplicacionInyectada());
}

class AplicacionInyectada extends StatelessWidget {
  const AplicacionInyectada({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VehiculoBloc()..add(Inicializado()),
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: BlocBuilder<VehiculoBloc, VehiculoEstado>(
        builder: (context, state) {
          if (state is MisVehiculos) return WidgetMisVehiculos(misVehiculos: state.misVehiculos, idsVehiculosSeleccionados: state.idsVehiculosSeleccionados,);
          if (state is PlantillaVehiculo) return WidgetPlantillaVehiculo(vehiculo: state.vehiculo,);
          if (state is PlantillaGasto) return WidgetPlantillaGasto(idVehiculo: state.idVehiculo, misEtiquetas: state.misEtiquetas, gasto: state.gasto,);
          if (state is AdministradorEtiquetas) return WidgetAdministradorEtiquetas(misEtiquetas: state.misEtiquetas,);
          if (state is PlantillaEtiqueta) return WidgetPlantillaEtiqueta(etiqueta: state.etiqueta);
          if (state is MisGastos) return WidgetMisGastos(misGastos: state.misGastos, fechaSeleccionadaInicial: state.fechaInicial, fechaSeleccionadaFinal: state.fechaFinal, misEtiquetas: state.misEtiquetas, idEtiquetaSeleccionada: state.filtroIdEtiqueta,);
          return const WidgetCargando();
        },
      )
    );
  }
}

class WidgetCargando extends StatelessWidget {
  const WidgetCargando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/* ----------------------------------- MISC ------------------------------------ */

class CuadroDeTexto extends StatelessWidget {
  const CuadroDeTexto({
    super.key,
    required this.controlador,
    required this.titulo, 
    this.esInt = false, 
    this.esDouble = false,
    this.esSoloLectura = false, 
    this.funcionAlPresionar,
    this.campoRequerido = true,
  });

  final TextEditingController controlador;
  final String titulo;
  final bool esInt;
  final bool esDouble;
  final bool esSoloLectura;
  final VoidCallback? funcionAlPresionar;
  final bool campoRequerido;

  bool esNumerico(String? s) {
    if(s == null) return false;    
    if (esInt) return int.tryParse(s) != null;
    return double.tryParse(s) != null;
  }
  InputDecoration obtenerDecoracion(){

    if (campoRequerido && !esSoloLectura){
      return const InputDecoration(
        hintText: "", 
        prefixIcon: Icon(Icons.label_important),
        prefixIconColor: Colors.red,
        suffixIcon: Icon(Icons.car_rental)
      );
    }

    return const InputDecoration(
      hintText: "", 
      suffixIcon: Icon(Icons.car_rental)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(titulo),
          TextFormField(
            validator: (value) {
              if (value != null && value.isEmpty && campoRequerido) return 'Campo requerido';
              if (esInt && !esNumerico(value)) return 'Debe ser número entero';  
              if (esDouble && !esNumerico(value)) return 'Debe ser numerico';  
              if((!esInt && !esDouble) && esNumerico(value)) return 'Campo inválido';
              return null;
            },
            readOnly: esSoloLectura,
            controller: controlador,
            decoration: obtenerDecoracion(),
            onTap: funcionAlPresionar
          ),
        ],
      ),
    );
  }
}
class SeleccionadorDeFecha extends StatelessWidget {
  const SeleccionadorDeFecha({
    super.key,
    required this.controlador,
    required this.titulo, 
    required this.funcionAlPresionar,
  });

  final TextEditingController controlador;
  final String titulo;
  final VoidCallback funcionAlPresionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(titulo),
            TextFormField(
              validator: (value) {
                if (value != null && value.isEmpty) return 'Valor requerido';
                return null;
              },
              readOnly: true,
              controller: controlador,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.date_range)
              ),
              onTap: funcionAlPresionar
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------------------------- */

/* --------------------------------- VEHICULOS --------------------------------- */
// Widget Principal (Menu Principal)
class WidgetMisVehiculos extends StatelessWidget {
  final Future <List<Vehiculo>>? misVehiculos;
  final List<int> idsVehiculosSeleccionados;

  const WidgetMisVehiculos({super.key, required this.misVehiculos, required this.idsVehiculosSeleccionados});

  VoidCallback? funcionConsultarGastos(BuildContext context){
    if (idsVehiculosSeleccionados.isEmpty) return null;
    return (){
      context.read<VehiculoBloc>().add(ClickeadoConsultarGastos());
    };
  }

  @override
  Widget build(BuildContext context) {
    var pressedConsultarGastos = funcionConsultarGastos(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: 
            FutureBuilder<List<Vehiculo>>(
              future: misVehiculos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final vehiculos = snapshot.data?? [];

                  return vehiculos.isEmpty
                      ? const Center(
                        child: Text(
                          'Sin vehiculos...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      )
                    : ListView.separated(
                      separatorBuilder: (context, index) => 
                          const SizedBox(height: 12,), 
                      itemCount: vehiculos.length,
                      itemBuilder: (context, index) {
                        final vehiculo = vehiculos[index];
                        return TileVehiculo(vehiculo: vehiculo, estaSeleccionado: idsVehiculosSeleccionados.contains(vehiculo.id),);
                      }, 
                    );
                }
              },
            ),
          ),
          TextButton(
            onPressed: pressedConsultarGastos,
            child: const Text('Consultar gastos'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<VehiculoBloc>().add(ClickeadoAgregarVehiculo());
        },
      ),
    );
  }
}

class TileVehiculo extends StatelessWidget {
  const TileVehiculo({
    super.key,
    required this.vehiculo, 
    required this.estaSeleccionado,
  });

  final Vehiculo vehiculo;
  final bool estaSeleccionado;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        vehiculo.modelo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(vehiculo.matricula),
      trailing: BotonesTileVehiculo(vehiculo: vehiculo),
      onTap: () {
        context.read<VehiculoBloc>().add(SeleccionadoVehiculo(idVehiculo: vehiculo.id));
      },
      selected: estaSeleccionado,
      selectedColor: Colors.black,
      selectedTileColor: Colors.amber,
    );
  }
}

class BotonesTileVehiculo extends StatelessWidget {
  const BotonesTileVehiculo({
    super.key,
    required this.vehiculo,
  });

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(EliminadoVehiculo(id: vehiculo.id));
            }, 
            icon: const Icon(Icons.delete, color: Colors.red)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarVehiculo(vehiculo: vehiculo));
            }, 
            icon: const Icon(Icons.edit, color: Colors.red)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoAgregarGasto(idVehiculo: vehiculo.id));
            }, 
            icon: const Icon(Icons.monetization_on, color: Colors.red)
          ),
        ],
      ),
    );
  }
}

class WidgetPlantillaVehiculo extends StatefulWidget {
  final Vehiculo? vehiculo;
  const WidgetPlantillaVehiculo({super.key, this.vehiculo});

  @override
  State<WidgetPlantillaVehiculo> createState() => _WidgetPlantillaVehiculoState();
}

class _WidgetPlantillaVehiculoState extends State<WidgetPlantillaVehiculo> {
  final TextEditingController controladorMatricula = TextEditingController();
  final TextEditingController controladorMarca = TextEditingController();
  final TextEditingController controladorModelo = TextEditingController();
  final TextEditingController controladorColor = TextEditingController();
  final TextEditingController controladorAno = TextEditingController();

  String obtenerTexto() => (widget.vehiculo == null)? 'Agregar Vehiculo':'Editar Vehiculo';
  Vehiculo obtenerVehiculo(){
    return Vehiculo(
      id: (widget.vehiculo?.id)??0, 
      matricula: controladorMatricula.text, 
      marca: controladorMarca.text, 
      modelo: controladorModelo.text, 
      color: controladorColor.text, 
      ano: int.parse(controladorAno.text)
    );
  }
  void inicializarValoresDeControladores(){
    if (widget.vehiculo == null) return;
    controladorMatricula.text = widget.vehiculo?.matricula??'';
    controladorMarca.text = widget.vehiculo?.marca??'';
    controladorModelo.text = widget.vehiculo?.modelo??'';
    controladorColor.text = widget.vehiculo?.color??'';
    controladorAno.text = (widget.vehiculo?.ano??0000).toString();
  }
  
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();

    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.
            CuadroDeTexto(controlador: controladorMatricula, titulo: 'Matricula'),          
            CuadroDeTexto(controlador: controladorMarca, titulo: 'Marca'),
            CuadroDeTexto(controlador: controladorModelo, titulo: 'Modelo'),
            CuadroDeTexto(controlador: controladorColor, titulo: 'Color'),
            CuadroDeTexto(controlador: controladorAno, titulo: 'Año', esInt: true),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (widget.vehiculo == null) {
                    context.read<VehiculoBloc>().add(AgregadoVehiculo(vehiculo: obtenerVehiculo()));
                    return;
                  }
                  context.read<VehiculoBloc>().add(EditadoVehiculo(vehiculo: obtenerVehiculo()));
                }
              },
              child: Text(obtenerTexto()),
            ),
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    controladorMatricula.dispose();
    controladorMarca.dispose();
    controladorModelo.dispose();
    controladorColor.dispose();
    controladorAno.dispose();
    super.dispose();
  }
}

/* ----------------------------------------------------------------------------- */

/* ----------------------------------- GASTOS ----------------------------------- */
const String nombreEtiquetaNula = 'Desconocida';
const int valorEtiquetaNula = 0;
const int valorEtiquetaTodas = 999;
const int valorSinEtiquetas = 998;

Future<String> obtenerNombreEtiquetaDeId(int id) async {
  Etiqueta etiqueta = await Etiquetas().fetchById(id);
  return etiqueta.nombre;
}
Future<String> obtenerNombreVehiculoDeId(int id) async {
  Vehiculo vehiculo = await Vehiculos().fetchById(id);
  return vehiculo.matricula;
}

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
    controladorFecha.text = DateFormat.yMMMd().format(fechaRecibida); // Esto es solo para mostrar la fecha en el textBox
    fechaSeleccionada = fechaRecibida; // Esta es la fecha que se guardara en la BaseDeDatos
    //controladorFecha.text = (widget.gasto?.fecha??DateFormat.yMMMd().format(fechaSeleccionada));
  }
  Gasto obtenerGasto(){
    return Gasto(
      id: (widget.gasto?.id)??0, 
      vehiculo: int.parse(idVehiculo),
      etiqueta: int.parse(controladorEtiqueta.text),
      mecanico: controladorMecanico.text,
      lugar: controladorLugar.text,
      costo: double.parse(controladorCosto.text),
      //fecha: controladorFecha.text
      fecha: fechaSeleccionada.millisecondsSinceEpoch.toString()
    );
  }
  VoidCallback funcionAlPresionarFecha(){
    return () async {
      DateTime? nuevaFecha = await showDatePicker(
        context: context, 
        initialDate: fechaSeleccionada,
        firstDate: DateTime(1970), 
        lastDate: DateTime(3000),
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
            future: obtenerNombreVehiculoDeId(int.parse(controladorVehiculo.text)),
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
                      CuadroDeTexto(controlador: controladorLugar, titulo: 'Lugar', campoRequerido: false,),
                      CuadroDeTexto(controlador: controladorCosto, titulo: 'Costo', esDouble: true,),
                      CuadroDeTexto(controlador: controladorFecha, titulo: 'Fecha', esSoloLectura: true, funcionAlPresionar: funcionAlPresionarFecha(),),
                    
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
  bool esEditarGasto;

  @override
  State<SeleccionadorEtiqueta> createState() => _SeleccionadorEtiquetaState();
}

class _SeleccionadorEtiquetaState extends State<SeleccionadorEtiqueta>{
  var etiquetaSeleccionada = "";

  @override
  Widget build(BuildContext context)  {
    int? idEtiquetaSeleccionada = int.tryParse(widget.etiquetaSeleccionada.text);
    idEtiquetaSeleccionada = ((idEtiquetaSeleccionada != null) && (idEtiquetaSeleccionada == valorEtiquetaNula))?null:idEtiquetaSeleccionada;
    etiquetaSeleccionada = (idEtiquetaSeleccionada == null)?'':idEtiquetaSeleccionada.toString();
    
    bool esNulaEtiqueta() => idEtiquetaSeleccionada == null && widget.esEditarGasto;
    int valorIdEtiquetaInicial(List<Etiqueta> etiquetas) {
      if ((esNulaEtiqueta()) && etiquetas.isNotEmpty) return valorEtiquetaNula;
      return (idEtiquetaSeleccionada != null)?idEtiquetaSeleccionada:(etiquetas.isNotEmpty? etiquetas.first.id:valorSinEtiquetas);
    }
    
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
                    if (value != null && value == valorSinEtiquetas) return 'Valor requerido';
                    
                    // En caso de que se deja seleccionada la etiqueta por omisión, se iguala el valor manualmente.
                    if (etiquetaSeleccionada.isEmpty) {
                      //etiquetaSeleccionada = (value == valorEtiquetaNula)?valorEtiquetaNula.toString():etiquetas.first.id.toString();
                      etiquetaSeleccionada = value.toString();
                      widget.etiquetaSeleccionada.text = etiquetaSeleccionada;
                    }
                    return null;
                  },
                  value: valorIdEtiquetaInicial(etiquetas),
                  items: [
                    if(esNulaEtiqueta()) const DropdownMenuItem(value: valorEtiquetaNula, child: Text(nombreEtiquetaNula),),
                    for(var etiqueta in etiquetas) DropdownMenuItem(value: etiqueta.id, child: Text(etiqueta.nombre),)
                  ],
                  onChanged: (value) {
                    setState(() {
                      etiquetaSeleccionada = value.toString();
                      widget.etiquetaSeleccionada.text = etiquetaSeleccionada;
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

class WidgetMisGastos extends StatelessWidget {
  final Future <List<Gasto>>? misGastos;
  final DateTime fechaSeleccionadaFinal;
  final DateTime fechaSeleccionadaInicial;
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;

  const WidgetMisGastos({super.key, this.misGastos, required this.fechaSeleccionadaFinal, required this.fechaSeleccionadaInicial, required this.misEtiquetas, required this.idEtiquetaSeleccionada}); 

  String normalizarNumero(int numeroRecibido){
    String numeroNormalizado = '';
    if (numeroRecibido.toString().length == 1) numeroNormalizado += '0';
    return numeroNormalizado += numeroRecibido.toString();
  }
  bool enIntervaloFecha(String fecha) {
    DateTime fechaFinalNormalizada = DateTime.parse('${fechaSeleccionadaFinal.year}-${normalizarNumero(fechaSeleccionadaFinal.month)}-${normalizarNumero(fechaSeleccionadaFinal.day)} 23:59:59.999');
    return ((DateTime.parse(fecha)).isAfter(fechaSeleccionadaInicial) && ((DateTime.parse(fecha)).isBefore(fechaFinalNormalizada)));
  }
  
  @override
  Widget build(BuildContext context) {
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
          FiltroParaGastos(fechaSeleccionadaInicial: fechaSeleccionadaInicial, fechaSeleccionadaFinal: fechaSeleccionadaFinal, misEtiquetas: misEtiquetas, idEtiquetaSeleccionada: idEtiquetaSeleccionada,),
          Expanded(
            child: 
            FutureBuilder<List<Gasto>>(
              future: misGastos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final gastos = snapshot.data?? [];
                  
                  gastos.removeWhere((element) => (!enIntervaloFecha(element.fecha))); // Filtrar por fecha
                  if (idEtiquetaSeleccionada != valorEtiquetaTodas) gastos.removeWhere((element) => (element.etiqueta != idEtiquetaSeleccionada)); // Filtrar por etiqueta
                  
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
}

// ignore: must_be_immutable
class FiltroParaGastos extends StatelessWidget {
  FiltroParaGastos({
    super.key, 
    required this.fechaSeleccionadaInicial,
    required this.fechaSeleccionadaFinal, 
    required this.misEtiquetas, 
    required this.idEtiquetaSeleccionada,
  });
  final Future<List<Etiqueta>>? misEtiquetas;
  final int idEtiquetaSeleccionada;

  TextEditingController controladorFechaInicial = TextEditingController();
  TextEditingController controladorFechaFinal = TextEditingController();
  TextEditingController controladorEtiqueta= TextEditingController();
  
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
    controladorEtiqueta.text = idEtiquetaSeleccionada.toString();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SeleccionadorDeFecha(controlador: controladorFechaInicial, titulo: 'Fecha Inicial', funcionAlPresionar: funcionAlPresionarFechaInicial(context),),
            SeleccionadorDeFecha(controlador: controladorFechaFinal, titulo: 'Fecha Final', funcionAlPresionar: funcionAlPresionarFechaFinal(context),),            
          ],
        ),
        FiltroSeleccionadorEtiqueta(idEtiquetaSeleccionada: idEtiquetaSeleccionada, titulo: 'Etiqueta', misEtiquetas: misEtiquetas),
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

  @override
  Widget build(BuildContext context) {
    DateTime nuevaFecha = DateTime.parse(gasto.fecha);
    Future<String> nombreEtiqueta = obtenerNombreEtiquetaDeId(gasto.etiqueta);

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
                    if ((value != null && (value == valorEtiquetaNula || value == valorSinEtiquetas)) || value == valorEtiquetaTodas) return 'Valor requerido';
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

/* ------------------------------------------------------------------------------ */

/* --------------------------------- ETIQUETAS --------------------------------- */
class WidgetAdministradorEtiquetas extends StatelessWidget {
  const WidgetAdministradorEtiquetas({super.key, required this.misEtiquetas});

  final Future <List<Etiqueta>>? misEtiquetas;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Etiquetas'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: FutureBuilder<List<Etiqueta>>(
        future: misEtiquetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final etiquetas = snapshot.data?? [];

            return etiquetas.isEmpty
                ? const Center(
                  child: Text(
                    'Sin etiquetas...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                )
              : ListView.separated(
                separatorBuilder: (context, index) => 
                    const SizedBox(height: 12,), 
                itemCount: etiquetas.length,
                itemBuilder: (context, index) {
                  final etiqueta = etiquetas[index];
                  return TileEtiqueta(etiqueta: etiqueta);
                }, 
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<VehiculoBloc>().add(ClickeadoAgregarEtiqueta());
        },
      ),
    );
  }
}

class TileEtiqueta extends StatelessWidget {
  const TileEtiqueta({
    super.key,
    required this.etiqueta,
  });

  final Etiqueta etiqueta;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        etiqueta.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: BotonesTileEtiqueta(etiqueta: etiqueta),
      onTap: () {
        
      },
    );
  }
}

class BotonesTileEtiqueta extends StatelessWidget {
  const BotonesTileEtiqueta({
    super.key,
    required this.etiqueta,
  });

  final Etiqueta etiqueta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(EliminadaEtiqueta(id: etiqueta.id));
            }, 
            icon: const Icon(Icons.delete, color: Colors.red)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarEtiqueta(etiqueta: etiqueta));
            }, 
            icon: const Icon(Icons.edit, color: Colors.red)
          ),
        ],
      ),
    );
  }
}

class WidgetPlantillaEtiqueta extends StatelessWidget {
  final Etiqueta? etiqueta;
  WidgetPlantillaEtiqueta({super.key, this.etiqueta});

  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController controladorNombre = TextEditingController();

  Etiqueta obtenerEtiqueta(){
    return Etiqueta(
      id: (etiqueta?.id)??0, 
      nombre: controladorNombre.text, 
    );
  }
  String obtenerTexto() => "${(etiqueta == null)? 'Agregar':'Editar'} Etiqueta";
  void inicializarValoresDeControladores(){
    if (etiqueta == null) return;
    controladorNombre.text = etiqueta?.nombre??'';
  }

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();

    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoRegresarAAdministradorEtiquetas());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            CuadroDeTexto(controlador: controladorNombre, titulo: 'Nombre'),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (etiqueta == null) {
                    context.read<VehiculoBloc>().add(AgregadoEtiqueta(nombreEtiqueta: controladorNombre.text));
                  }
                  context.read<VehiculoBloc>().add(EditadoEtiqueta(etiqueta: obtenerEtiqueta()));
                }
              },
              child: Text(obtenerTexto()),
            ),
          ],
        ),
      ),
    );
  }
}
/* ----------------------------------------------------------------------------- */

