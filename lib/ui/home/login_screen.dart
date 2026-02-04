import 'package:cali_app/data/alumno_data.dart';
import 'package:cali_app/ui/home/menu_screen.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  void _ingresar() {
    if (_formKey.currentState?.validate() != true) return;
    final dni = _dniController.text.trim();
    final alumno = AlumnoData().findByDni(dni);
    if (alumno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('DNI no encontrado. Verificá e intentá de nuevo.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(alumno: alumno),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showFloatingActionButton: false,
      showBackButton: false,
      content: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
          vertical: MediaQuery.of(context).size.height * 0.06,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                'Cali Gym',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresá tu DNI para continuar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _dniController,
                decoration: InputDecoration(
                  labelText: 'DNI',
                  hintText: 'Ej: 12345678',
                  prefixIcon: const Icon(Icons.badge_outlined),
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
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresá tu DNI';
                  if (v.trim().length < 7) return 'DNI inválido';
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: _styleButton(context),
                  onPressed: _ingresar,
                  child: const Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _styleButton(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffFFD700),
      foregroundColor: Colors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
