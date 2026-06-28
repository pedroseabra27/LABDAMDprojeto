import 'package:flutter/material.dart';
import 'package:shared_core/models/booking.dart';
import 'dart:async';
import 'package:shared_core/models/court.dart';
import 'package:shared_core/services/api_service.dart';
import 'package:shared_core/services/socket_service.dart';
import 'package:shared_core/services/auth_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  final SocketService socketService = SocketService();
  late final AuthService authService;

  AppProvider() {
    authService = AuthService(apiService);
  }

  int currentClienteId = 0;
  String? userName;
  String? userEmail;

  StreamSubscription? _socketSubscription;

  List<Booking> myBookings = [];
  List<Court> courts = [];
  bool isLoadingBookings = false;

  Future<void> login(String email, String senha) async {
    final result = await authService.login(email, senha);
    currentClienteId = result['usuario']['id'];
    userName = result['usuario']['nome'];
    userEmail = result['usuario']['email'];
    _initSocket();
    notifyListeners();
  }

  void logout() {
    authService.logout();
    currentClienteId = 0;
    myBookings.clear();
    socketService.disconnect();
    _socketSubscription?.cancel();
    notifyListeners();
  }

  void _initSocket() {
    socketService.connectAndSubscribe(currentClienteId);
    _socketSubscription?.cancel();
    _socketSubscription = socketService.onBookingUpdated.listen((updatedBooking) {
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
      if (courts.isEmpty) {
        courts = await apiService.getCourts();
      }
      myBookings = await apiService.getMyBookings(currentClienteId);
    } catch (e) {
      print('Erro ao buscar agendamentos: $e');
    }
    isLoadingBookings = false;
    notifyListeners();
  }

  String getCourtName(int id) {
    try {
      return courts.firstWhere((c) => c.id == id).nome;
    } catch (_) {
      return 'Quadra $id';
    }
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
