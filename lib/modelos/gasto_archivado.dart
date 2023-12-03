import 'package:equatable/equatable.dart';

class GastoArchivado extends Equatable{
  final int id;
  final String vehiculo;
  final String etiqueta;
  final String mecanico;
  final String lugar;
  final double costo;
  final String fecha;
  final int idVehiculo;
  final int idEtiqueta;

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
  );
  
  @override
  List<Object?> get props => [id, vehiculo, etiqueta, mecanico, lugar, costo, fecha, idVehiculo, idEtiqueta];
}