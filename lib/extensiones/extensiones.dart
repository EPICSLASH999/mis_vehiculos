import 'package:flutter/material.dart';

extension MiLista<T> on List<T>{
  List<T> copiar () => [...this];
}

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());
  //bool isNotBlank() => this != null && this.isNotEmpty;
  bool equalsIgnoreCase(String secondString) => (toLowerCase() == (secondString.toLowerCase()));
}

extension TextEditingControllerText on TextEditingController {
  // Extension para seleccionar todo en el CuadroDeTexto 'controlador.selectAll()'.
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}