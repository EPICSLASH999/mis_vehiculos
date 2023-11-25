import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- VEHICULOS --------------------------------- */
 
// Widget Principal (Menu Principal)
class WidgetMisVehiculos extends StatefulWidget {
  final Future<List<Vehiculo>>? misVehiculos;
  final Future<List<Etiqueta>>? misEtiquetas;

  const WidgetMisVehiculos({super.key, required this.misVehiculos, required this.misEtiquetas});

  @override
  State<WidgetMisVehiculos> createState() => _WidgetMisVehiculosState();
}

class _WidgetMisVehiculosState extends State<WidgetMisVehiculos> {
  SearchController controladorDeBusqueda = SearchController();
  void escuchador(){
    setState(() {
    });
  }

  @override
  void dispose() {
    controladorDeBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controladorDeBusqueda.addListener(escuchador);
    
    List<Vehiculo> filtrarListaVehiculos(List<Vehiculo> vehiculos) {
      List<Vehiculo> vehiculosRecibidos = vehiculos.copiar();
      String filtroVehiculo = controladorDeBusqueda.text.trim();

      if (filtroVehiculo.isNotEmpty) { 
          vehiculosRecibidos.removeWhere((element) {
          String matricula = element.matricula;
          String modelo = element.modelo;
          return (!matricula.containsIgnoreCase(filtroVehiculo) && !modelo.containsIgnoreCase(filtroVehiculo));
        }); 
      }
      return vehiculosRecibidos;
    }
    Future<List<Vehiculo>>? obtenerListaVehiculos() async{
      List<Vehiculo> lista = await widget.misVehiculos??[];
      lista = filtrarListaVehiculos(lista);
      return Future(() => lista);
    }


    return BlocConsumer<VehiculoBloc, VehiculoEstado>(
      listenWhen: (previous, current) { 
        // Esto lo hice para no ocultar el toast (snackBar) cuando se recargue el Estado
        // Para asi poder mostrar el toast de 'Gastos archivados'.
        if ((previous is! MisVehiculos) || (current is! MisVehiculos)) return true;
        return false;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      builder: (context, state) {
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
          bottomNavigationBar: const BarraInferior(indiceSeleccionado: indiceMisVehiculos),
          body: Column(
            children: [
              SearchBarApp(controladorDeBusqueda: controladorDeBusqueda,),
              Expanded(
                child: FutureBuilder<List<Vehiculo>>(
                  future: obtenerListaVehiculos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const WidgetCargando();
                    } else {
                      final vehiculos = snapshot.data ?? [];

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<VehiculoBloc>().add(ClickeadoAgregarVehiculo());
                  }, 
                  icon: const Icon(Icons.add), 
                  label: const Text('Agregar Vehículo'),
                ),
              )
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
  Future mostrarVehiculo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.car_repair_outlined),
            const SizedBox(
              width: 12,
            ),
            SizedBox(
              width: 220,
              child: Text(
                vehiculo.modelo,
                style: const TextStyle(fontSize: 25),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min, // Esto autoajusta el 'height' del AlertDialog dependiendo de la altura del total de los widgets hijos.
          children: [
            DatoVehiculo(titulo: 'Matricula', valor: vehiculo.matricula),
            DatoVehiculo(titulo: 'Marca', valor: vehiculo.marca),
            DatoVehiculo(titulo: 'Color', valor: vehiculo.color),
            DatoVehiculo(titulo: 'Año', valor: vehiculo.ano.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<VehiculoBloc>().add(ClickeadoEditarVehiculo(vehiculo: vehiculo));
            },
            child: const Text('Editar')),
          TextButton(
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
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.green,
        child: ListTile(
          title: Text(
            vehiculo.modelo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(vehiculo.matricula),
          trailing: BotonesTileVehiculo(vehiculo: vehiculo),
          onTap: () {
            mostrarVehiculo(context);
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

    var state = context.watch<VehiculoBloc>().state;
    Future<List<Etiqueta>>? misEtiquetas;
    if (state is MisVehiculos){
      misEtiquetas = state.misEtiquetas;
    }

    return IconButton(
      onPressed: () async {
        var etiquetas = await misEtiquetas ?? [];

        if (etiquetas.isEmpty) {
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
  String obtenerTexto() => (!esEditar) ? 'Agregar Vehiculo' : 'Editar Vehiculo';
  Vehiculo obtenerVehiculo() {
    return Vehiculo(
        id: (widget.vehiculo?.id) ?? 0,
        matricula: controladorMatricula.text,
        marca: controladorMarca.text,
        modelo: controladorModelo.text,
        color: controladorColor.text,
        ano: int.parse(controladorAno.text));
  }

  void inicializarValoresDeControladores() {
    if (!esEditar) return;
    controladorMatricula.text = widget.vehiculo?.matricula ?? '';
    controladorMarca.text = widget.vehiculo?.marca ?? '';
    controladorModelo.text = widget.vehiculo?.modelo ?? '';
    controladorColor.text = widget.vehiculo?.color ?? '';
    controladorAno.text = (widget.vehiculo?.ano ?? 0000).toString();
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
              context
                  .read<VehiculoBloc>()
                  .add(ClickeadoRegresarAMisvehiculos());
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      bottomNavigationBar:
          const BarraInferior(indiceSeleccionado: indiceMisVehiculos),
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.
            CuadroDeTextoMatricula(matriculasVehiculos: widget.matriculasVehiculos, controladorMatricula: controladorMatricula, titulo: 'Matricula', focusTecaldo: true, icono: const Icon(Icons.abc_outlined),),
            CuadroDeTexto(controlador: controladorMarca, titulo: 'Marca', icono: const Icon(Icons.factory)),
            CuadroDeTexto(controlador: controladorModelo, titulo: 'Modelo'),
            CuadroDeTexto(controlador: controladorColor, titulo: 'Color', maxCaracteres: 15, icono: const Icon(Icons.colorize),),
            CuadroDeTexto(controlador: controladorAno, titulo: 'Año', esInt: true, maxCaracteres: 4, minCaracteres: 4, icono: const Icon(Icons.calendar_month), minValor: 1000,),
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
      )),
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
    this.focusTecaldo = false, 
    this.icono,
  });

  final Future<List<String>>? matriculasVehiculos;
  final TextEditingController controladorMatricula;
  final String titulo;
  final bool focusTecaldo;
  final Icon? icono;

  final bool campoRequerido = true;
  final int maxCaracteres = 7;
  final int minCaracteres = 4;

  final caracteresEspeciales = RegExp(r'[\^$*\[\]{}()?\"!@%&$#/\><:,.;_~`+='
      "'"
      ']');

  @override
  Widget build(BuildContext context) {
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
                    if (matriculasVehiculos.contains(valorNormalizado)) return 'Matricula ya existente';
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                  maxLength: maxCaracteres,
                  controller: controladorMatricula,
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
