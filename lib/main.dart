import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/widgets/widgets_etiquetas.dart';
import 'package:mis_vehiculos/widgets/widgets_gastos.dart';
import 'package:mis_vehiculos/widgets/widgets_gastos_archivados.dart';
import 'package:mis_vehiculos/widgets/widgets_vehiculos.dart';

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
      theme: ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
      ).copyWith(),      
    ),
      home: BlocBuilder<VehiculoBloc, VehiculoEstado>(
        builder: (context, state) {
          if (state is MisVehiculos) return WidgetMisVehiculos(misVehiculos: state.misVehiculos, idsVehiculosSeleccionados: state.idsVehiculosSeleccionados,);
          if (state is PlantillaVehiculo) return WidgetPlantillaVehiculo(vehiculo: state.vehiculo,);
          if (state is PlantillaGasto) return WidgetPlantillaGasto(idVehiculo: state.idVehiculo, misEtiquetas: state.misEtiquetas, gasto: state.gasto,);
          if (state is MisEtiquetas) return WidgetMisEtiquetas(misEtiquetas: state.misEtiquetas,);
          if (state is PlantillaEtiqueta) return WidgetPlantillaEtiqueta(etiqueta: state.etiqueta);
          if (state is MisGastos) return WidgetMisGastos(misGastos: state.misGastos, fechaSeleccionadaInicial: state.fechaInicial, fechaSeleccionadaFinal: state.fechaFinal, misEtiquetas: state.misEtiquetas, idEtiquetaSeleccionada: state.filtroIdEtiqueta,);
          if (state is MisGastosArchivados) return WidgetMisGastosArchivados(misGastosArchivados: state.misGastosArchivados,);
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

