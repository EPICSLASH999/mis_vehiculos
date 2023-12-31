import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/variables/variables.dart';
import 'dart:math' as math;

/* -------------------------------- COMPONENTES -------------------------------- */
class TituloComponente extends StatelessWidget {
  const TituloComponente({
    super.key,
    required this.titulo,
  });

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),);
  }
}
class TituloGrande extends StatelessWidget {
  const TituloGrande({
    super.key, 
    required this.titulo,
  });
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(8.0),
      child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    );
  }
}


class CuadroDeTexto extends StatelessWidget {
  const CuadroDeTexto({
    super.key,
    required this.controlador,
    required this.titulo, 
    this.esInt = false, 
    this.esDouble = false,
    this.esSoloLectura = false, 
    this.campoRequerido = true,
    this.maxCaracteres = 20, 
    this.minCaracteres,
    this.focusTecaldo = false, 
    this.icono, 
    this.valorDebeSermayorA, 
    this.puedeTenerEspacios = true, 
    this.valorDebeSerMenorOIgualA, 
    this.validarCampo = true, 
  });

  final TextEditingController controlador;
  final String titulo;
  final bool esInt;
  final bool esDouble;
  final bool esSoloLectura;
  final bool campoRequerido;
  final int maxCaracteres;
  final int? minCaracteres;
  final bool focusTecaldo;
  final Icon? icono;
  final int? valorDebeSermayorA;
  final int? valorDebeSerMenorOIgualA;
  final bool puedeTenerEspacios;
  final bool validarCampo;

  bool esNumerico(String? valor) {
    if(valor == null) return false;    
    if (esInt) return int.tryParse(valor) != null;
    return double.tryParse(valor) != null;
  }
  InputDecoration obtenerDecoracion(){
    if (campoRequerido && !esSoloLectura){
      return obtenerDecoracionCampoObligatorio(icono: icono);
    }
    return obtenerDecoracionCampoOpcional(icono: icono);
  }

  TextInputType obtenerTipoTeclado(){
    if(esInt || esDouble) return TextInputType.number;
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@%&/\><:,;_~`+=' 
      "'" 
      ']'
    );    
    bool esPrimerClic = true;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TituloComponente(titulo: titulo),
          TextFormField(
            autovalidateMode: autovalidacion,
            validator: (value) {
              if (esSoloLectura || !validarCampo) return null;
              String valorNormalizado = (value??'').trim();
              if (!puedeTenerEspacios && value != null && value.contains(" ")) return 'No puede tener espacios';
              if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
              if (esInt && !esNumerico(valorNormalizado)) return 'Debe ser número entero';  
              if (esDouble && !esNumerico(valorNormalizado)) return 'Debe ser numerico';  
              if((!esInt && !esDouble) && esNumerico(valorNormalizado)) return 'Campo inválido';
              if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
              if(minCaracteres != null && valorNormalizado.length < minCaracteres!) return 'Debe tener al menos $minCaracteres caracteres';
              if (valorDebeSermayorA != null && esNumerico(valorNormalizado) && double.parse(valorNormalizado) <= double.parse(valorDebeSermayorA.toString())) return 'Valor debe ser mayor a $valorDebeSermayorA';
              if (valorDebeSerMenorOIgualA != null && esNumerico(valorNormalizado) && double.parse(valorNormalizado) > valorDebeSerMenorOIgualA!.toDouble()) return 'Valor máximo es $valorDebeSerMenorOIgualA';
              return null;
            },
            textCapitalization: TextCapitalization.sentences,
            maxLength: esSoloLectura?null:maxCaracteres,
            readOnly: esSoloLectura,
            controller: controlador,
            decoration: obtenerDecoracion(),
            keyboardType: obtenerTipoTeclado(),
            autofocus: focusTecaldo,
            inputFormatters: !esDouble?null:[DecimalTextInputFormatter(decimalRange: 2)],
            onTap: () { 
              if(esSoloLectura) return;
              if(!esPrimerClic) return;
              controlador.selectAll(); // Seleccionar todo el texto.
              esPrimerClic = !esPrimerClic;
            },
          ),
        ],
      ),
    );
  }
}
// Clase para que TextField solo permita 2 decimales
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
    //return newValue;
  }
}

class SeleccionadorDeFecha extends StatelessWidget {
  const SeleccionadorDeFecha({
    super.key,
    required this.controlador,
    required this.titulo, 
    required this.funcionAlPresionar,
  });

  final TextEditingController controlador;
  final String titulo;
  final VoidCallback funcionAlPresionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TituloComponente(titulo: titulo),
            TextFormField(
              validator: (value) {
                if (value != null && value.isEmpty) return 'Valor requerido';
                return null;
              },
              readOnly: true,
              controller: controlador,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.date_range),
              ),
              onTap: funcionAlPresionar,
            ),
          ],
        ),
      ),
    );
  }
}

//Buscador
class CuadroDeBusqueda extends StatefulWidget {
  const CuadroDeBusqueda({super.key, required this.controladorDeBusqueda});
  final SearchController controladorDeBusqueda;

  @override
  State<CuadroDeBusqueda> createState() => _CuadroDeBusquedaState();
}
class _CuadroDeBusquedaState extends State<CuadroDeBusqueda> {

  @override
  Widget build(BuildContext context) {
    SearchController controladorDeBusqueda = widget.controladorDeBusqueda;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              hintText: 'Buscar...',
              controller: controladorDeBusqueda,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                //controladorDeBusqueda.openView();
              },
              onChanged: (_) {
                //controladorDeBusqueda.openView();
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Borrar busqueda',
                  child: IconButton(
                    onPressed: () {
                      controladorDeBusqueda.clear();
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            );
          }, 
          // Esto genera una lista de opciones en caso de abrir la línea "controladorDeBusqueda.openView();"
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controladorDeBusqueda.closeView(item);
                  });
                },
              );
            });
          }
      ),
    );
  }
}

class BotonAgregar extends StatelessWidget {
  const BotonAgregar({
    super.key, 
    required this.texto, 
    required this.funcionAlPresionar,
  });

  final String texto;
  final VoidCallback? funcionAlPresionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: funcionAlPresionar, 
        icon: const Icon(Icons.add), 
        label: Text(texto),
      ),
    );
  }
}
/* ----------------------------------------------------------------------------- */


/* ---------------------------------- MENSAJES --------------------------------- */
//Función de AlertDialog
VoidCallback dialogoAlerta ({required BuildContext context, required String texto, required Function funcionAlProceder, String? titulo, Color colorTextoSi = Colors.red}) {
    return (){
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(titulo??'¿Desea continuar?'),
            content: Text(texto),
            actions: [
              TextButton(
                onPressed: () {
                  funcionAlProceder();
                  // Cerrar cuadro de diálogo
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: colorTextoSi,
                ),
                child: const Text('Si') // Botón de "Si" 
              ),
              TextButton(
                onPressed: () {
                  // Cerrar cuadro de diálogo
                  Navigator.of(context).pop();
                },
                child: const Text('No') // Botón de "No" 
              )
            ],
          );
        }
      );
    };
  }

// Toast!
 void mostrarToast(ScaffoldMessengerState scaffoldMessangerState, String mensaje) {
  scaffoldMessangerState.hideCurrentSnackBar();
  scaffoldMessangerState.showSnackBar(SnackBar(
    content: Text(mensaje),
    duration: const Duration(seconds: 1),
    //backgroundColor: Colors.blueGrey,
  ));
}
/* ------------------------------------------------------------------------------ */

/* --------------------------------- BOTTOM BAR --------------------------------- */
class BarraInferior extends StatelessWidget {
  const BarraInferior({
    super.key, required this.indiceSeleccionado,
  });

  final int indiceSeleccionado;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceSeleccionado,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: iconoVehiculo,
          label: 'Vehículos',
        ),
        BottomNavigationBarItem(
          icon: iconoEtiqueta,
          label: 'Etiquetas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_rounded),
          label: 'Gastos',
        ),
      ],
      onTap: (value) {
        switch (value) {
          case 0:
              context.read<VehiculoBloc>().add(CambiadoDePantalla(pantalla: OpcionesBottomBar.misVehiculos));
            break;
          case 1:
              context.read<VehiculoBloc>().add(CambiadoDePantalla(pantalla: OpcionesBottomBar.misEtiquetas));
            break;
          case 2:
              context.read<VehiculoBloc>().add(CambiadoDePantalla(pantalla: OpcionesBottomBar.misGastos));
            break;
            
          default:
        }
      },
    );
  }
}
/* ------------------------------------------------------------------------------- */



