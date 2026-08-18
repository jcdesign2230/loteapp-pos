import 'package:flutter/material.dart';
import '../services/api.service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _jugadaController = TextEditingController();
  final _montoController = TextEditingController();
  
  bool _montoFijo = false;
  List<String> _loteriasSeleccionadas = ["02-LOTERIA NACIONAL"];
  
  // Lista de jugadas cargadas en el ticket actual
  List<Map<String, dynamic>> _jugadasList = [];

  // Loterías disponibles de ejemplo
  final List<String> _loteriasDisponibles = [
    "19-LA SUERTE",
    "04-ANGUILA 6:00 PM",
    "02-LOTERIA NACIONAL",
    "03-LEIDSA",
    "12-LOTEKA"
  ];

  // Calcular monto total
  double get _totalVenta {
    double subtotal = _jugadasList.fold(0.0, (sum, item) => sum + (item['monto'] as double));
    return subtotal * (_loteriasSeleccionadas.isNotEmpty ? _loteriasSeleccionadas.length : 1);
  }

  // Identificar tipo de jugada según longitud o separadores
  String _determinarTipo(String input) {
    String limpia = input.replaceAll('-', '').replaceAll(' ', '');
    if (limpia.length <= 2) return 'QL'; // Quiniela
    if (limpia.length <= 4) return 'PL'; // Palé
    return 'TP'; // Tripleta
  }

  // Formatear string de números para Palé/Tripleta (ej. 1226 -> 12-26)
  String _formatearNumeros(String input) {
    String limpia = input.replaceAll('-', '').replaceAll(' ', '');
    if (limpia.length == 4) {
      return '${limpia.substring(0, 2)}-${limpia.substring(2, 4)}';
    } else if (limpia.length == 6) {
      return '${limpia.substring(0, 2)}-${limpia.substring(2, 4)}-${limpia.substring(4, 6)}';
    }
    return limpia;
  }

  // Agregar jugada a la tabla
  void _agregarJugada() {
    String jugadaTexto = _jugadaController.text.trim();
    String montoTexto = _montoController.text.trim();

    if (jugadaTexto.isEmpty || montoTexto.isEmpty) return;

    double? monto = double.tryParse(montoTexto);
    if (monto == null || monto <= 0) return;

    String tipo = _determinarTipo(jugadaTexto);
    String numeros = _formatearNumeros(jugadaTexto);

    setState(() {
      for (var loteria in _loteriasSeleccionadas) {
        String codigoLot = loteria.contains('-') ? loteria.split('-')[0] : loteria.substring(0, 2);
        _jugadasList.add({
          'tipo': tipo,
          'loteria': codigoLot,
          'loteriaCompleta': loteria,
          'numeros': numeros,
          'monto': monto,
        });
      }

      _jugadaController.clear();
      if (!_montoFijo) {
        _montoController.clear();
      }
    });
  }

  // Función del Botón 'C' (Combinar Quinielas en Palé)
  void _combinarJugadas() {
    // Obtiene todas las quinielas actualmente agregadas
    List<String> quinielas = _jugadasList
        .where((item) => item['tipo'] == 'QL')
        .map((item) => item['numeros'].toString())
        .toSet()
        .toList();

    if (quinielas.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requieren al menos 2 quinielas para combinar en Palé.')),
      );
      return;
    }

    double montoPale = double.tryParse(_montoController.text) ?? 1.0;

    setState(() {
      for (int i = 0; i < quinielas.length; i++) {
        for (int j = i + 1; j < quinielas.length; j++) {
          String paleGenerado = '${quinielas[i]}-${quinielas[j]}';
          for (var loteria in _loteriasSeleccionadas) {
            String codigoLot = loteria.contains('-') ? loteria.split('-')[0] : loteria.substring(0, 2);
            _jugadasList.add({
              'tipo': 'PL',
              'loteria': codigoLot,
              'loteriaCompleta': loteria,
              'numeros': paleGenerado,
              'monto': montoPale,
            });
          }
        }
      }
    });
  }

  // Diálogo para Editar o Quitar Jugada
  void _mostrarOpcionesJugada(int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "¿Que desea hacer?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Editar Jugada Seleccionada", textAlign: TextAlign.center),
                onTap: () {
                  Navigator.pop(ctx);
                  _jugadaController.text = _jugadasList[index]['numeros'];
                  _montoController.text = _jugadasList[index]['monto'].toString();
                  setState(() => _jugadasList.removeAt(index));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Quitar Jugada Seleccionada", textAlign: TextAlign.center),
                onTap: () {
                  setState(() => _jugadasList.removeAt(index));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Atras", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Diálogo para seleccionar loterías
  void _mostrarSelectorLoterias() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Seleccionar Loterías"),
              content: SingleChildScrollView(
                child: Column(
                  children: _loteriasDisponibles.map((loteria) {
                    bool seleccionada = _loteriasSeleccionadas.contains(loteria);
                    return CheckboxListTile(
                      title: Text(loteria),
                      value: seleccionada,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            _loteriasSeleccionadas.add(loteria);
                          } else {
                            _loteriasSeleccionadas.remove(loteria);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Aceptar"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Enviar ticket al backend
  void _finalizarVenta() async {
    if (_jugadasList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos una jugada.')),
      );
      return;
    }

    try {
      final res = await ApiService.crearTicket(
        loterias: _loteriasSeleccionadas,
        jugadas: _jugadasList,
        usuarioId: 1,
        sucursalId: 1,
      );

      if (res['ticket'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket #${res['ticket']['id']} guardado con éxito.')),
        );
        setState(() {
          _jugadasList.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con servidor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String textoLoterias = _loteriasSeleccionadas.isEmpty
        ? "Seleccione las Loterias"
        : _loteriasSeleccionadas.length == 1
            ? _loteriasSeleccionadas.first
            : "${_loteriasSeleccionadas.length} Loterías Seleccionadas";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("LOTEAPPMOVIL", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("2.0.0", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.orange),
              title: const Text("Inicio"),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.teal),
              title: const Text("Ventas"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Bar Superior: Seleccionar Loterías + Copiar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _mostrarSelectorLoterias,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        textoLoterias,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text("Copiar"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total Acumulado
          Text(
            "Total: ${_totalVenta.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),

          // Fila de Entradas: Jugada | Monto | Checkbox | + | C
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _jugadaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Jugada",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Monto",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                  ),
                ),
                Checkbox(
                  value: _montoFijo,
                  onChanged: (val) => setState(() => _montoFijo = val!),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _agregarJugada,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("+", style: TextStyle(fontSize: 20, color: Colors.lightBlue)),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _combinarJugadas,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("C", style: TextStyle(fontSize: 20, color: Colors.lightBlue)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Encabezado de la Tabla
          Container(
            color: Colors.lightBlue,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              children: const [
                Expanded(flex: 1, child: Text("PR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("LOT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("NUM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("MON", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),

          // Lista de Jugadas Agregadas
          Expanded(
            child: ListView.separated(
              itemCount: _jugadasList.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final item = _jugadasList[index];
                return ListTile(
                  dense: true,
                  onTap: () => _mostrarOpcionesJugada(index),
                  title: Row(
                    children: [
                      Expanded(flex: 1, child: Text(item['tipo'])),
                      Expanded(flex: 1, child: Text(item['loteria'])),
                      Expanded(flex: 2, child: Text(item['numeros'])),
                      Expanded(
                        flex: 1,
                        child: Text(
                          (item['monto'] as double).toStringAsFixed(2),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón Inferior: Finalizar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _finalizarVenta,
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text("Finalizar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}