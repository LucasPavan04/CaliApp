import 'package:flutter/material.dart';

class MenuModel {
  final String title;
  final String description;
  final String? url;
  final IconData? icon;
  final Function? onTap;
  final Widget? screenToNavigate;

  MenuModel(
      {required this.title, required this.description, this.icon, this.url, this.onTap, this.screenToNavigate});
}
