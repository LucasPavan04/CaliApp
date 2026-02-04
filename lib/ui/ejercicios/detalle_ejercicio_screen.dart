import 'package:cali_app/data/ejercicio_data.dart';
import 'package:cali_app/ui/ejercicios/alta_ejercicio_screen.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/ejercicio_card.dart';
import 'package:flutter/material.dart';

class DetalleEjercicioScreen extends StatefulWidget {
  const DetalleEjercicioScreen({super.key});

  @override
  State<DetalleEjercicioScreen> createState() => _DetalleEjercicioScreenState();
}

class _DetalleEjercicioScreenState extends State<DetalleEjercicioScreen> {
  @override
  Widget build(BuildContext context) {
    final ejercicios = EjercicioData().ejercicios;

    return AppLayout(
      showFloatingActionButton: true,
      icono: Icons.add,
      onPress: () async {
        // Cuando volvés de alta, refrescamos la lista
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AltaEjercicioScreen()),
        );
        setState(() {});
      },
      heroTag: 'FAB3',
      content: SingleChildScrollView(
        child: Column(
          children: ejercicios.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return EjercicioCard(
              ejercicio: e,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AltaEjercicioScreen(
                      ejercicioExistente: e,
                      indexExistente: index,
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
