import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/court.dart';
import '../../domain/models/booking.dart';

class ApiService {
  // Para Android Emulator use 10.0.2.2. Para Web ou iOS simulator use localhost.
  // Ajuste para o IP local se rodar em device físico.
  static const String baseUrl = 'http://10.0.2.2:3001';

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
        'horarioInicio': horario.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar agendamento');
    }
  }
}
