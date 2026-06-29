import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebracionDiaCompletado extends StatefulWidget {
  final String nombreDia;

  const CelebracionDiaCompletado({super.key, required this.nombreDia});

  static Future<void> mostrar(BuildContext context, String nombreDia) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Celebración',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, _, __) {
        return CelebracionDiaCompletado(nombreDia: nombreDia);
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<CelebracionDiaCompletado> createState() =>
      _CelebracionDiaCompletadoState();
}

class _CelebracionDiaCompletadoState extends State<CelebracionDiaCompletado>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final List<_Particula> _particulas;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _scale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );

    final random = math.Random();
    _particulas = List.generate(14, (i) {
      final angle = (i / 14) * 2 * math.pi;
      return _Particula(
        color: [
          const Color(0xffFFD700),
          Colors.orange.shade300,
          Colors.amber.shade200,
          Colors.yellow.shade600,
        ][i % 4],
        angle: angle,
        distance: 40 + random.nextDouble() * 50,
        size: 6 + random.nextDouble() * 6,
      );
    });

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ..._particulas.map((p) {
                final progress = Curves.easeOut.transform(
                  _mainController.value.clamp(0.0, 1.0),
                );
                final dx = math.cos(p.angle) * p.distance * progress;
                final dy = math.sin(p.angle) * p.distance * progress;
                return Positioned(
                  left: dx,
                  top: dy,
                  child: Opacity(
                    opacity: (1 - progress).clamp(0.0, 1.0),
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffFFD700).withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFD700).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 48,
                            color: Color(0xffE6B800),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Día completado!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.nombreDia,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seguí así 💪',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particula {
  final Color color;
  final double angle;
  final double distance;
  final double size;

  const _Particula({
    required this.color,
    required this.angle,
    required this.distance,
    required this.size,
  });
}
