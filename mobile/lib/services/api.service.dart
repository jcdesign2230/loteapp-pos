import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // En Codespaces/Localhost la URL base cambia según tu puerto expuesto
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, dynamic>> crearTicket({
    required List<String> loterias,
    required List<Map<String, dynamic>> jugadas,
    required int usuarioId,
    required int sucursalId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/crear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'sucursal_id': sucursalId,
        'loterias': loterias,
        'jugadas': jugadas,
        'porcentaje_comision': 5.0,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> anularTicket(String ticketId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets/anular'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ticketId': ticketId,
        'usuario': {'permiso_anular': true},
      }),
    );

    return jsonDecode(response.body);
  }
}