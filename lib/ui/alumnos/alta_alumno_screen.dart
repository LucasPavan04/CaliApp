import 'package:cali_app/config/app_branding.dart';
import 'package:cali_app/data/alumno_data.dart';
import 'package:cali_app/ui/models/alumno_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';

class AltaAlumnoScreen extends StatefulWidget {
  final Alumno? alumnoExistente;

  const AltaAlumnoScreen({super.key, this.alumnoExistente});

  @override
  State<AltaAlumnoScreen> createState() => _AltaAlumnoScreenState();
}

class _AltaAlumnoScreenState extends State<AltaAlumnoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    final a = widget.alumnoExistente;
    if (a != null) {
      final partes = a.nombreCompleto.split(' ');
      _nombreController.text = partes.isNotEmpty ? partes.first : '';
      _apellidoController.text = partes.length > 1 ? partes.sublist(1).join(' ') : '';
      _dniController.text = a.dni;
      _direccionController.text = a.direccion;
      _fechaNacimiento = a.fechaNacimiento;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),

              // Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese el apellido'
                    : null,
              ),

              // DNI
              TextFormField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'DNI'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el DNI';
                  }
                  if (int.tryParse(value) == null) {
                    return 'DNI inválido';
                  }
                  return null;
                },
              ),

              // Dirección
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese la dirección'
                    : null,
              ),

              // Fecha de nacimiento
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaNacimiento == null
                          ? 'Seleccione fecha de nacimiento'
                          : 'Fecha: ${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2005),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaNacimiento = picked;
                        });
                      }
                    },
                    child: const Text('Elegir fecha', style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(AppBranding.primary),
                      foregroundColor: WidgetStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _fechaNacimiento != null) {
                    final nombreCompleto =
                        '${_nombreController.text.trim()} ${_apellidoController.text.trim()}';
                    final nuevo = Alumno(
                      nombreCompleto: nombreCompleto,
                      dni: _dniController.text.trim(),
                      direccion: _direccionController.text.trim(),
                      fechaNacimiento: _fechaNacimiento!,
                      isAdmin: widget.alumnoExistente?.isAdmin ?? false,
                    );
                    if (widget.alumnoExistente != null) {
                      AlumnoData().actualizarAlumno(widget.alumnoExistente!.dni, nuevo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alumno actualizado', style: TextStyle(color: Colors.black)),
                          backgroundColor: AppBranding.primary,
                        ),
                      );
                    } else {
                      AlumnoData().alumnos.add(nuevo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alumno registrado exitosamente', style: TextStyle(color: Colors.black)),
                          backgroundColor: AppBranding.primary,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  } else if (_fechaNacimiento == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Seleccione la fecha de nacimiento', style: TextStyle(color: Colors.black),),
                          backgroundColor: AppBranding.primary,),
                    );
                  }
                },
                child: Text(
                  widget.alumnoExistente != null ? 'Guardar cambios' : 'Registrar alumno',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
