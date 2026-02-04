import 'package:flutter/material.dart';

class BotonBack extends StatelessWidget {
  const BotonBack({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      child: const Icon(
        Icons.chevron_left,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
