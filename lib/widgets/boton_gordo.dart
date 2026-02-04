import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class BotonGordo extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color color1;
  final Color color2;
  final Function onPress;

  const BotonGordo(
      {super.key,
      required this.icon,
      required this.texto,
      required this.color1,
      required this.color2,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Stack(
        children: [
          const _BotonGordoBackground(
            icon: FontAwesomeIcons.carCrash,
            color1: Color(0xff6989F5),
            color2: Color(0xff906EF5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 140,
                width: 20,
              ),
              FaIcon(
                icon, //FontAwesomeIcons.carCrash,
                color: color1,
                size: 40,
              ),
              const Gap(20),
              Text(
                texto,
                style: TextStyle(
                  color: color2,
                  fontSize: 18,
                ),
              ),
              const Gap(40),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonGordoBackground extends StatelessWidget {
  final IconData icon;
  final Color color1;
  final Color color2;

  const _BotonGordoBackground(
      {required this.icon, required this.color1, required this.color2});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          // color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(4, 6),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              color1, // Color(0xff6989F5),
              color2, // Color(0xff906EF5),
            ],
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned(
                right: -20,
                top: -20,
                child: FaIcon(
                  icon, //FontAwesomeIcons.carCrash,
                  size: 150,
                  color: Colors.white.withOpacity(0.2),
                )),
          ],
        ),
      ),
    );
  }
}
