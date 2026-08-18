import 'package:flutter/material.dart';
import '../services/api.service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _numeroController = TextEditingController();
  final _montoController = TextEditingController();

  String _loteriaSeleccionada = 'Gana Más';
  final List<String> _loterias = ['Gana Más', 'Nacional', 'Leidsa', 'Real', 'Loteka'];

  final List<Map<String, dynamic>> _jugadas = [];

  void _agregarJugada() {
    final numero = _numeroController.text.trim();
    final montoText = _montoController.text.trim();

    if (numero.isEmpty || montoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa número y monto')),
      );
      return;
    }

    final double? monto = double.tryParse(montoText);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    setState(() {
      _jugadas.add({
        'numero': numero,
        'monto': monto,
        'loteria': _loteriaSeleccionada,
      });
      _numeroController.clear();
      _montoController.clear();
    });
  }

  double get _totalVenta => _jugadas.fold(0, (sum, item) => sum + (item['monto'] as double));

  void _procesarVenta() async {
    if (_jugadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay jugadas en el ticket')),
      );
      return;
    }

    final ticket = {
      'usuario_id': 1,
      'sucursal_id': 1,
      'loterias': [_loteriaSeleccionada],
      'jugadas': _jugadas
          .map((jugada) => {
                'tipo': 'QUINIELA',
                'numeros': jugada['numero'],
                'monto': jugada['monto'],
              })
          .toList(),
    };

    final ticketRegistrado = await ApiService.registrarTicket(ticket);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ticketRegistrado ? 'Ticket Registrado' : 'Procesado Localmente'),
        content: Text('Total a cobrar: RD\$ ${_totalVenta.toStringAsFixed(2)}\n\n¿Desea imprimir la copia del cliente?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _jugadas.clear());
            },
            child: const Text('Aceptar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Ventas - LOTEAPP'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Izquierdo: Formulario
            Expanded(
              flex: 2,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nueva Jugada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      DropdownButtonFormField(
                        initialValue: _loteriaSeleccionada,
                        decoration: const InputDecoration(labelText: 'Sorteo / Lotería', border: OutlineInputBorder()),
                        items: _loterias.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (val) => setState(() => _loteriaSeleccionada = val!),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Número (ej: 05, 12, 99)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _montoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Monto RD\$', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: _agregarJugada,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar Jugada'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Panel Derecho: Detalle del Ticket
            Expanded(
              flex: 3,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Detalle del Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => setState(() => _jugadas.clear()),
                          )
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: _jugadas.isEmpty
                            ? const Center(child: Text('No hay jugadas agregadas.'))
                            : ListView.builder(
                                itemCount: _jugadas.length,
                                itemBuilder: (ctx, i) {
                                  final item = _jugadas[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green[100],
                                      child: Text(item['numero'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    ),
                                    title: Text('${item['loteria']}'),
                                    subtitle: Text('Número: ${item['numero']}'),
                                    trailing: Text('RD\$ ${(item['monto'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('RD\$ ${_totalVenta.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: _procesarVenta,
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir / Finalizar Ticket', style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}