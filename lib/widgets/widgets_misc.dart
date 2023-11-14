import 'package:flutter/material.dart';

/* ----------------------------------- MISC ------------------------------------ */

class CuadroDeTexto extends StatelessWidget {
  const CuadroDeTexto({
    super.key,
    required this.controlador,
    required this.titulo, 
    this.esInt = false, 
    this.esDouble = false,
    this.esSoloLectura = false, 
    this.funcionAlPresionar,
    this.campoRequerido = true,
    this.maxCaracteres = 20,
  });

  final TextEditingController controlador;
  final String titulo;
  final bool esInt;
  final bool esDouble;
  final bool esSoloLectura;
  final VoidCallback? funcionAlPresionar;
  final bool campoRequerido;
  final int maxCaracteres;

  bool esNumerico(String? s) {
    if(s == null) return false;    
    if (esInt) return int.tryParse(s) != null;
    return double.tryParse(s) != null;
  }
  InputDecoration obtenerDecoracion(){

    if (campoRequerido && !esSoloLectura){
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
  TextInputType obtenerTipoTeclado(){
    if(esInt || esDouble) return TextInputType.number;
    return TextInputType.text;
  }

  

  @override
  Widget build(BuildContext context) {
    final caracteresEspeciales = RegExp(
      r'[\^$*\[\]{}()?\"!@#%&/\><:;_~`+=' 
      "'" 
      ']'
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(titulo),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              String valorNormalizado = (value??'').trim();
              if (valorNormalizado.isEmpty && campoRequerido) return 'Campo requerido';
              if (esInt && !esNumerico(valorNormalizado)) return 'Debe ser número entero';  
              if (esDouble && !esNumerico(valorNormalizado)) return 'Debe ser numerico';  
              if((!esInt && !esDouble) && esNumerico(valorNormalizado)) return 'Campo inválido';
              if((valorNormalizado).contains(caracteresEspeciales)) return 'No se permiten caracteres especiales';
              return null;
            },
            maxLength: maxCaracteres,
            readOnly: esSoloLectura,
            controller: controlador,
            decoration: obtenerDecoracion(),
            onTap: funcionAlPresionar,
            keyboardType: obtenerTipoTeclado(),
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
            Text(titulo),
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