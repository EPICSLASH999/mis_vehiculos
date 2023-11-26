import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- VEHICULOS --------------------------------- */
 
// Widget Principal (Menu Principal) - Mis Vehículos.
class WidgetMisVehiculos extends StatefulWidget {
  final Future<List<Vehiculo>>? misVehiculos;

  const WidgetMisVehiculos({super.key, required this.misVehiculos});

  @override
  State<WidgetMisVehiculos> createState() => _WidgetMisVehiculosState();
}
class _WidgetMisVehiculosState extends State<WidgetMisVehiculos> {
  SearchController controladorDeBusqueda = SearchController();
  
  void escuchador(){ // Event listener del controlador.
    setState(() {
    });
  }

  @override
  void dispose() { // Se deben de eliminar manualmente los Controladores.
    controladorDeBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controladorDeBusqueda.addListener(escuchador); // Se agrega el Event Listener al controlador.
    
    List<Vehiculo> filtrarListaVehiculos(List<Vehiculo> vehiculos) {
      if (vehiculos.isEmpty) return vehiculos;
      List<Vehiculo> vehiculosFiltrados = vehiculos.copiar();
      String valorAFiltrar = controladorDeBusqueda.text.trim();

      if (valorAFiltrar.isNotEmpty) { 
        vehiculosFiltrados.removeWhere((element) {
          return (!element.matricula.containsIgnoreCase(valorAFiltrar) && !element.modelo.containsIgnoreCase(valorAFiltrar));
        }); 
      }
      return vehiculosFiltrados;
    }
    Future<List<Vehiculo>>? obtenerListaVehiculos() async{
      List<Vehiculo> lista = await widget.misVehiculos??[];
      lista = filtrarListaVehiculos(lista);
      return Future(() => lista);
    }
    VoidCallback funcionAgregarVehiculo(){
      return () {
        context.read<VehiculoBloc>().add(ClickeadoAgregarVehiculo());
      };
    }

    return BlocConsumer<VehiculoBloc, VehiculoEstado>( // BlocConsumer para realizar una acción cada vez que se carga este Widget/Estado. En este caso, es para ocultar un Toast al cambiar de Estado o Pantalla.
      listenWhen: (previous, current) { 
        // Esto lo hice para no ocultar el toast (snackBar) cuando se recargue este mismo Estado.
        // De esta manera se puede (quedar y) mostrar el toast de 'Gastos archivados'.
        if ((previous is! MisVehiculos) || (current is! MisVehiculos)) return true;
        return false;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Oculta el Toast o SnackBar.
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Vehículos'),
          ),
          bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisVehiculos),
          body: Column(
            children: [
              CuadroDeBusqueda(controladorDeBusqueda: controladorDeBusqueda,),
              Expanded(
                child: FutureBuilder<List<Vehiculo>>(
                  future: obtenerListaVehiculos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const WidgetCargando();
                    } else {
                      final vehiculos = snapshot.data ?? []; // Lista de vehículos filtrada.

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
                          : ListView.builder(
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
              BotonAgregar(texto: 'Agregar Vehiculo', funcionAlPresionar: funcionAgregarVehiculo(),)
            ],
          ),
        );
      },
    );
  }
}
class TileVehiculo extends StatelessWidget {
  const TileVehiculo({
    super.key,
    required this.vehiculo,
  });

  final Vehiculo vehiculo;

  Function eliminarVehiculo(BuildContext context, int idVehiculo) {
    return () {
      context.read<VehiculoBloc>().add(EliminadoVehiculo(id: idVehiculo));
      mostrarToast(context, 'Gastos archivados');
    };
  }
  Future mostrarCuadroDeDialogoDeVehiculo(BuildContext context) { // Cuadro de diálogo que aparece al hacer clic en un vehículo.
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.directions_car),
            const SizedBox(width: 12,), // Para separar un poco el ícono del título.
            SizedBox(
              width: 220, // Width necesario para establecer el límite antes del overflow.
              child: Text(
                vehiculo.modelo,
                style: const TextStyle(fontSize: 25),
                overflow: TextOverflow.ellipsis, // Ellipsis para evitar overflow por 3 puntitos. (Ej: Titulo muy larg...)
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min, // Esto autoajusta el 'height' del AlertDialog dependiendo de la altura del total de los widgets hijos. MUY útil.
          children: [
            DatoVehiculo(titulo: 'Matricula', valor: vehiculo.matricula),
            DatoVehiculo(titulo: 'Marca', valor: vehiculo.marca),
            DatoVehiculo(titulo: 'Color', valor: vehiculo.color),
            DatoVehiculo(titulo: 'Año', valor: vehiculo.ano.toString()),
          ],
        ),
        actions: [
          TextButton( // Botón Editar Vehículo.
            onPressed: () {
              Navigator.of(context).pop();
              context.read<VehiculoBloc>().add(ClickeadoEditarVehiculo(vehiculo: vehiculo));
            },
            child: const Text('Editar')
          ),
          TextButton( // Botón Aceptar (Desaparece el cuadro de diálogo).
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar')
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material( // Diseño para que el Tile parezca un rectángulo sombreado.
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.green,
        child: ListTile( // ListTile de Vehículo.
          leading: const Icon(Icons.directions_car_filled),
          title: Text(
            vehiculo.modelo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(vehiculo.matricula),
          trailing: BotonesTileVehiculo(vehiculo: vehiculo),
          onTap: () {
            mostrarCuadroDeDialogoDeVehiculo(context);
          },
          onLongPress: dialogoAlerta(context: context, texto: '¿Desea eliminar este vehículo?', funcionAlProceder: eliminarVehiculo(context, vehiculo.id), titulo: 'Eliminar'),
        ),
      ),
    );
    
  }
}
class DatoVehiculo extends StatelessWidget {
  const DatoVehiculo({
    super.key,
    required this.titulo,
    required this.valor,
  });

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(valor),
        ],
      ),
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
    //Future<List<Etiqueta>>? misEtiquetas = context.watch<VehiculoBloc>().misEtiquetas;
    Future<bool> futureHayEtiquetas = context.watch<VehiculoBloc>().hayAlmenosUnaEtiqueta();

    return IconButton(
      onPressed: () async {
        //var etiquetas = await misEtiquetas ?? [];
        bool hayAlmenosUnaEtiqueta = await futureHayEtiquetas;

        if (!hayAlmenosUnaEtiqueta) { // Si no hay etiquetas, mostrar Toast / SnackBar.
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // ignore: use_build_context_synchronously
          mostrarToast(context, "Primero cree una etiqueta!");
          return;
        }
        // ignore: use_build_context_synchronously
        context.read<VehiculoBloc>().add(ClickeadoAgregarGasto(idVehiculo: vehiculo.id));
      },
      icon: const Icon(Icons.monetization_on, color: Color.fromARGB(255, 228, 185, 31),)
    );
  }

  
}


// Plantilla Vehículo - Sirve tanto para Agregar como para Editar un vehículo.
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

  bool get esEditar => widget.vehiculo != null;
  String obtenerTextoPlantilla() => (!esEditar) ? 'Agregar Vehiculo' : 'Editar Vehiculo';
  Vehiculo obtenerVehiculo() {
    return Vehiculo(
        id: (widget.vehiculo?.id) ?? 0,
        matricula: controladorMatricula.text,
        marca: controladorMarca.text,
        modelo: controladorModelo.text,
        color: controladorColor.text,
        ano: int.tryParse(controladorAno.text)??2000);
  }

  void inicializarValoresDeControladores() {
    if (!esEditar) return;
    controladorMatricula.text = widget.vehiculo?.matricula ?? '';
    controladorMarca.text = widget.vehiculo?.marca ?? '';
    controladorModelo.text = widget.vehiculo?.modelo ?? '';
    controladorColor.text = widget.vehiculo?.color ?? '';
    controladorAno.text = (widget.vehiculo?.ano ?? 2000).toString();
  }

  // Global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>(); // Llave necesaria para un Form. De esta manera se validan los valores de los campos.

  @override
  void dispose() { // Elimina manualmente los controladores.
    controladorMatricula.dispose();
    controladorMarca.dispose();
    controladorModelo.dispose();
    controladorColor.dispose();
    controladorAno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    inicializarValoresDeControladores();

    return Scaffold(
      appBar: AppBar(
        title: Text(obtenerTextoPlantilla()),
        leading: IconButton( // Botón Volver a MisVehículos.
          onPressed: () {
            context.read<VehiculoBloc>().add(ClickeadoRegresarAMisvehiculos());
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisVehiculos),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CuadroDeTextoMatricula(controlador: controladorMatricula, titulo: 'Matricula', focusTecaldo: true, icono: const Icon(Icons.abc_outlined), maxCaracteres: 7,),
                CuadroDeTexto(controlador: controladorMarca, titulo: 'Marca', icono: const Icon(Icons.factory)),
                CuadroDeTexto(controlador: controladorModelo, titulo: 'Modelo', icono: const Icon(Icons.car_rental)),
                CuadroDeTexto(controlador: controladorColor, titulo: 'Color', maxCaracteres: 15, icono: const Icon(Icons.colorize),),
                CuadroDeTexto(controlador: controladorAno, titulo: 'Año', esInt: true, maxCaracteres: 4, minCaracteres: 4, icono: const Icon(Icons.calendar_month), minValor: 1000,),
                ElevatedButton(
                  onPressed: () {
                    if (!(_formKey.currentState!.validate())) return; // Si alguno de los campos no es válido, no procede.
                    if (!esEditar) {
                      context.read<VehiculoBloc>().add(AgregadoVehiculo(vehiculo: obtenerVehiculo()));
                      return;
                    }
                    context.read<VehiculoBloc>().add(EditadoVehiculo(vehiculo: obtenerVehiculo()));
                  },
                  child: Text(obtenerTextoPlantilla()
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
class CuadroDeTextoMatricula extends StatelessWidget {
  CuadroDeTextoMatricula({
    super.key,
    required this.controlador,
    required this.titulo,
    this.focusTecaldo = false, 
    this.icono, 
    required this.maxCaracteres,
    this.minCaracteres = 4,
  });

  final TextEditingController controlador;
  final String titulo;
  final bool focusTecaldo;
  final Icon? icono;

  final bool campoRequerido = true;
  final int maxCaracteres;
  final int minCaracteres;

  final caracteresEspeciales = RegExp(r'[\^$*\[\]{}()?\"!@%&$#/\><:,.;_~`+='
      "'"
      ']');

  bool existeMatricula(List<String> matriculas, String matriculaRecibida){
    for (var matricula in matriculas) {
      if (matricula.equalsIgnoreCase(matriculaRecibida)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>>? matriculasVehiculos = context.watch<VehiculoBloc>().matriculasVehiculos;
    
    return FutureBuilder(
      future: matriculasVehiculos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WidgetCargando();
        } else {
          final matriculasVehiculos = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TituloComponente(titulo: titulo),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    String valorNormalizado = (value ?? '').trim();
                    if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
                    if ((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
                    if (valorNormalizado.length < minCaracteres) return 'Debe tener al menos $minCaracteres caracteres';
                    if (existeMatricula(matriculasVehiculos, valorNormalizado)) return 'Matricula ya existente';
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                  maxLength: maxCaracteres,
                  controller: controlador,
                  decoration: obtenerDecoracionCampoObligatorio(icono: icono),
                  keyboardType: TextInputType.text,
                  autofocus: focusTecaldo,
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
