import 'package:flutter/material.dart';

extension MiLista<T> on List<T>{
  List<T> copiar () => [...this];
}

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());
  //bool isNotBlank() => this != null && this.isNotEmpty;
}

extension TextEditingControllerText on TextEditingController {
  // Extension para seleccionar todo en el CuadroDeTexto 'controlador.selectAll()'.
  // Pero es algo molesto tratar de deseleccionarlo con el dedo.
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}