import 'package:cali_app/ui/models/dia_rutina_model.dart';

class RutinaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final List<DiaRutinaModel> dias;

  RutinaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.dias,
  });

  int get cantidadDias => dias.length;

  int get cantidadEjercicios =>
      dias.fold(0, (total, dia) => total + dia.ejercicios.length);

  RutinaModel copy() {
    return RutinaModel(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      dias: dias.map((d) => d.copy()).toList(),
    );
  }
}
