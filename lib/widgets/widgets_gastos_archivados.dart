import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
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

                return IconButton(
                  onPressed: gastosArchivados.isEmpty?null:dialogoAlerta(context: context, texto: '¿Seguro de eliminar todos los gastos archivados de: ${obtenerVehiculoSeleccionado()}?', funcionAlProceder: eliminarGastosArchivados(context), titulo: 'Eliminar'), 
                  icon: const Icon(Icons.delete_forever)
                );
              }
            },
          ),
        ],
      ),      
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisGastos),
      body: Column(
        children: [
          //FiltroSeleccionadorVehiculo(vehiculoSeleccionado: vehiculoSeleccionado, titulo: 'Vehiculo', misVehiculos: misVehiculosArchivados),
          DropDownSearch(misVehiculos: misVehiculosArchivados, matriculaVehiculoSeleccionado: vehiculoSeleccionado, titulo: 'Vehiculo'),
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

//Rama DE dROPdOWNbUTTON_2--
/* ----------------------------------- PRUEBAS ----------------------------------- */
class DropDownSearch extends StatefulWidget {
  const DropDownSearch({super.key, required this.misVehiculos, required this.matriculaVehiculoSeleccionado, required this.titulo});

  final Future<List<String>>? misVehiculos;
  final String matriculaVehiculoSeleccionado;
  final String titulo;

  @override
  State<DropDownSearch> createState() => _DropDownSearchState();
}

class _DropDownSearchState extends State<DropDownSearch> {
  final TextEditingController textEditingController = TextEditingController(); // Controlador propio de este widget. NO ALTERAR.
  String? matriculaVehiculoSeleccionado;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    matriculaVehiculoSeleccionado = widget.matriculaVehiculoSeleccionado;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TituloComponente(titulo: widget.titulo),
          ),
          FutureBuilder<List<String>>(
            future: widget.misVehiculos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return const WidgetCargando();
              } else{
                final vehiculos = snapshot.data?? [];
                List<String> listaVehiculosMatriculas = vehiculos.copiar();
                listaVehiculosMatriculas.insert(0,valorOpcionTodas.toString()); // Agrega la opción de 'Todos' al filtro.
    
                return DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Vehiculo...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: listaVehiculosMatriculas
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                (item != valorOpcionTodas.toString())?item:'Todos',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: matriculaVehiculoSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        matriculaVehiculoSeleccionado = value;
                        
                      });
                      context.read<VehiculoBloc>().add(FiltradoGastoArchivadoPorVehiculo(matricula: matriculaVehiculoSeleccionado!));
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
                      maxHeight: 200,
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
                            hintText: 'Matricula...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return (item.value.toString().containsIgnoreCase(searchValue) 
                         || item.value.toString().containsIgnoreCase(valorOpcionTodas.toString())); // Filtrar por matrícula.
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