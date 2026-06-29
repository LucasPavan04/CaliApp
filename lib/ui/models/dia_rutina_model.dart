import 'package:cali_app/ui/models/detalle_rutina_model.dart';

class DiaRutinaModel {
  final int numero;
  final String nombre;
  final List<DetalleRutinaModel> ejercicios;

  DiaRutinaModel({
    required this.numero,
    required this.nombre,
    required this.ejercicios,
  });

  DiaRutinaModel copy() {
    return DiaRutinaModel(
      numero: numero,
      nombre: nombre,
      ejercicios: ejercicios.map((e) => e.copy()).toList(),
    );
  }
}
