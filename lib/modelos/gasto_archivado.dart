import 'package:equatable/equatable.dart';

class GastoArchivado extends Equatable{
  final int id;
  final String vehiculo; // Matricula de vehiculo
  final String etiqueta; // Nombre de etiqueta
  final String mecanico;
  final String lugar;
  final double costo;
  final String fecha;
  final int idVehiculo;
  final int idEtiqueta;
  final String marcaVehiculo;
  final String modeloVehiculo;
  final String colorVehiculo;
  final int anoVehiculo;

  const GastoArchivado({
    required this.id, 
    required this.vehiculo, 
    required this.etiqueta, 
    required this.mecanico, 
    required this.lugar, 
    required this.costo, 
    required this.fecha,
    required this.idVehiculo, 
    required this.idEtiqueta, 
    required this.marcaVehiculo, 
    required this.modeloVehiculo, 
    required this.colorVehiculo, 
    required this.anoVehiculo, 
  });

  factory GastoArchivado.fromSQfliteDatabase(Map<String, dynamic> datos) => GastoArchivado(
    id: datos['id_gasto_archivado']?.toInt() ?? 0,
    vehiculo: datos['vehiculo'] ?? '',
    etiqueta: datos['etiqueta'] ?? '',
    mecanico: datos['mecanico'] ?? '',
    lugar: datos['lugar'] ?? '',
    costo: datos['costo']?.toDouble() ?? 0,
    fecha: DateTime.fromMillisecondsSinceEpoch(datos['fecha'])
        .toIso8601String(),
    idVehiculo: datos['id_vehiculo'] ?? 0,
    idEtiqueta: datos['id_etiqueta'] ?? 0,
    marcaVehiculo: datos['marca_vehiculo'] ?? '',
    modeloVehiculo: datos['modelo_vehiculo'] ?? '',
    colorVehiculo: datos['color_vehiculo'] ?? '',
    anoVehiculo: datos['ano_vehiculo'] ?? 2000,
  );
  
  @override
  List<Object?> get props => [id, vehiculo, etiqueta, mecanico, lugar, costo, fecha, idVehiculo, idEtiqueta, marcaVehiculo, modeloVehiculo, colorVehiculo, anoVehiculo];
}