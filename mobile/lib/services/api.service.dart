import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ajusta la URL base según el entorno de desarrollo
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, dynamic>?> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> registrarTicket(Map<String, dynamic> ticketData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ticketData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}