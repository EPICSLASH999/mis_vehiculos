import 'package:equatable/equatable.dart';

class Gasto extends Equatable{
  final int id;
  final int vehiculo;
  final int etiqueta;
  final String mecanico;
  final String lugar;
  final double costo;
  final String fecha;

  const Gasto({
    required this.id, 
    required this.vehiculo, 
    required this.etiqueta, 
    required this.mecanico, 
    required this.lugar, 
    required this.costo, 
    required this.fecha
  });

  factory Gasto.fromSQfliteDatabase(Map<String, dynamic> datos) => Gasto(
    id: datos['id_gasto']?.toInt() ?? 0,
    vehiculo: datos['vehiculo'] ?? '',
    etiqueta: datos['etiqueta'] ?? '',
    mecanico: datos['mecanico'] ?? '',
    lugar: datos['lugar'] ?? '',
    costo: datos['costo']?.toDouble() ?? 0,
    fecha: DateTime.fromMillisecondsSinceEpoch(datos['fecha'])
        .toIso8601String(),
  );
  
  @override
  List<Object?> get props => [id, vehiculo, etiqueta, mecanico, lugar, costo, fecha];
}