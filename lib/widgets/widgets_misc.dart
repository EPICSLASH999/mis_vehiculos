import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mis_vehiculos/blocs/bloc.dart';
import 'package:mis_vehiculos/extensiones/extensiones.dart';
import 'package:mis_vehiculos/variables/variables.dart';

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

  bool esNumerico(String? s) {
    if(s == null) return false;    
    if (esInt) return int.tryParse(s) != null;
    return double.tryParse(s) != null;
  }
  InputDecoration obtenerDecoracion(){

    if (campoRequerido && !esSoloLectura){
      return decoracionParaCampoObligatorio;
    }

    return const InputDecoration(
      hintText: "", 
      suffixIcon: Icon(Icons.car_rental)
    );
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              String valorNormalizado = (value??'').trim();
              if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
              if (esInt && !esNumerico(valorNormalizado)) return 'Debe ser número entero';  
              if (esDouble && !esNumerico(valorNormalizado)) return 'Debe ser numerico';  
              if((!esInt && !esDouble) && esNumerico(valorNormalizado)) return 'Campo inválido';
              if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
              if(minCaracteres != null && valorNormalizado.length < minCaracteres!) return 'Debe tener al menos $minCaracteres caracteres';
              return null;
            },
            textCapitalization: TextCapitalization.sentences,
            maxLength: maxCaracteres,
            readOnly: esSoloLectura,
            controller: controlador,
            decoration: obtenerDecoracion(),
            keyboardType: obtenerTipoTeclado(),
            autofocus: focusTecaldo,
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
                suffixIcon: Icon(Icons.date_range)
              ),
              onTap: funcionAlPresionar
            ),
          ],
        ),
      ),
    );
  }
}
/* ----------------------------------------------------------------------------- */


/* ---------------------------------- MENSAJES --------------------------------- */
//Función de AlertDialog
VoidCallback dialogoAlerta ({required BuildContext context, required String texto, required Function funcionAlProceder, String? titulo}) {
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
                  foregroundColor: Colors.red,
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
 void mostrarToast(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
          icon: Icon(Icons.car_repair),
          label: 'Vehículos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_travel),
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
