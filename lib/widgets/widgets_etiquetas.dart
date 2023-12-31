import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- ETIQUETAS --------------------------------- */
// Pantalla Principal de Mis Etiquetas. Aqui se muestran todas.
class WidgetMisEtiquetas extends StatefulWidget {
  const WidgetMisEtiquetas({super.key, required this.misEtiquetas});

  final Future <List<Etiqueta>>? misEtiquetas; // Recibe las etiquetas futuras desde el bloc.

  @override
  State<WidgetMisEtiquetas> createState() => _WidgetMisEtiquetasState();
}
class _WidgetMisEtiquetasState extends State<WidgetMisEtiquetas> {

  /* ********************** SECCION PARA SELECCIONAR Y ELIMINAR ETIQUETAS ********************** */
  List<int> idsEtiquetasSeleccionadas = [];
  bool estaModoSeleccionActivo = false;

  Function eliminarEtiquetasSeleccionadas(BuildContext context){
    return () {
      context.read<VehiculoBloc>().add(EliminadasEtiquetasSeleccionadas(idsEtiquetasSeleccionadas: idsEtiquetasSeleccionadas));
      abortarSeleccionEtiquetas();
    };
  }
  void alSeleccionarEtiqueta(int idEtiqueta){
    setState(() {
      if (idsEtiquetasSeleccionadas.contains(idEtiqueta)){
        idsEtiquetasSeleccionadas..copiar()..remove(idEtiqueta);
        return;
      }
      idsEtiquetasSeleccionadas..copiar()..add(idEtiqueta);
    });
  }
  void alDejarPresionadaEtiqueta(int idEtiquetaPresionada){
    setState(() {
      estaModoSeleccionActivo = true;
      idsEtiquetasSeleccionadas..copiar()..add(idEtiquetaPresionada); // Selecciona la etiqueta que se dejó presionada.
    });
  }
  void abortarSeleccionEtiquetas(){
    setState(() {
      idsEtiquetasSeleccionadas = [];
      estaModoSeleccionActivo = false;
    });
  }
  /* ******************************************************************************************* */

  VoidCallback funcionAgregarEtiqueta(){
    return () {
      context.read<VehiculoBloc>().add(ClickeadoAgregarEtiqueta());
    };
  }

  @override
  Widget build(BuildContext context) {
    /* ********************** SECCION PARA SELECCIONAR Y ELIMINAR ETIQUETAS ********************** */
    estaModoSeleccionActivo = context.watch<VehiculoBloc>().estaModoSeleccionEtiquetasActivo;
    if (!estaModoSeleccionActivo) idsEtiquetasSeleccionadas = [];
    /* ******************************************************************************************* */
    
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
          if (estaModoSeleccionActivo) IconButton( // Botón de Borrar.
            onPressed: !(estaModoSeleccionActivo && idsEtiquetasSeleccionadas.isNotEmpty)?null:
              dialogoAlerta(context: context, texto: '¿Seguro de eliminar las etiquetas seleccionadas?', funcionAlProceder: eliminarEtiquetasSeleccionadas(context), titulo: 'Eliminar'),
            icon: const Icon(Icons.delete_forever)
          ),
          if (estaModoSeleccionActivo) IconButton( // Botón Cancelar Modo Selección de Etiquetas.
            onPressed: !estaModoSeleccionActivo?null:() {
              abortarSeleccionEtiquetas();
              context.read<VehiculoBloc>().add(CambiadaModalidadSeleccionEtiqueta(estaModoSeleccionActivo: false));
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
              future: widget.misEtiquetas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const WidgetCargando();
                } else{
                  final etiquetas = snapshot.data?? []; // Lista de Etiquetas recibida.
                  
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
                        return TileEtiqueta(
                          etiqueta: etiqueta, 
                          estaSeleccionada: idsEtiquetasSeleccionadas.contains(etiqueta.id), 
                          estaModoSeleccionActivo: estaModoSeleccionActivo, 
                          funcionAlSeleccionar: alSeleccionarEtiqueta,
                          funcionAlDejarPresionado: alDejarPresionadaEtiqueta,
                        );
                      }, 
                    );
                }
              },
            ),
          ),
          BotonAgregar(texto: 'Agregar Etiqueta', funcionAlPresionar: estaModoSeleccionActivo? null:funcionAgregarEtiqueta()),
        ],
      ),
    );
  }
}
class TileEtiqueta extends StatelessWidget {
  const TileEtiqueta({
    super.key,
    required this.etiqueta, 
    required this.estaSeleccionada, 
    required this.estaModoSeleccionActivo, 
    required this.funcionAlSeleccionar, 
    required this.funcionAlDejarPresionado,
  });

  final Etiqueta etiqueta;
  final bool estaSeleccionada;
  final bool estaModoSeleccionActivo;
  final Function(int) funcionAlSeleccionar;
  final Function(int) funcionAlDejarPresionado;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: iconoEtiqueta,
      title: Text(
        etiqueta.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: estaModoSeleccionActivo?null: IconButton( // Botón Editar Etiqueta.
        onPressed: () {
          context.read<VehiculoBloc>().add(ClickeadoEditarEtiqueta(etiqueta: etiqueta));
        }, 
        icon: const Icon(Icons.edit, color: colorIcono,)
      ),
      onTap: !estaModoSeleccionActivo?null:() {
        funcionAlSeleccionar(etiqueta.id);
      },
      onLongPress: estaModoSeleccionActivo?null:() {
        funcionAlDejarPresionado(etiqueta.id);
        context.read<VehiculoBloc>().add(CambiadaModalidadSeleccionEtiqueta(estaModoSeleccionActivo: true));
      },
      selected: estaSeleccionada,
      selectedColor: Colors.green,
      textColor: Colors.black,
      selectedTileColor: colorTileSeleccionado,
    );
  }
}

// Plantilla Etiqueta - Sirve tanto para Agregar como para Editar.
class WidgetPlantillaEtiqueta extends StatefulWidget {
  final Etiqueta? etiqueta; // En caso de editar no es nula. Al agregar si lo es.
  const WidgetPlantillaEtiqueta({super.key, this.etiqueta});

  @override
  State<WidgetPlantillaEtiqueta> createState() => _WidgetPlantillaEtiquetaState();
}
class _WidgetPlantillaEtiquetaState extends State<WidgetPlantillaEtiqueta> {
  final _formKey = GlobalKey<FormState>(); 
 // Llave necesaria para el Form. Sirve para validar los campos.
  final TextEditingController controladorNombre = TextEditingController();
  
  bool get esEditarEtiqueta => widget.etiqueta != null;
  bool get esFormValido => _formKey.currentState?.validate()??(esEditarEtiqueta?true:false);
  String obtenerTextoDePlantilla() => "${(widget.etiqueta == null)? 'Agregar':'Editar'} Etiqueta";

  Etiqueta obtenerEtiqueta(){
    return Etiqueta(
      id: (widget.etiqueta?.id)??0, 
      nombre: controladorNombre.text.trim(), 
    );
  }
  void inicializarValoresDeControladores(){
    controladorNombre.text = widget.etiqueta?.nombre??'';
  }

  @override
  void initState() {
    inicializarValoresDeControladores();
    super.initState();
  }

  @override
  void dispose() {
    controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTextoDePlantilla()),
        leading: IconButton( // Botón Volver.
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAAdministradorEtiquetas());
          }, 
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisEtiquetas),
      body: SingleChildScrollView( // Esto evita algun tipo de overflow al aparecer el teclado en el celular.
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            children: <Widget>[
              CuadroDeTextoEtiqueta(controlador: controladorNombre, titulo: 'Nombre', focusTecaldo: true, icono: iconoEtiqueta,),
              ElevatedButton(
                onPressed: () {
                  if (!esFormValido) return;
                  if (!esEditarEtiqueta) {
                    context.read<VehiculoBloc>().add(AgregadoEtiqueta(nombreEtiqueta: controladorNombre.text.trim())); // Agrega nueva Etiqueta.
                    return;
                  }
                  context.read<VehiculoBloc>().add(EditadoEtiqueta(etiqueta: obtenerEtiqueta())); // Edita la etiqueta.                  
                },
                child: Text(obtenerTextoDePlantilla()),
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
    if (campoRequerido) return obtenerDecoracionCampoObligatorio(hintText: 'Ej: Gasolina', icono: icono);
    return obtenerDecoracionCampoOpcional(icono: icono);
  }
  bool existeEtiqueta(List<String> etiquetas, String etiquetaRecibida){
    for (var etiqueta in etiquetas) {
      if (etiqueta.equalsIgnoreCase(etiquetaRecibida)) return true;
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

    var state = context.watch<VehiculoBloc>().state;
    Future<List<String>>? nombresEtiquetas = (state as PlantillaEtiqueta).nombresEtiquetas; // Lista para evitar repetir etiquetas.
    
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
                  autovalidateMode: autovalidacion,
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
                    controlador.selectAll(); // Selecciona todo el texto.
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
