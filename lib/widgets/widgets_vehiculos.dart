import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/main.dart';
import 'package:mis_vehiculos/modelos/etiqueta.dart';
import 'package:mis_vehiculos/modelos/vehiculo.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'package:mis_vehiculos/widgets/widgets_misc.dart';

/* --------------------------------- VEHICULOS --------------------------------- */
Future<List<Etiqueta>>? etiquetasGlobales;

// Widget Principal (Menu Principal)
class WidgetMisVehiculos extends StatelessWidget {
  final Future<List<Vehiculo>>? misVehiculos;
  final Future<List<Etiqueta>>? misEtiquetas;

  const WidgetMisVehiculos({super.key, required this.misVehiculos, required this.misEtiquetas});

  @override
  Widget build(BuildContext context) {
    etiquetasGlobales = misEtiquetas;

    return BlocConsumer<VehiculoBloc, VehiculoEstado>(
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
          bottomNavigationBar: BarraInferior(indiceSeleccionado: indiceMisVehiculos),
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Vehiculo>>(
                  future: misVehiculos,
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
                              /*separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 12,
                              ),*/
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

  @override
  Widget build(BuildContext context) {
    Future openDialog() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.car_repair_outlined),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  vehiculo.modelo,
                  style: const TextStyle(fontSize: 25),
                ),
              ],
            ),
            content: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Dato(titulo: 'Matricula', valor: vehiculo.matricula),
                  Dato(titulo: 'Marca', valor: vehiculo.marca),
                  Dato(titulo: 'Color', valor: vehiculo.color),
                  Dato(titulo: 'Año', valor: vehiculo.ano.toString()),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context
                        .read<VehiculoBloc>()
                        .add(ClickeadoEditarVehiculo(vehiculo: vehiculo));
                  },
                  child: const Text('Editar')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'))
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.green,
        child: ListTile(
          title: Text(
            vehiculo.modelo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(vehiculo.matricula),
          trailing: BotonesTileVehiculo(vehiculo: vehiculo),
          onTap: () {
            openDialog();
          },
        ),
      ),
    );
    
  }
}

class Dato extends StatelessWidget {
  const Dato({
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

  Function eliminarVehiculo(BuildContext context) {
    return () {
      context.read<VehiculoBloc>().add(EliminadoVehiculo(id: vehiculo.id));
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Row(
        children: [
          IconButton(
              onPressed: dialogoAlerta(
                  context: context,
                  texto: '¿Seguro de eliminar este vehículo?',
                  funcionAlProceder: eliminarVehiculo(context)),
              icon: Icon(Icons.delete, color: colorIcono)),
          IconButton(
              onPressed: () async {
                var etiquetas = await etiquetasGlobales ?? [];
                etiquetas.removeWhere((element) => (element.id == idSinEtiqueta)); // Remueve la etiqueta 'Desconocida' de la lista.

                if (etiquetas.isEmpty) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Primero cree etiquetas!"),
                    duration: Duration(seconds: 1),
                    //backgroundColor: Colors.blueGrey,
                  ));
                  return;
                }
                // ignore: use_build_context_synchronously
                context.read<VehiculoBloc>().add(ClickeadoAgregarGasto(idVehiculo: vehiculo.id));
              },
              icon: Icon(Icons.add_card_outlined, color: colorIcono)),
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
          BarraInferior(indiceSeleccionado: indiceMisVehiculos),
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
            CuadroDeTexto(controlador: controladorAno, titulo: 'Año',esInt: true,maxCaracteres: 4,minCaracteres: 4,),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (!esEditar) {
                    context
                        .read<VehiculoBloc>()
                        .add(AgregadoVehiculo(vehiculo: obtenerVehiculo()));
                    return;
                  }
                  context
                      .read<VehiculoBloc>()
                      .add(EditadoVehiculo(vehiculo: obtenerVehiculo()));
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
  });

  final Future<List<String>>? matriculasVehiculos;
  final TextEditingController controladorMatricula;
  final String titulo;

  final bool campoRequerido = true;
  final int maxCaracteres = 7;
  final int minCaracteres = 4;

  final caracteresEspeciales = RegExp(r'[\^$*\[\]{}()?\"!@%&/\><:,;_~`+='
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
                  maxLength: maxCaracteres,
                  controller: controladorMatricula,
                  decoration: decoracionParaCampoObligatorio,
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

/* ----------------------------------------------------------------------------- */