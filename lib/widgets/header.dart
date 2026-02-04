import 'package:flutter/material.dart';

class HeaderWavesGradient extends StatelessWidget {
  const HeaderWavesGradient({super.key});

  @override
  Widget build(context) {
    return Container(
      //*Defino mi canvas como toda la pantalla del dispositivo ...
      height: double.infinity,
      width: double.infinity,
      // color: Color(0xff615AAB),
      child: CustomPaint(
        painter: _HeaderWavesGradient(),
      ),
    );
  }
}

class _HeaderWavesGradient extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.35);

    const Gradient gradiente = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color(0xffFFD700),
        Color(0xffFFC107),
      ],
    );

    final paint = Paint()..shader = gradiente.createShader(rect);
    paint.color = const Color(0xffFFD700);
    //*El stroke son los bordes y el fill es cuando lo quiero rellenar ...
    paint.style = PaintingStyle.fill; //PaintingStyle.stroke;
    paint.strokeWidth = 20;

    final path = Path();
    //*Dibujar con el path y el lapiz ...
    path.lineTo(0, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.3,
        size.width * 0.5, size.height * 0.25);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.2, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
