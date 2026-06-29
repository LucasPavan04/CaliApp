import 'package:cali_app/config/app_branding.dart';
import 'package:cali_app/ui/home/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppBranding.appName,
      theme: AppBranding.theme,
      home: const LoginScreen(),
    );
  }
}
