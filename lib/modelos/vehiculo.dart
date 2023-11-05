import 'package:equatable/equatable.dart';

class Vehiculo extends Equatable{
  final int id;
  final String matricula;
  final String marca;
  final String modelo;
  final String color;
  final int ano;

  const Vehiculo({ 
    required this.id, 
    required this.matricula, 
    required this.marca, 
    required this.modelo, 
    required this.color, 
    required this.ano
  });
  
  factory Vehiculo.fromSQfliteDatabase(Map<String, dynamic> datos) => Vehiculo(
    id: datos['id_vehiculo']?.toInt() ?? 0,
    matricula: datos['matricula'] ?? '',
    marca: datos['marca'] ?? '',
    modelo: datos['modelo'] ?? '',
    color: datos['color'] ?? '',
    ano: datos['ano']?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [id, matricula, marca, modelo, color, ano];
}