import 'package:flutter/material.dart';
import 'package:shared_core/models/booking.dart';
import 'package:shared_core/services/api_service.dart';
import 'package:shared_core/services/socket_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  final SocketService socketService = SocketService();

  // Vamos hardcodar o clienteId = 1 para facilitar os testes,
  // mas em um app real isso viria do login.
  final int currentClienteId = 1;

  List<Booking> myBookings = [];
  bool isLoadingBookings = false;

  AppProvider() {
    _initSocket();
  }

  void _initSocket() {
    socketService.connectAndSubscribe(currentClienteId);
    socketService.onBookingUpdated.listen((updatedBooking) {
      // Atualiza o agendamento na lista
      final index = myBookings.indexWhere((b) => b.id == updatedBooking.id);
      if (index != -1) {
        myBookings[index] = updatedBooking;
        notifyListeners();
      }
    });
  }

  Future<void> fetchMyBookings() async {
    isLoadingBookings = true;
    notifyListeners();
    try {
      myBookings = await apiService.getMyBookings(currentClienteId);
    } catch (e) {
      print('Erro ao buscar agendamentos: $e');
    }
    isLoadingBookings = false;
    notifyListeners();
  }

  Future<void> createBooking(int quadraId, DateTime horario) async {
    try {
      final newBooking = await apiService.createBooking(quadraId, currentClienteId, horario);
      myBookings.add(newBooking);
      notifyListeners();
    } catch (e) {
      print('Erro ao criar agendamento: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }
}
