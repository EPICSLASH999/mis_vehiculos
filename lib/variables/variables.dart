// Variables constantes para administrar los valores de etiquetas Nulas, Todas o vacías
// Puesto que ellas no se encuentran en la Base de Datos.
import 'package:flutter/material.dart';

// Etiquetas
const String nombreSinEtiqueta = 'Desconocida'; // NO CAMBIAR despues de inicializar tabla en la base de datos.
const int idSinEtiqueta = 1; // NO CAMBIAR ESTE VALOR. 
const int valorOpcionTodas = 999;
const int valorNoHayEtiquetasCreadas = 998;

//Base de Datos
const nombreBD = 'mis_vehiculos.db';

// Tablas
const tablaGastos = 'gastos';
const tablaVehiculos = 'vehiculos';
const tablaEtiquetas = 'etiquetas';
const tablaGastosArchivados = 'gastos_archivados';

// Pantallas
enum Pantallas {misVehiculos, misEtiquetas, misGastos}

int indiceMisVehiculos = 0;
int indiceMisEtiquetas = 1;
int indiceMisGastos = 2;

// Colores
Color colorIcono = const Color.fromARGB(255, 158, 190, 42);
Color colorTileSeleccionado = const Color.fromARGB(104, 201, 255, 7);

//Decoracion
InputDecoration get decoracionParaCampoObligatorio => const InputDecoration(
        hintText: "", 
        prefixIcon: Icon(Icons.label_important),
        prefixIconColor: Colors.red,
        suffixIcon: Icon(Icons.car_rental)
      );