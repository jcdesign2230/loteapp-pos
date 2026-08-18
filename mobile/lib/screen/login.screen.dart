import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _recordarPassword = false;

  void _iniciarSesion() {
    if (_usuarioController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/ventas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
          child: Column(
            crossAxisAlignment: CrossAlignment.center,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  child: Column(
                    children: [
                      Text("Iniciar Sesión", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("LOTEAPPMOVIL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Usuario", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  hintText: 'Usuario',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Contraseña", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _recordarPassword,
                    onChanged: (val) => setState(() => _recordarPassword = val!),
                  ),
                  const Text("Recordar contraseña"),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _iniciarSesion,
                  child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
              Text("2.0.0", style: TextStyle(color: Colors.grey[600])),
              Text("Powered By Tecnolora", style: TextStyle(color: Colors.grey[600])),
              Text("info@tecnolora.com", style: TextStyle(color: Colors.grey[600])),
              Text("Serie: 70d680197ce8bb8a", style: TextStyle(color: Colors.grey[600])),
              Text("Android: 13", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}