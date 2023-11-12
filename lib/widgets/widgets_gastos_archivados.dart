import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';

/* ------------------------------ GASTOS ARCHIVADOS------------------------------ */
class WidgetMisGastosArchivados extends StatelessWidget {
  const WidgetMisGastosArchivados({super.key, required this.misGastosArchivados});

  final Future<List<GastoArchivado>>? misGastosArchivados;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos Archivados'),
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
  String get mecanico => (gastoArchivado.mecanico.isNotEmpty)? gastoArchivado.mecanico:'Sin mecánico';
  String get lugar => (gastoArchivado.lugar.isNotEmpty)? gastoArchivado.lugar:'Sin lugar';
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
      onTap: () {
      },
    );
  }
}
/* ----------------------------------------------------------------------------- */
