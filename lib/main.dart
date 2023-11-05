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
                                context.read<VehiculoBloc>().add(EditadoVehiculo(vehiculo: vehiculo));
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
          Vehiculo vehiculo = const Vehiculo(id: 1, matricula: 'xxx-1', marca: 'Toyota', modelo: 'Camry', color: 'Plateada', ano: 1969);
          context.read<VehiculoBloc>().add(AgregadoVehiculo(vehiculo: vehiculo));
        },
      ),
    );
  }
}

class WidgetPlantillaVehiculo extends StatelessWidget {
  const WidgetPlantillaVehiculo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class WidgetCargando extends StatelessWidget {
  const WidgetCargando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}