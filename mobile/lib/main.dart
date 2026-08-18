import 'package:flutter/material.dart';
import 'screen/login.screen.dart';
import 'screen/ventas.screen.dart';

void main() {
  runApp(const LoteApp());
}

class LoteApp extends StatelessWidget {
  const LoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoteAppMovil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/ventas': (context) => const VentasScreen(),
      },
    );
  }
}