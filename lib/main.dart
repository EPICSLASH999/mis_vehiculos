import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/bloc/bloc.dart';
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
          return const WidgetCargando();
        },
      )
    );
  }
}

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
                  final subtitle = vehiculo.matricula;

                    return ListTile(
                      title: Text(
                        vehiculo.modelo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(subtitle),
                      trailing: SizedBox(
                        width: 100,
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
                          ],
                        ),
                      ),
                      onTap: () {
                        
                      },
                    );
                  
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
  VoidCallback? obtenerFuncion (BuildContext context){
    if (widget.vehiculo == null) {
      return () {
        context.read<VehiculoBloc>().add(AgregadoVehiculo(vehiculo: obtenerVehiculo()));
      };
    }
    return () {
      context.read<VehiculoBloc>().add(EditadoVehiculo(vehiculo: obtenerVehiculo()));
    };
  }
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
  
  void escuchador(){
    //print(controladorMatricula.text);
    setState(() {
      //reglas = establecerReglas();
    });
  }

  @override
  Widget build(BuildContext context) {
    //controladorMatricula.addListener(escuchador);
    var funcionOnClick = obtenerFuncion(context);
    inicializarValoresDeControladores();

    return Scaffold(
      appBar: AppBar(title: Text(obtenerTexto())),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CuadroDeTexto(controlador: controladorMatricula),          
          CuadroDeTexto(controlador: controladorMarca),
          CuadroDeTexto(controlador: controladorModelo),
          CuadroDeTexto(controlador: controladorColor),
          CuadroDeTexto(controlador: controladorAno),
          TextButton(
            onPressed: funcionOnClick, 
            child: Text(obtenerTexto())
          ),
        ],
      ),
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
  });

  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      decoration: const InputDecoration(
        hintText: "", 
        prefixIcon: Icon(Icons.access_alarm_outlined),
        prefixIconColor: Colors.red,
        suffixIcon: Icon(Icons.password)
      ),

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