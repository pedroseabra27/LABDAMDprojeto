import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../models/court.dart';
import '../models/booking.dart';

String get _getBaseUrl {
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3001';
  } catch (_) {}
  return 'http://127.0.0.1:3001';
}

class ApiService {
  String get baseUrl => _getBaseUrl;

  Future<List<Court>> getCourts() async {
    final response = await http.get(Uri.parse('$baseUrl/courts'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Court.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar quadras');
    }
  }

  Future<List<Booking>> getMyBookings(int clienteId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings?clienteId=$clienteId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar agendamentos');
    }
  }

  Future<Booking> createBooking(int quadraId, int clienteId, DateTime horario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'quadraId': quadraId,
        'clienteId': clienteId,
        'horarioInicio': horario.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar agendamento');
    }
  }
}
