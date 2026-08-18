import 'package:flutter/material.dart';
import 'screens/login.screen.dart';
import 'screens/ventas.screen.dart';

void main() {
  runApp(const LoteApp());
}

class LoteApp extends StatelessWidget {
  const LoteApp({Key? key}) : super(key: key);

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