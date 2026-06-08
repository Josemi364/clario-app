import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // ── Token management ──────────────────────────────────────────
  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ── Headers ───────────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await obtenerToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registro(
      String email, String password, String nif, String nombreFiscal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/auth/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nif': nif,
        'nombreFiscal': nombreFiscal,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── Dashboard ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSueldoNeto() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/dashboard/sueldo-neto'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ── Facturas ──────────────────────────────────────────────────
  static Future<List<dynamic>> getFacturas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/facturas'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> crearFactura(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/facturas'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ── Gastos ────────────────────────────────────────────────────
  static Future<List<dynamic>> getGastos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/gastos'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> crearGasto(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/gastos'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
  static Future<Map<String, dynamic>> analizarFacturaOcr(File imagen) async {
  final token = await obtenerToken();
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/v1/ocr/factura'),
  );
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return jsonDecode(response.body);
}
}