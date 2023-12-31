import 'package:flutter/material.dart';

// Variables constantes para administrar los valores de etiquetas Nulas, Todas o vacías
// Puesto que ellas no se encuentran en la Base de Datos.

//Base de Datos
const nombreBD = 'mis_vehiculos.db';

// Valores por omisión
const int valorOpcionTodas = 999;

// Vehiculos
const int numeroVehiculosFavoritos = 3;

// Etiquetas
const String nombreSinEtiqueta = 'Sin etiqueta'; // NO CAMBIAR despues de inicializar tabla en la base de datos.
const int idSinEtiqueta = 1; // NO CAMBIAR ESTE VALOR. 
const int valorNoHayEtiquetasCreadas = 998;
const int valorNoTieneEtiquetaConMayorOcurrencias = 0;

//Gastos
const String valorSinMecanico = 'Sin mecanico';
const String valorSinLugar = 'Sin lugar';
enum RepresentacionGastos {lista, grafica, reporte}
enum TipoReporte {year, month, day}
const String mensajeSinRelacion = 'Sin datos';

// Tablas
const tablaGastos = 'gastos';
const tablaVehiculos = 'vehiculos';
const tablaEtiquetas = 'etiquetas';
const tablaGastosArchivados = 'gastos_archivados';

// Opciones BottomBar
enum OpcionesBottomBar {misVehiculos, misEtiquetas, misGastos}

const int indiceMisVehiculos = 0;
const int indiceMisEtiquetas = 1;
const int indiceMisGastos = 2;

// Colores
const Color colorIcono = Color.fromARGB(255, 158, 190, 42);
const Color colorTileSeleccionado = Color.fromARGB(104, 201, 255, 7);
const Color colorGastoDorado = Color.fromARGB(255, 228, 185, 31);
const Color colorReporteSinGastos = Color.fromARGB(255, 209, 208, 208);
const Color colorReporteConGastos = Color.fromARGB(255, 196, 248, 212);

//Decoración
InputDecoration obtenerDecoracionCampoObligatorio({String? hintText, Icon? icono}) {
  return InputDecoration(
        hintText: (hintText??''), 
        suffixIcon: const Icon(Icons.arrow_left_rounded),
        suffixIconColor: Colors.red,
        prefixIcon: icono??const Icon(Icons.car_rental)
      );
}

InputDecoration obtenerDecoracionCampoOpcional({String? hintText, Icon? icono}) {
  return InputDecoration(
    hintText: (hintText??''), 
    prefixIcon: icono??const Icon(Icons.car_rental)
  );
}

// Iconos
const Icon iconoVehiculo = Icon(Icons.directions_car);
const Icon iconoVehiculoMotocicleta = Icon(Icons.motorcycle);
const Icon iconoEtiqueta = Icon(Icons.card_travel);

// Tamaños
const double widthDeComponente = 160;
const double alturaMaximaSearchbar = 290;

// Autovalidacion
AutovalidateMode autovalidacion = AutovalidateMode.onUserInteraction;
