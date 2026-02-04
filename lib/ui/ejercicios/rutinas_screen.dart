import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/ejercicios/alta_rutina_screen.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/rutina_card.dart';
import 'package:flutter/material.dart';

class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  @override
  Widget build(BuildContext context) {
    final plantillas = RutinaData().getRutinasPlantilla();

    return AppLayout(
      showFloatingActionButton: true,
      icono: Icons.add,
      heroTag: 'FAB2',
      onPress: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AltaRutinaScreen()),
        );
        if (mounted) setState(() {});
      },
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Plantillas de rutinas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...plantillas.map(
              (rutina) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RutinaCardWidget(rutina: rutina),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

