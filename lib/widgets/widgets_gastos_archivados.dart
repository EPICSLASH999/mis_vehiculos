import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/database/tablas/vehiculos.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/funciones/funciones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/gasto_archivado.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* ------------------------------ GASTOS ARCHIVADOS------------------------------ */
class WidgetMisGastosArchivados extends StatelessWidget {
  const WidgetMisGastosArchivados({
    super.key, 
    required this.misGastosArchivados, 
    required this.idVehiculoSeleccionado, 
    required this.misVehiculosArchivados, 
    required this.fechaSeleccionadaFinal, 
    required this.fechaSeleccionadaInicial
  });

  final Future<List<GastoArchivado>>? misGastosArchivados;
  final int idVehiculoSeleccionado;
  final Future<List<Vehiculo>>? misVehiculosArchivados;

  final DateTime fechaSeleccionadaFinal;
  final DateTime fechaSeleccionadaInicial;
  
  Function eliminarGastosArchivados(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadosGastosArchivados(idVehiculo: idVehiculoSeleccionado));
    };
  }
  String obtenerNombreVehiculoSeleccionado(List<GastoArchivado> gastosArchivados){
    if(idVehiculoSeleccionado == valorOpcionTodas) return 'Todos';
    GastoArchivado gastoArchivado = gastosArchivados.where((element) => element.idVehiculo == idVehiculoSeleccionado).first;
    return '${gastoArchivado.modeloVehiculo} - ${gastoArchivado.vehiculo}';
  }
  Function restaurarGastosArchivados (BuildContext context) {
    return () {
      context.read<VehiculoBloc>().add(RestauradosGastosArchivados(idVehiculo: idVehiculoSeleccionado));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos Archivados'),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoregresarAConsultarGastos());
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

                return Row(
                  children: [
                    IconButton( // Botón Borrar GastosArchivados.
                      onPressed: gastosArchivados.isEmpty
                          ?null:
                          dialogoAlerta(
                            context: context, 
                            texto: '¿Seguro de eliminar todos los gastos archivados de: ${obtenerNombreVehiculoSeleccionado(gastosArchivados)}?', 
                            funcionAlProceder: eliminarGastosArchivados(context), 
                            titulo: 'Eliminar'
                          ), 
                      icon: const Icon(Icons.delete_forever)
                    ),
                    if (!(gastosArchivados.isEmpty || idVehiculoSeleccionado == valorOpcionTodas)) IconButton( // Botón Restaurar GastosArchivados.
                      onPressed: (gastosArchivados.isEmpty || idVehiculoSeleccionado == valorOpcionTodas)
                          ? null:
                          dialogoAlerta(
                            context: context, 
                            texto: '¿Seguro de restaurar todos los gastos archivados de: ${obtenerNombreVehiculoSeleccionado(gastosArchivados)}?', 
                            funcionAlProceder: restaurarGastosArchivados(context), 
                            titulo: 'Restaurar', 
                            colorTextoSi: Colors.blue
                          ), 
                      icon: const Icon(Icons.restore)
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),      
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisGastos),
      body: Column(
        children: [
          FiltroParaRangoFechas(fechaSeleccionadaInicial: fechaSeleccionadaInicial, fechaSeleccionadaFinal: fechaSeleccionadaFinal),
          FiltroVehiculo(misVehiculosArchivados: misVehiculosArchivados, idVehiculoSeleccionado: idVehiculoSeleccionado, titulo: 'Vehiculo'),
          Expanded(
            child: 
            FutureBuilder<List<GastoArchivado>>(
              future: misGastosArchivados,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final gastosArchivados = snapshot.data?? [];

                  var gastosArchivadosFiltrados = gastosArchivados.copiar();
                  gastosArchivadosFiltrados.removeWhere((element) => 
                  !((DateTime.parse(element.fecha).isAfter(fechaSeleccionadaInicial))  && ((DateTime.parse(element.fecha)).isBefore(fechaSeleccionadaFinal))));

                  return gastosArchivadosFiltrados.isEmpty
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
                    itemCount: gastosArchivadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final gastoArchivado = gastosArchivadosFiltrados[index];
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

  // Variables
  final GastoArchivado gastoArchivado;
  
  // Getters y métodos
  String get mecanico => (gastoArchivado.mecanico.isNotEmpty)? gastoArchivado.mecanico:valorSinMecanico;
  String get lugar => (gastoArchivado.lugar.isNotEmpty)? gastoArchivado.lugar:valorSinLugar;
  String get fechaNormalizada {
    DateTime fechaRecibida = DateTime.parse(DateTime.parse(gastoArchivado.fecha).toIso8601String());
    return DateFormat.yMMMd().format(fechaRecibida);
  }

  Function eliminarGastoArchivado(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadoGastoArchivado(idGastoArchivado: gastoArchivado.id));
    };
  }
  Function restaurarGastoArchivado (BuildContext context, bool existeVehiculo) {
    return () {
      context.read<VehiculoBloc>().add(RestauradoGastoArchivado(gastoArchivado: gastoArchivado, debeRestaurarVehiculo: false));
    };
  }
  Future<bool> existeVehiculo(int idVehiculo) async {
    Vehiculo? vehiculo = await Vehiculos().fetchById(idVehiculo);
    return (vehiculo != null);
  }
  
  Future<String?> cuadroDeDialogoRestaurarVehiculo(BuildContext context) {
    return showDialog<String>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Vehiculo ya no existe'),
        content: const Text('¿Desea restaurar el vehículo?'),
        actions: [
          TextButton( // Botón Restaurar Vehículo.
            onPressed: () {
              context.read<VehiculoBloc>().add(RestauradoGastoArchivado(gastoArchivado: gastoArchivado, debeRestaurarVehiculo: true));
              Navigator.of(context).pop();
            }, 
            child: const Text('Aceptar')
          ),
          TextButton( // Botón Cancelar.
            onPressed: () {
              Navigator.of(context).pop();
            }, 
            child: const Text('Cancelar')
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: existeVehiculo(gastoArchivado.idVehiculo), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const WidgetCargando();
        } else{
          final siExisteVehiculo = snapshot.data?? false;

          return  ListTile(
            title: Text(
              gastoArchivado.etiqueta,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fechaNormalizada),
                Text(gastoArchivado.modeloVehiculo, style: const TextStyle(fontStyle: FontStyle.italic)),
                Text(gastoArchivado.vehiculo),
                Text(mecanico),
                Text(lugar),
                Text('\$${gastoArchivado.costo}'),
              ],
            ),
            trailing: SizedBox(
              width: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton( // Botón borar gasto arhivado
                    onPressed: dialogoAlerta(context: context, texto: '¿Seguro de eliminar permanentemente el gasto archivado?', funcionAlProceder: eliminarGastoArchivado(context), titulo: 'Eliminar'), 
                    icon: const Icon(Icons.delete_forever, color: colorIcono,)
                  ),
                  IconButton( // Botón restaurar gasto archivado
                    onPressed: () {
                      if (!siExisteVehiculo){
                        // removido await del cuadroDeDialogo
                        cuadroDeDialogoRestaurarVehiculo(context);
                        return;
                      }
                      dialogoAlerta(context: context, texto: '¿Desea restaurar el gasto archivado?', funcionAlProceder: restaurarGastoArchivado(context, siExisteVehiculo), titulo: 'Restaurar', colorTextoSi: Colors.blue)();
                    },
                    icon: const Icon(Icons.restore, color: colorIcono,)
                  ),
                ],
              ),
            ),
            onTap: null,
          );
        }
      },
    );
  }
}

// Filtros
class FiltroParaRangoFechas extends StatelessWidget {
  FiltroParaRangoFechas({
    super.key, 
    required this.fechaSeleccionadaInicial,
    required this.fechaSeleccionadaFinal, 
  });

  final TextEditingController controladorFechaInicial = TextEditingController();
  final TextEditingController controladorFechaFinal = TextEditingController();
  
   final DateTime fechaSeleccionadaInicial;
   final DateTime fechaSeleccionadaFinal;

 
  void inicializarTextBoxesConFechas() {
    controladorFechaInicial.text = DateFormat.yMMMd().format(fechaSeleccionadaInicial);
    controladorFechaFinal.text = DateFormat.yMMMd().format(fechaSeleccionadaFinal);
  }

  @override
  Widget build(BuildContext context) {
    inicializarTextBoxesConFechas();
    DateTime fechaInicial = fechaSeleccionadaInicial;
    DateTime fechaFinal = fechaSeleccionadaFinal;

    VoidCallback funcionAlPresionarFechaInicial(BuildContext context){
      return () async {
        final vehiculoBloc = context.read<VehiculoBloc>();
        ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context); 
        DateTime? nuevaFecha = await showDatePicker(
          context: context, 
          initialDate: fechaInicial,
          firstDate: DateTime(1970), 
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.calendarOnly
        );
        if (nuevaFecha == null) return;
        if (!((nuevaFecha.isBefore(fechaFinal) || nuevaFecha.isAtSameMomentAs(fechaFinal)))) {
          mostrarToast(scaffoldMessengerState, 'Fecha Inicial debe ser menor a la Fecha Final');
          return;
        }
        fechaInicial = nuevaFecha;
        vehiculoBloc.add(FiltradoGastosArchivadosPorFecha(fechaInicial: fechaInicial, fechaFinal: fechaFinal));      
      };
    }
    VoidCallback funcionAlPresionarFechaFinal(BuildContext context){
      return () async {
        final vehiculoBloc = context.read<VehiculoBloc>();
        ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context); // Util para usar el conexto en una funcion async. Pero debe ir ANTES del await.
        DateTime? nuevaFecha = await showDatePicker(
          context: context, 
          initialDate: fechaFinal,
          firstDate: DateTime(1970), 
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.calendarOnly
        );
        if (nuevaFecha == null) return;
        if (!((nuevaFecha.isAfter(fechaInicial) || nuevaFecha.isAtSameMomentAs(fechaInicial)))) {
          mostrarToast(scaffoldMessengerState, 'Fecha Final debe ser mayor a la Fecha inicial');
          return;
        }
        //Formato: 2023-01-01 00:00:00.000
        DateTime fechaNormalizada = DateTime.parse('${nuevaFecha.year}-${normalizarNumeroA2DigitosFecha(nuevaFecha.month)}-${normalizarNumeroA2DigitosFecha(nuevaFecha.day)} 23:59:59.999');        
        fechaFinal = fechaNormalizada;
        vehiculoBloc.add(FiltradoGastosArchivadosPorFecha(fechaInicial: fechaInicial, fechaFinal: fechaFinal));      
      };
    }


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

class FiltroVehiculo extends StatefulWidget {
  const FiltroVehiculo({super.key, required this.misVehiculosArchivados, required this.idVehiculoSeleccionado, required this.titulo});

  final Future<List<Vehiculo>>? misVehiculosArchivados;
  final int idVehiculoSeleccionado;
  final String titulo;

  @override
  State<FiltroVehiculo> createState() => _FiltroVehiculoState();
}

class _FiltroVehiculoState extends State<FiltroVehiculo> {
  final TextEditingController textEditingController = TextEditingController(); // Controlador propio de este widget. NO ALTERAR.
  Vehiculo? vehiculoSeleccionado;
  final Vehiculo opcionTodosLosVehiculos = const Vehiculo(id: valorOpcionTodas, matricula: "Todos", marca: "", modelo: "", color: "", ano: 2000); // Opción por omisión 'Todos'

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //vehiculoSeleccionado = widget.idVehiculoSeleccionado;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TituloComponente(titulo: widget.titulo),
          ),
          FutureBuilder<List<Vehiculo>>(
            future: widget.misVehiculosArchivados,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final vehiculos = snapshot.data?? [];
                List<Vehiculo> listaVehiculosArchivados = vehiculos.copiar();
                listaVehiculosArchivados.insert(0,opcionTodosLosVehiculos); // Agrega la opción de 'Todos' al filtro.

                // Obtener vehiculo seleccionado
                vehiculoSeleccionado = listaVehiculosArchivados.where((element) => element.id == widget.idVehiculoSeleccionado).toList().first;
    
                return DropdownButtonHideUnderline(
                  child: DropdownButton2<Vehiculo>(
                    isExpanded: true,
                    hint: Text(
                      'Vehiculo...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: /*listaVehiculosArchivados
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                (item != valorOpcionTodas.toString())?item:'Todos',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),*/
                        listaVehiculosArchivados.map((item) => DropdownMenuItem(
                            value: item,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.id != valorOpcionTodas) Text(
                                  item.modelo,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ),
                                Text(
                                  item.matricula,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                
                              ],
                            ),
                          ))
                      .toList(),
                    value: vehiculoSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        vehiculoSeleccionado = value;
                        
                      });
                      context.read<VehiculoBloc>().add(FiltradoGastoArchivadoPorVehiculo(idVehiculo: vehiculoSeleccionado!.id));
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: widthDeComponente,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: alturaMaximaSearchbar,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: textEditingController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: textEditingController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Vehiculo...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return (item.value.toString().containsIgnoreCase(searchValue) 
                         || item.value.toString().containsIgnoreCase(valorOpcionTodas.toString())); // Filtrar por vehículo.
                      },
                    ),
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingController.clear();
                      }
                    },
                  ),
                );
              }
            }
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------------------ */

