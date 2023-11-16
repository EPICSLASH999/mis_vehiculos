import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- VEHICULOS --------------------------------- */

// Widget Principal (Menu Principal)
class WidgetMisVehiculos extends StatelessWidget {
  final Future <List<Vehiculo>>? misVehiculos;

  const WidgetMisVehiculos({super.key, required this.misVehiculos});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoConsultarGastosArchivados());
            }, 
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
      bottomNavigationBar: BarraInferior(indiceSeleccionado: indiceMisVehiculos),
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
                        return TileVehiculo(vehiculo: vehiculo);
                      }, 
                    );
                }
              },
            ),
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
      trailing: BotonesTileVehiculo(vehiculo: vehiculo),
      onTap: () {
      },
    );
  }
}

class BotonesTileVehiculo extends StatelessWidget {
  const BotonesTileVehiculo({
    super.key,
    required this.vehiculo,
  });

  final Vehiculo vehiculo;

  Function eliminarVehiculo(BuildContext context){
    return (){
      context.read<VehiculoBloc>().add(EliminadoVehiculo(id: vehiculo.id));
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Row(
        children: [
          IconButton(
            onPressed: dialogoAlerta(context: context, texto: '¿Seguro de eliminar este vehículo?', funcionAlProceder: eliminarVehiculo(context)),
            icon: Icon(Icons.delete, color: colorIcono)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarVehiculo(vehiculo: vehiculo));
            }, 
            icon: Icon(Icons.edit, color: colorIcono)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoAgregarGasto(idVehiculo: vehiculo.id));
            }, 
            icon: Icon(Icons.add_card_outlined, color: colorIcono)
          ),
        ],
      ),
    );
  }
}

class WidgetPlantillaVehiculo extends StatefulWidget {
  final Vehiculo? vehiculo;
  final Future<List<String>>? matriculasVehiculos;
  const WidgetPlantillaVehiculo({super.key, this.vehiculo, this.matriculasVehiculos});

  @override
  State<WidgetPlantillaVehiculo> createState() => _WidgetPlantillaVehiculoState();
}

class _WidgetPlantillaVehiculoState extends State<WidgetPlantillaVehiculo> {
  final TextEditingController controladorMatricula = TextEditingController();
  final TextEditingController controladorMarca = TextEditingController();
  final TextEditingController controladorModelo = TextEditingController();
  final TextEditingController controladorColor = TextEditingController();
  final TextEditingController controladorAno = TextEditingController();

  bool get esEditar => widget.vehiculo != null;
  String obtenerTexto() => (!esEditar)? 'Agregar Vehiculo':'Editar Vehiculo';
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
    if (!esEditar) return;
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
      bottomNavigationBar: BarraInferior(indiceSeleccionado: indiceMisVehiculos),
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Add TextFormFields and ElevatedButton here.
              CuadroDeTextoMatricula(matriculasVehiculos: widget.matriculasVehiculos, controladorMatricula: controladorMatricula, titulo: 'Matricula'),
              CuadroDeTexto(controlador: controladorMarca, titulo: 'Marca'),
              CuadroDeTexto(controlador: controladorModelo, titulo: 'Modelo'),
              CuadroDeTexto(controlador: controladorColor, titulo: 'Color', maxCaracteres: 15,),
              CuadroDeTexto(controlador: controladorAno, titulo: 'Año', esInt: true, maxCaracteres: 4, minCaracteres: 4,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!esEditar) {
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

class CuadroDeTextoMatricula extends StatelessWidget {
  CuadroDeTextoMatricula({
    super.key,
    required this.matriculasVehiculos,
    required this.controladorMatricula, 
    required this.titulo,
  });

  final Future<List<String>>? matriculasVehiculos;
  final TextEditingController controladorMatricula;
  final String titulo;

  final bool campoRequerido = true;
  final int maxCaracteres = 7;
  final int minCaracteres = 4;

  final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@%&/\><:,;_~`+=' 
      "'" 
      ']'
    );


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: matriculasVehiculos, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const WidgetCargando();
        } else{
          final matriculasVehiculos = snapshot.data?? [];

          //return ValodadorDeMatricula(controlador: controladorMatricula, titulo: titulo, maxCaracteres: 7, minCaracteres: 4, matriculasVehiculos: matriculasVehiculos,);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TituloComponente(titulo: titulo),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    String valorNormalizado = (value??'').trim();
                    if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
                    if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
                    if(valorNormalizado.length < minCaracteres) return 'Debe tener al menos $minCaracteres caracteres';
                    if(matriculasVehiculos.contains(valorNormalizado)) return 'Matricula ya existente';
                    return null;
                  },
                  maxLength: maxCaracteres,
                  controller: controladorMatricula,
                  decoration: const InputDecoration(
                    hintText: "", 
                    prefixIcon: Icon(Icons.label_important),
                    prefixIconColor: Colors.red,
                    suffixIcon: Icon(Icons.car_rental)
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
/*
class ValodadorDeMatricula extends StatelessWidget {
  const ValodadorDeMatricula({
    super.key,
    required this.controlador,
    required this.titulo, 
    this.campoRequerido = true,
    this.maxCaracteres = 20, 
    this.minCaracteres, 
    required this.matriculasVehiculos,
  });

  final TextEditingController controlador;
  final String titulo;
  final bool campoRequerido;
  final int maxCaracteres;
  final int? minCaracteres;
  final List<String> matriculasVehiculos;

  InputDecoration obtenerDecoracion(){
    if (campoRequerido){
      return const InputDecoration(
        hintText: "", 
        prefixIcon: Icon(Icons.label_important),
        prefixIconColor: Colors.red,
        suffixIcon: Icon(Icons.car_rental)
      );
    }
    return const InputDecoration(
      hintText: "", 
      suffixIcon: Icon(Icons.car_rental)
    );
  }

  @override
  Widget build(BuildContext context) {
    final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@%&/\><:,;_~`+=' 
      "'" 
      ']'
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TituloComponente(titulo: titulo),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              String valorNormalizado = (value??'').trim();
              if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
              if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
              if(minCaracteres != null && valorNormalizado.length < minCaracteres!) return 'Debe tener al menos $minCaracteres caracteres';
              if(matriculasVehiculos.contains(valorNormalizado)) return 'Matricula ya existente';
              return null;
            },
            maxLength: maxCaracteres,
            controller: controlador,
            decoration: obtenerDecoracion(),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}*/

/* ----------------------------------------------------------------------------- */