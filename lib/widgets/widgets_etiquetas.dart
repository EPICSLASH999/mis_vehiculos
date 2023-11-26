import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- ETIQUETAS --------------------------------- */

class WidgetMisEtiquetas extends StatelessWidget {
  const WidgetMisEtiquetas({super.key, required this.misEtiquetas, required this.etiquetasSeleccionadas});

  final Future <List<Etiqueta>>? misEtiquetas;
  final List<int> etiquetasSeleccionadas;

  Function eliminarEtiquetas(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadasEtiquetasSeleccionadas());
    };
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<VehiculoBloc>().state;
    bool modoSeleccion = false;
    List<int> etiquetasSeleccionadas = [];
    if (state is MisEtiquetas){
      modoSeleccion = state.modoSeleccion;
      etiquetasSeleccionadas = state.etiquetasSeleccionadas;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Etiquetas'),
        leading: IconButton(
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
        actions: [
          IconButton(
            onPressed: !(modoSeleccion && etiquetasSeleccionadas.isNotEmpty)?null:
              dialogoAlerta(context: context, texto: '¿Seguro de eliminar las etiquetas seleccionadas?', funcionAlProceder: eliminarEtiquetas(context), titulo: 'Eliminar'),
            icon: const Icon(Icons.delete_forever))
          ,
          IconButton(
            onPressed: !modoSeleccion?null:() {
              context.read<VehiculoBloc>().add(DeseleccionadasEtiquetas());
            }, 
            icon: const Icon(Icons.close)
          ),
        ],
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisEtiquetas),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Etiqueta>>(
              future: misEtiquetas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final etiquetas = snapshot.data?? [];
            
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
                        return TileEtiqueta(etiqueta: etiqueta, indice: etiqueta.id, estaSeleccionada: etiquetasSeleccionadas.contains(etiqueta.id), modoSeleccion: modoSeleccion,);
                      }, 
                    );
                }
              },
            ),
          ),
          if(!modoSeleccion) Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<VehiculoBloc>().add(ClickeadoAgregarEtiqueta());
              }, 
              icon: const Icon(Icons.add), 
              label: const Text('Agregar Etiqueta'),
            ),
          )
        ],
      ),
    );
  }
}

class TileEtiqueta extends StatelessWidget {
  const TileEtiqueta({
    super.key,
    required this.etiqueta, 
    required this.indice, 
    required this.estaSeleccionada, 
    required this.modoSeleccion,
  });

  final Etiqueta etiqueta;
  final int indice;
  final bool estaSeleccionada;
  final bool modoSeleccion;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        etiqueta.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: modoSeleccion?null: IconButton(
        onPressed: () {
          context.read<VehiculoBloc>().add(ClickeadoEditarEtiqueta(etiqueta: etiqueta));
        }, 
        icon: const Icon(Icons.edit, color: colorIcono,)
      ),
      onTap: !modoSeleccion?null:() {
        context.read<VehiculoBloc>().add(SeleccionadaEtiqueta(etiquetaSeleccionada: indice));
      },
      onLongPress: modoSeleccion?null:() {
        context.read<VehiculoBloc>().add(SeleccionadaEtiqueta(etiquetaSeleccionada: indice));
      },
      selected: estaSeleccionada,
      selectedColor: Colors.black,
      selectedTileColor: colorTileSeleccionado,
    );
  }
}

class WidgetPlantillaEtiqueta extends StatelessWidget {
  final Etiqueta? etiqueta;
  final Future<List<String>>? nombresEtiquetas;
  WidgetPlantillaEtiqueta({super.key, this.etiqueta, this.nombresEtiquetas});

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
              CuadroDeTextoEtiqueta(controlador: controladorNombre, titulo: 'Nombre', focusTecaldo: true, icono: const Icon(Icons.label),),
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

class CuadroDeTextoEtiqueta extends StatelessWidget {
  const CuadroDeTextoEtiqueta({
    super.key,
    required this.controlador,
    required this.titulo, 
    this.campoRequerido = true,
    this.maxCaracteres = 20, 
    this.minCaracteres,
    this.focusTecaldo = false, 
    this.icono,
  });

  final TextEditingController controlador;
  final String titulo;
  final bool campoRequerido;
  final int maxCaracteres;
  final int? minCaracteres;
  final bool focusTecaldo;
  final Icon? icono;

  bool esNumerico(String? s) {
    if(s == null) return false;    
    return double.tryParse(s) != null;
  }
  InputDecoration obtenerDecoracion({Icon? icono}){
    if (campoRequerido) return obtenerDecoracionCampoObligatorio(hintText: 'Gasolina', icono: icono);
    return obtenerDecoracionCampoOpcional(icono: icono);
  }
  bool existeEtiqueta(List<String> etiquetas, String etiquetaRecibida){
    for (var etiqueta in etiquetas) {
      if(etiqueta.equalsIgnoreCase(etiquetaRecibida)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@#%&/\><:,.;_~`+=' 
      "'" 
      ']'
    );
    bool esPrimerClic = true;

    Future<List<String>>? nombresEtiquetas;
    var state = context.watch<VehiculoBloc>().state;
    if (state is PlantillaEtiqueta){
      nombresEtiquetas = state.nombresEtiquetas;
    }

    return FutureBuilder(
      future: nombresEtiquetas, 
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
          return const WidgetCargando();
        } else {
          final nombresEtiquetas = snapshot.data ?? [];

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
                    if(esNumerico(valorNormalizado)) return 'Campo inválido';
                    if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
                    if(minCaracteres != null && (valorNormalizado.length < minCaracteres!)) return 'Debe tener al menos $minCaracteres caracteres';
                    if (existeEtiqueta(nombresEtiquetas, valorNormalizado)) return 'Etiqueta ya existente';
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: maxCaracteres,
                  controller: controlador,
                  decoration: obtenerDecoracion(icono: icono),
                  keyboardType: TextInputType.text,
                  autofocus: focusTecaldo,
                  onTap: () { 
                    if(!esPrimerClic) return;
                    controlador.selectAll(); // Seleccionar todo el texto.
                    esPrimerClic = !esPrimerClic;
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/* ----------------------------------------------------------------------------- */
