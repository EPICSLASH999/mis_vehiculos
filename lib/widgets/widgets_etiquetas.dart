import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- ETIQUETAS --------------------------------- */
class WidgetMisEtiquetas extends StatelessWidget {
  const WidgetMisEtiquetas({super.key, required this.misEtiquetas});

  final Future <List<Etiqueta>>? misEtiquetas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Etiquetas'),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisEtiquetas),
      body: FutureBuilder<List<Etiqueta>>(
        future: misEtiquetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const WidgetCargando();
          } else{
            final etiquetas = snapshot.data?? [];
            etiquetas.removeWhere((element) => (element.id == idSinEtiqueta)); // Remueve la etiqueta 'Desconocida' de la lista.

            return etiquetas.isEmpty
                ? const Center(
                  child: Text(
                    'Sin etiquetas...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                )
              : ListView.separated(
                separatorBuilder: (context, index) => 
                    const SizedBox(height: 12,), 
                itemCount: etiquetas.length,
                itemBuilder: (context, index) {
                  final etiqueta = etiquetas[index];
                  return TileEtiqueta(etiqueta: etiqueta);
                }, 
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<VehiculoBloc>().add(ClickeadoAgregarEtiqueta());
        },
      ),
    );
  }
}

class TileEtiqueta extends StatelessWidget {
  const TileEtiqueta({
    super.key,
    required this.etiqueta,
  });

  final Etiqueta etiqueta;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        etiqueta.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: BotonesTileEtiqueta(etiqueta: etiqueta),
      onTap: null,
    );
  }
}

class BotonesTileEtiqueta extends StatelessWidget {
  const BotonesTileEtiqueta({
    super.key,
    required this.etiqueta,
  });

  final Etiqueta etiqueta;

  Function eliminarEtiqueta(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadaEtiqueta(id: etiqueta.id));
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        children: [
          IconButton(
            onPressed: dialogoAlerta(context: context, texto: '¿Seguro de eliminar esta etiqueta?', funcionAlProceder: eliminarEtiqueta(context)), 
            icon: const Icon(Icons.delete, color: colorIcono)
          ),
          IconButton(
            onPressed: () {
              context.read<VehiculoBloc>().add(ClickeadoEditarEtiqueta(etiqueta: etiqueta));
            }, 
            icon: const Icon(Icons.edit, color: colorIcono)
          ),
        ],
      ),
    );
  }
}

class WidgetPlantillaEtiqueta extends StatelessWidget {
  final Etiqueta? etiqueta;
  WidgetPlantillaEtiqueta({super.key, this.etiqueta});

  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController controladorNombre = TextEditingController();

  Etiqueta obtenerEtiqueta(){
    return Etiqueta(
      id: (etiqueta?.id)??0, 
      nombre: controladorNombre.text, 
    );
  }
  String obtenerTexto() => "${(etiqueta == null)? 'Agregar':'Editar'} Etiqueta";
  void inicializarValoresDeControladores(){
    if (etiqueta == null) return;
    controladorNombre.text = etiqueta?.nombre??'';
  }

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();

    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTexto()),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAAdministradorEtiquetas());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisEtiquetas),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              CuadroDeTexto(controlador: controladorNombre, titulo: 'Nombre'),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (etiqueta == null) {
                      context.read<VehiculoBloc>().add(AgregadoEtiqueta(nombreEtiqueta: controladorNombre.text));
                      return;
                    }
                    context.read<VehiculoBloc>().add(EditadoEtiqueta(etiqueta: obtenerEtiqueta()));
                  }
                },
                child: Text(obtenerTexto()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/* ----------------------------------------------------------------------------- */
