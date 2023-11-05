import 'package:equatable/equatable.dart';

class Etiqueta extends Equatable {
  final int id;
  final String nombre;

  const Etiqueta({required this.id, required this.nombre});

  factory Etiqueta.fromSQfliteDatabase(Map<String, dynamic> datos) => Etiqueta(
    id: datos['id_etiqueta']?.toInt() ?? 0,
    nombre: datos['nombre'] ?? '',
  );
  
  @override
  List<Object?> get props => [id, nombre];
}