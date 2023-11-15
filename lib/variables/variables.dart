// Variables constantes para administrar los valores de etiquetas Nulas, Todas o vacías
// Puesto que ellas no se encuentran en la Base de Datos.
import 'dart:ui';

import 'package:flutter/material.dart';

const String nombreSinEtiqueta = 'Desconocida'; // NO CAMBIAR despues de inicializar tabla en la base de datos.
const int idSinEtiqueta = 1; // NO CAMBIAR ESTE VALOR. 
const int valorEtiquetaTodas = 999;
const int valorNoHayEtiquetasCreadas = 998;

//Base de Datos
const nombreBD = 'mis_vehiculos.db';

// Tablas
const tablaGastos = 'gastos';
const tablaVehiculos = 'vehiculos';
const tablaEtiquetas = 'etiquetas';
const tablaGastosArchivados = 'gastos_archivados';

// Pantallas
enum Pantallas {misVehiculos, misEtiquetas, misGastosArchivados}

int indiceMisVehiculos = 0;
int indiceMisEtiquetas = 1;
int indiceMisGastosArchivados = 2;

// Colores
Color colorIcono = const Color.fromARGB(255, 13, 126, 37);