import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_etiquetas.dart';
import 'package:mis_vehiculos/widgets/widgets_gastos.dart';
import 'package:mis_vehiculos/widgets/widgets_gastos_archivados.dart';
import 'package:mis_vehiculos/widgets/widgets_vehiculos.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([ // Para que solo permita orientación vertical
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

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
    var state = context.watch<VehiculoBloc>().state;

    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
      ).copyWith(),      
    ),
      home: WillPopScope( // Esto se encarga del botón "Return" del celular.
        onWillPop: () {
          if (state is MisGastosArchivados) {
            context.read<VehiculoBloc>().add(ClickeadoregresarAConsultarGastos());
            return Future(() => false);
          }
          if (state is PlantillaEtiqueta) {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAAdministradorEtiquetas());
            return Future(() => false);
          }
          if(state is PlantillaGasto && state.esEditarGasto){
            context.read<VehiculoBloc>().add(ClickeadoregresarAConsultarGastos());
            return Future(() => false);
          }
          if (state is MisEtiquetas && state.estaModoSeleccionActivo){
            context.read<VehiculoBloc>().add(CambiadaModalidadSeleccionEtiqueta(estaModoSeleccionActivo: false));
            return Future(() => false);
          }
          if (state is MisGastos && state.tipoReporte != TipoReporte.year){
            context.read<VehiculoBloc>().add(ClickeadoRegresarDesdeGastos());
            return Future(() => false);
          }
          if (state is MisVehiculos){
            if (state.estaModoSeleccionActivo){
              context.read<VehiculoBloc>().add(CambiadaModalidadSeleccionVehiculo(estaModoSeleccionActivo: false));
              return Future(() => false);
            }
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos(reiniciarBusquedaDeVehiculos: true));
            return Future(() => false);
          }
          context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          return Future(() => false);
        }, 
        child: BlocBuilder<VehiculoBloc, VehiculoEstado>(
          builder: (context, state) {
            if (state is MisVehiculos) return WidgetMisVehiculos(misVehiculos: state.misVehiculos, buscarVehiculosQueContengan: state.buscarVehiculosQueContengan,);
            if (state is PlantillaVehiculo) return WidgetPlantillaVehiculo(vehiculo: state.vehiculo,);
            if (state is PlantillaGasto) return WidgetPlantillaGasto(idVehiculo: state.idVehiculo, gasto: state.gasto, listaMecanicoPorEtiqueta: state.listaMecanicoPorEtiqueta, fueAgregadaUnaEtiquetaDesdeGasto: state.agregadaEtiquetaDesdeGasto, esEditarGasto: state.esEditarGasto,);
            if (state is MisEtiquetas) return WidgetMisEtiquetas(misEtiquetas: state.misEtiquetas,);
            if (state is PlantillaEtiqueta) return WidgetPlantillaEtiqueta(etiqueta: state.etiqueta,);
            if (state is MisGastos) return WidgetMisGastos(misGastos: state.misGastos, fechaSeleccionadaInicial: state.fechaInicial, fechaSeleccionadaFinal: state.fechaFinal, misEtiquetas: state.misEtiquetas, idEtiquetaSeleccionada: state.filtroIdEtiqueta, idVehiculoSeleccionado: state.filtroIdVehiculo, misVehiculos: state.misVehiculos, filtroMecanico: state.filtroMecanico,);
            if (state is MisGastosArchivados) return WidgetMisGastosArchivados(misGastosArchivados: state.misGastosArchivados, vehiculoSeleccionado: state.vehiculoSeleccionado, misVehiculosArchivados: state.misVehiculosArchivados,);
            return const WidgetCargando();
          },
        )
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

