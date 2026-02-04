import 'package:flutter/material.dart';

class RutinaCardModel {
  final String title;
  final String description;
  final IconData? icon;
  final Function? onTap;

  RutinaCardModel(
      {required this.title, required this.description, this.icon, this.onTap});
}
