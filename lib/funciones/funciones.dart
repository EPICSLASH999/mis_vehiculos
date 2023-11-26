// ütil para normalizar valores de una fecha a 2 dígitos.
// A esta función se le pasa un "DateTime.month" o "DateTime.day" y normaliza el valor a 2 digitos.
// Ejemplo: 2023-1-1 necesita convertirse a 2023-01-01
String normalizarNumeroA2DigitosFecha(int numero){
  String numeroRecibido = '';
  if (numero.toString().length == 1) numeroRecibido += '0';
  return numeroRecibido += numero.toString();
}

DateTime obtenerValorMaximoDelDiaDeFecha(DateTime fecha){
  return DateTime.parse('${fecha.year}-${normalizarNumeroA2DigitosFecha(fecha.month)}-${normalizarNumeroA2DigitosFecha(fecha.day)} 23:58:99.999');
}