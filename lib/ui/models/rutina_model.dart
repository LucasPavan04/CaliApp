import 'package:cali_app/ui/models/detalle_rutina_model.dart';

class RutinaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final List<DetalleRutinaModel> detalles;

  RutinaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.detalles,
  });
}
