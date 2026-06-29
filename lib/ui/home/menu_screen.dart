import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/alumnos/alumno_rutina_screen.dart';
import 'package:cali_app/ui/alumnos/alumnos_screen.dart';
import 'package:cali_app/ui/ejercicios/detalle_ejercicio_screen.dart';
import 'package:cali_app/ui/ejercicios/detalle_rutina_screen.dart';
import 'package:cali_app/ui/ejercicios/rutinas_screen.dart';
import 'package:cali_app/ui/home/login_screen.dart';
import 'package:cali_app/ui/models/alumno_model.dart';
import 'package:cali_app/ui/models/menu_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final Alumno alumno;

  const MenuScreen({super.key, required this.alumno});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuModel> _buildMenu() {
    if (widget.alumno.isAdmin) {
      return [
        MenuModel(
          title: 'Alumnos',
          description: 'Ver todos los usuarios y sus rutinas',
          icon: Icons.people,
          screenToNavigate: const AlumnosScreen(),
        ),
        MenuModel(
          title: 'Rutinas',
          description: 'Dar de alta y gestionar rutinas',
          icon: Icons.fitness_center,
          screenToNavigate: const RutinasScreen(),
        ),
        MenuModel(
          title: 'Ejercicios',
          description: 'Dar de alta y ver ejercicios',
          icon: Icons.sports_gymnastics,
          screenToNavigate: const DetalleEjercicioScreen(),
        ),
      ];
    }
    return [
      MenuModel(
        title: 'Mi rutina',
        description: 'Ver mi rutina asignada',
        icon: Icons.calendar_today,
        screenToNavigate: AlumnoRutinaScreen(
          alumno: widget.alumno,
          showAssignDelete: widget.alumno.isAdmin,
        ),
      ),
      MenuModel(
        title: 'Generar día extra de ejercicio',
        description: 'Un día complementario por semana',
        icon: Icons.add_circle_outline,
        onTap: _generarDiaExtra,
      ),
    ];
  }

  void _generarDiaExtra() {
    final dni = widget.alumno.dni;

    if (!RutinaData().puedeGenerarDiaExtra(dni)) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Día extra no disponible'),
          content: const Text(
            'Comunicate con el profesor para planificar una nueva rutina, '
            'adaptada a la cantidad de dias que desees entrenar',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final rutina = RutinaData().generarDiaExtra(dni);
    if (rutina == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay ejercicios disponibles para generar un día extra',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xffFFD700),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Día extra creado con ${rutina.cantidadEjercicios} ejercicios',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xffFFD700),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleRutinaScreen(
          rutina: rutina,
          dniAlumno: dni,
        ),
      ),
    );
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = _buildMenu();
    return AppLayout(
      showBackButton: false,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${widget.alumno.nombreCompleto.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.alumno.isAdmin)
                        Chip(
                          label: const Text('Administrador', style: TextStyle(fontSize: 11)),
                          backgroundColor: const Color(0xffFFD700),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout, size: 18, color: Colors.black54),
                  label: const Text('Salir', style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: menu.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = menu[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (item.onTap != null) {
                        item.onTap!();
                        return;
                      }
                      final screen = item.screenToNavigate;
                      if (screen != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screen),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xffFFD700).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon ?? Icons.arrow_forward,
                              color: const Color(0xffFFD700),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
