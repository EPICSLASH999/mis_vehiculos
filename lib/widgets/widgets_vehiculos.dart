import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoConsultarGastosArchivados());
            }, 
            icon: const Icon(Icons.folder_copy)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoAdministrarEtiquetas());
            }, 
            icon: const Icon(Icons.label),
          )
        ],
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
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Add TextFormFields and ElevatedButton here.
              CuadroDeTexto(controlador: controladorMatricula, titulo: 'Matricula', maxCaracteres: 7,),          
              CuadroDeTexto(controlador: controladorMarca, titulo: 'Marca'),
              CuadroDeTexto(controlador: controladorModelo, titulo: 'Modelo'),
              CuadroDeTexto(controlador: controladorColor, titulo: 'Color', maxCaracteres: 15,),
              CuadroDeTexto(controlador: controladorAno, titulo: 'Año', esInt: true, maxCaracteres: 4,),
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

/* ----------------------------------------------------------------------------- */