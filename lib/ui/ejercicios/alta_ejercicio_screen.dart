import 'package:cali_app/data/ejercicio_data.dart';
import 'package:cali_app/ui/models/ejercicio_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';

class AltaEjercicioScreen extends StatefulWidget {
  final EjercicioModel? ejercicioExistente;
  final int? indexExistente;

  const AltaEjercicioScreen({
    super.key,
    this.ejercicioExistente,
    this.indexExistente,
  });

  @override
  State<AltaEjercicioScreen> createState() => _AltaEjercicioScreenState();
}

class _AltaEjercicioScreenState extends State<AltaEjercicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.ejercicioExistente;
    if (e != null) {
      _nombreController.text = e.nombre;
      _urlController.text = e.videoUrl;
      _descripcionController.text = e.descripcion;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _urlController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ejercicioExistente != null ? 'Editar ejercicio' : 'Nuevo ejercicio',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del ejercicio',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffFFD700), width: 2),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresá el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL del video explicativo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffFFD700), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresá la URL del video';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'URL inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción del ejercicio',
                  hintText: 'Explicá en qué consiste el ejercicio',
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffFFD700), width: 2),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Ingresá una descripción'
                        : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final nombre = _nombreController.text.trim();
                      final url = _urlController.text.trim();
                      final descripcion = _descripcionController.text.trim();
                      final nuevo = EjercicioModel(
                        nombre: nombre,
                        videoUrl: url,
                        descripcion: descripcion,
                      );

                      if (widget.indexExistente != null) {
                        EjercicioData().actualizarEjercicio(widget.indexExistente!, nuevo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ejercicio actualizado',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Color(0xffFFD700),
                          ),
                        );
                      } else {
                        EjercicioData().ejercicios.add(nuevo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ejercicio registrado exitosamente',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Color(0xffFFD700),
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.ejercicioExistente != null ? 'Guardar cambios' : 'Registrar ejercicio',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
