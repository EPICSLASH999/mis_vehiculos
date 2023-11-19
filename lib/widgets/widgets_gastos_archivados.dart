import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* ------------------------------ GASTOS ARCHIVADOS------------------------------ */
class WidgetMisGastosArchivados extends StatelessWidget {
  const WidgetMisGastosArchivados({super.key, required this.misGastosArchivados, required this.vehiculoSeleccionado, required this.misVehiculosArchivados});

  final Future<List<GastoArchivado>>? misGastosArchivados;
  final String vehiculoSeleccionado;
  final Future<List<String>>? misVehiculosArchivados;
  
  Function eliminarGastosArchivados(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadosGastosArchivados(matricula: vehiculoSeleccionado));
    };
  }
  String obtenerVehiculoSeleccionado(){
    if(vehiculoSeleccionado == valorOpcionTodas.toString()) return 'Todos';
    return vehiculoSeleccionado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos Archivados'),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
        actions: [
          FutureBuilder(
            future: misGastosArchivados, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final gastosArchivados = snapshot.data?? [];

                return IconButton(
                  onPressed: gastosArchivados.isEmpty?null:dialogoAlerta(context: context, texto: '¿Seguro de eliminar todos los gastos archivados de: ${obtenerVehiculoSeleccionado()}?', funcionAlProceder: eliminarGastosArchivados(context), titulo: 'Eliminar'), 
                  icon: const Icon(Icons.delete_forever)
                );
              }
            },
          ),
        ],
      ),      
      body: Column(
        children: [
          FiltroSeleccionadorVehiculo(vehiculoSeleccionado: vehiculoSeleccionado, titulo: 'Vehiculo', misVehiculos: misVehiculosArchivados),
          Expanded(
            child: 
            FutureBuilder<List<GastoArchivado>>(
              future: misGastosArchivados,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final gastosArchivados = snapshot.data?? [];

                  return gastosArchivados.isEmpty
                    ? const Center(
                      child: Text(
                        'Sin gastos archivados...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    )
                  : ListView.separated(
                    separatorBuilder: (context, index) => 
                        const SizedBox(height: 12,), 
                    itemCount: gastosArchivados.length,
                    itemBuilder: (context, index) {
                      final gastoArchivado = gastosArchivados[index];
                      return TileGastoArchivado(gastoArchivado: gastoArchivado);
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

class TileGastoArchivado extends StatelessWidget {
  const TileGastoArchivado({
    super.key,
    required this.gastoArchivado, 
  });

  final GastoArchivado gastoArchivado;
  String get mecanico => (gastoArchivado.mecanico.isNotEmpty)? gastoArchivado.mecanico:valorSinMecanico;
  String get lugar => (gastoArchivado.lugar.isNotEmpty)? gastoArchivado.lugar:valorSinLugar;
  String get fechaNormalizada {
    DateTime fechaRecibida = DateTime.parse(DateTime.parse(gastoArchivado.fecha).toIso8601String());
    return DateFormat.yMMMd().format(fechaRecibida);
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Text(
        gastoArchivado.etiqueta,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fechaNormalizada),
          Text(gastoArchivado.vehiculo),
          Text(mecanico),
          Text(lugar),
          Text('\$${gastoArchivado.costo}'),
        ],
      ),
      onTap: null,
    );
  }
}

class FiltroSeleccionadorVehiculo extends StatelessWidget{
  const FiltroSeleccionadorVehiculo({
    super.key,
    required this.vehiculoSeleccionado,
    required this.titulo, 
    required this.misVehiculos
  });

  final String vehiculoSeleccionado;
  final String titulo;
  final Future <List<String>>? misVehiculos;

  @override
  Widget build(BuildContext context)  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TituloComponente(titulo: titulo),
          SizedBox(
            width: 160,
            child: FutureBuilder<List<String>>(
              future: misVehiculos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final vehiculos = snapshot.data?? [];
                  
                  return DropdownButtonFormField(
                    validator: (value) {
                      return null;
                    },
                    value: vehiculoSeleccionado,
                    items: [
                      DropdownMenuItem(value: valorOpcionTodas.toString(), child: const Text('Todos')),
                      for(var vehiculo in vehiculos) DropdownMenuItem(value: vehiculo, child: Text(vehiculo),)
                    ],
                    onChanged: (value) {
                      context.read<VehiculoBloc>().add(FiltradoGastoArchivadoPorVehiculo(matricula: value as String));
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

/* ----------------------------------------------------------------------------- */
