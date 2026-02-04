import 'package:cali_app/widgets/boton_back.dart';
import 'package:cali_app/widgets/header.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    this.content,
    this.showFloatingActionButton,
    this.icono,
    this.onPress,
    this.heroTag,
    this.showBackButton = true,
  });
  final Widget? content;
  final bool? showFloatingActionButton;
  final IconData? icono;
  final VoidCallback? onPress;
  final String? heroTag;
  final bool showBackButton;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const HeaderWavesGradient(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.28,
                width: double.infinity,
                child: Image.asset(
                  'assets/F2.PNG',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (widget.showBackButton)
              const Positioned(
                top: 20,
                child: BotonBack(),
              ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.3,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: widget.content!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.showFloatingActionButton ?? false
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.15, // ancho personalizado
              height: MediaQuery.of(context).size.height * 0.15, // alto personalizado
              child: FloatingActionButton(
                heroTag: widget.heroTag,
                onPressed: widget.onPress,
                backgroundColor: const Color(0xffFFD700),
                shape: const CircleBorder(), // asegura forma redonda
                child: Icon(
                  widget.icono,
                  size: 30, // tamaño del ícono
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
