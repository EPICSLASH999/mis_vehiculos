import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/bloc/bloc.dart';
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
          if (state is MisVehiculos) return WidgetMisVehiculos(misVehiculos: state.misVehiculos,);
          if (state is PlantillaVehiculo) return WidgetPlantillaVehiculo(vehiculo: state.vehiculo,);
          if (state is PlantillaGasto) return WidgetPlantillaGasto(idVehiculo: state.idVehiculo, misEtiquetas: state.misEtiquetas);
          return const WidgetCargando();
        },
      )
    );
  }
}

// Widget Principal (Menu Principal)
class WidgetMisVehiculos extends StatelessWidget {
  final Future <List<Vehiculo>>? misVehiculos;

  const WidgetMisVehiculos({super.key, required this.misVehiculos});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
      ),
      body: FutureBuilder<List<Vehiculo>>(
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
                  return TileVehiculo(vehiculo: vehiculo);
                }, 
              );
          }
        },
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

/* --------------------------------- VEHICULOS --------------------------------- */

class TileVehiculo extends StatelessWidget {
  const TileVehiculo({
    super.key,
    required this.vehiculo,
  });

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        vehiculo.modelo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(vehiculo.matricula),
      trailing: BotonesTile(vehiculo: vehiculo),
      onTap: () {
        
      },
    );
  }
}

class BotonesTile extends StatelessWidget {
  const BotonesTile({
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
    controladorAno.text = (widget.vehiculo?.ano??0).toString();
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
              context.read<VehiculoBloc>().add(ClickeadoRegresar());
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

class CuadroDeTexto extends StatelessWidget {
  const CuadroDeTexto({
    super.key,
    required this.controlador,
    this.esInt = false, 
    required this.titulo, 
    this.esDouble = false,
    this.soloLectura = false, 
    this.funcionAlPresionar,
  });

  final TextEditingController controlador;
  final bool esInt;
  final bool esDouble;
  final String titulo;
  final bool soloLectura;
  final VoidCallback? funcionAlPresionar;

  bool esNumerico(String? s) {
    if(s == null) return false;    
    if (esInt) return int.tryParse(s) != null;
    return double.tryParse(s) != null;
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
              if (value != null && value.isEmpty) return 'Valor requerido';
              if ((esInt || esDouble) && !esNumerico(value)) return 'Debe ser numerico';  
              return null;
            },
            readOnly: soloLectura,
            controller: controlador,
            decoration: const InputDecoration(
              hintText: "", 
              prefixIcon: Icon(Icons.access_alarm_outlined),
              prefixIconColor: Colors.red,
              suffixIcon: Icon(Icons.password)
            ),
            onTap: funcionAlPresionar
          ),
        ],
      ),
    );
  }
}

/* ----------------------------------------------------------------------------- */

/* ----------------------------------- GASTOS ----------------------------------- */
class WidgetPlantillaGasto extends StatefulWidget {
  final Gasto? gasto;
  final int idVehiculo;
  final Future <List<Etiqueta>>? misEtiquetas;

  const WidgetPlantillaGasto({super.key, required this.idVehiculo, this.gasto, this.misEtiquetas});

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

  Gasto obtenerGasto(){
    return Gasto(
      id: (widget.gasto?.id)??0, 
      vehiculo: int.parse(controladorVehiculo.text),
      etiqueta: int.parse(controladorEtiqueta.text),
      mecanico: controladorMecanico.text,
      lugar: controladorLugar.text,
      costo: double.parse(controladorCosto.text),
      fecha: controladorFecha.text
    );
  }
  VoidCallback funcionAlPresionar(){
    return () async {
      DateTime? nuevaFecha = await showDatePicker(
        context: context, 
        initialDate: fechaSeleccionada,
        firstDate: DateTime(1550), 
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
    controladorFecha.text =  DateFormat.yMMMd().format(fechaSeleccionada);
    controladorVehiculo.text = widget.idVehiculo.toString();
    controladorEtiqueta.text = '0';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoRegresar());
            }, 
            icon: const Icon(Icons.arrow_back_ios_new_outlined)
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            CuadroDeTexto(controlador: controladorVehiculo, titulo: 'Vehiculo', soloLectura: true,),
            SeleccionadorEtiqueta(etiquetaSeleccionada: controladorEtiqueta, titulo: 'Etiqueta'),
            CuadroDeTexto(controlador: controladorMecanico, titulo: 'Mecanico'),
            CuadroDeTexto(controlador: controladorLugar, titulo: 'Lugar'),
            CuadroDeTexto(controlador: controladorCosto, titulo: 'Costo', esDouble: true,),
            CuadroDeTexto(controlador: controladorFecha, titulo: 'Fecha', soloLectura: true, funcionAlPresionar: funcionAlPresionar(),),
           
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //context.read<VehiculoBloc>().add(AgregadoGasto(gasto: obtenerGasto()));
                }
                print(controladorEtiqueta.text);
              },
              child: const Text('Agregar Gasto'),
            ),
          ],
        ),
      )
    );
  }
}

// ignore: must_be_immutable
class SeleccionadorEtiqueta extends StatefulWidget {
  SeleccionadorEtiqueta({
    super.key,
    required this.etiquetaSeleccionada,
    required this.titulo, 
    this.misEtiquetas
  });

  TextEditingController etiquetaSeleccionada;
  final String titulo;
  final Future <List<Etiqueta>>? misEtiquetas;

  @override
  State<SeleccionadorEtiqueta> createState() => _SeleccionadorEtiquetaState();
}

class _SeleccionadorEtiquetaState extends State<SeleccionadorEtiqueta> {
  List<Etiqueta> misEtiquetas = [];

  obtenerEtiquetas() async{
    misEtiquetas = await widget.misEtiquetas??[];
  }
  
  @override
  Widget build(BuildContext context){
   obtenerEtiquetas();

    return Column(
      children: [
        Text(widget.titulo),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: misEtiquetas.isNotEmpty? misEtiquetas.first.id:0,
            items: [
              //const DropdownMenuItem(value: '1', child: Text('1')),
              for(var etiqueta in misEtiquetas) DropdownMenuItem(value: etiqueta.id, child: Text(etiqueta.nombre),)
            ],
            onChanged: (value) {
              setState(() {
                widget.etiquetaSeleccionada.text = value.toString();
              });
            },
          ),
        ),
        const TextButton(
          onPressed: null, 
          child: Text('Administrar Etiquetas')
        ),
      ],
    );
  }
}
/* ----------------------------------------------------------------------------- */

class WidgetCargando extends StatelessWidget {
  const WidgetCargando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}