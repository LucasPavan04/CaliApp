import 'package:cali_app/config/app_branding.dart';
import 'package:cali_app/data/alumno_data.dart';
import 'package:cali_app/ui/alumnos/alta_alumno_screen.dart';
import 'package:cali_app/ui/alumnos/alumno_rutina_screen.dart';
import 'package:cali_app/ui/models/alumno_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';

class AlumnosScreen extends StatefulWidget {
  const AlumnosScreen({super.key});

  @override
  State<AlumnosScreen> createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  final TextEditingController _searchController = TextEditingController();
/*
  TODO: borrar esto ...
  final List<Alumno> alumnos = [
    Alumno(nombreCompleto: 'Juan Pérez', dni: '12345678'),
    Alumno(nombreCompleto: 'María García', dni: '87654321'),
    Alumno(nombreCompleto: 'Lucas Fernández', dni: '45678912'),
    Alumno(nombreCompleto: 'Ana Torres', dni: '19876543'),
  ];
*/
  List<Alumno> alumnosFiltrados = [];

  @override
  void initState() {
    super.initState();
    alumnosFiltrados = List.from(AlumnoData().alumnos);
    _searchController.addListener(() {
      _filtrarAlumnos();
      setState(() {}); // Actualiza la UI para mostrar/ocultar el botón clear
    });
  }

  void _filtrarAlumnos() {
    final lista = AlumnoData().alumnos;
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        alumnosFiltrados = List.from(lista);
      } else {
        alumnosFiltrados = lista
            .where((a) =>
                a.nombreCompleto.toLowerCase().contains(query) ||
                a.dni.contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFloatingActionButton: true,
      icono: Icons.add,
      onPress: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AltaAlumnoScreen()),
        );
        if (mounted) setState(() => _filtrarAlumnos());
      },
      heroTag: 'FAB1',
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Buscador
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre o DNI',
                  hintText: 'Ej: Juan o 12345678',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarAlumnos();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppBranding.primary, width: 2),
                  ),
                ),
              ),
            ),

            // Lista de alumnos filtrados
            ...alumnosFiltrados.map((alumno) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppBranding.primary.withOpacity(0.3),
                            child: Text(
                              alumno.nombreCompleto.isNotEmpty
                                  ? alumno.nombreCompleto[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alumno.nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'DNI: ${alumno.dni}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey.shade700),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AltaAlumnoScreen(
                                    alumnoExistente: alumno,
                                  ),
                                ),
                              );
                              if (mounted) setState(() => _filtrarAlumnos());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.fitness_center, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppBranding.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlumnoRutinaScreen(
                                alumno: alumno,
                                showAssignDelete: true,
                              ),
                            ),
                          ),
                          label: const Text('Ver rutinas asignadas'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            if (alumnosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No se encontraron alumnos'),
              ),
          ],
        ),
      ),
    );
  }
}
