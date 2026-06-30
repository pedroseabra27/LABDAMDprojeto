import 'package:flutter/material.dart';
import 'package:shared_core/models/booking.dart';
import 'package:shared_core/models/court.dart';
import 'package:shared_core/services/api_service.dart';
import 'package:shared_core/services/socket_service.dart';
import 'package:shared_core/services/auth_service.dart';
import 'dart:async';

class PrestadorProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  final SocketService socketService = SocketService();
  late final AuthService authService;

  PrestadorProvider() {
    authService = AuthService(apiService);
  }

  int currentPrestadorId = 0;
  String? userName;
  String? userEmail;

  StreamSubscription? _socketSubscription;

  List<Booking> pendingBookings = [];
  List<Booking> acceptedBookings = [];
  List<Court> courts = [];
  bool isLoading = false;

  Future<void> login(String email, String senha) async {
    final result = await authService.login(email, senha);
    currentPrestadorId = result['usuario']['id'];
    userName = result['usuario']['nome'];
    userEmail = result['usuario']['email'];
    _initSocket();
    notifyListeners();
  }

  void logout() {
    authService.logout();
    currentPrestadorId = 0;
    pendingBookings.clear();
    acceptedBookings.clear();
    socketService.disconnect();
    _socketSubscription?.cancel();
    notifyListeners();
  }

  void _initSocket() {
    socketService.connectAndSubscribeAsPrestador(currentPrestadorId);
    _socketSubscription?.cancel();
    _socketSubscription = socketService.onNewBooking.listen((newBooking) {
      // Um novo agendamento chegou em tempo real!
      pendingBookings.insert(0, newBooking);
      notifyListeners();
    });
  }

  Future<void> fetchBookings() async {
    isLoading = true;
    notifyListeners();
    try {
      if (courts.isEmpty) {
        courts = await apiService.getCourts();
      }
      final all = await apiService.getBookingsForPrestador(currentPrestadorId);
      pendingBookings = all.where((b) => b.status == 'solicitado').toList();
      acceptedBookings = all.where((b) => b.status == 'confirmado' || b.status == 'concluido').toList();
    } catch (e) {
      print('Erro ao buscar agendamentos: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  String getCourtName(int id) {
    try {
      return courts.firstWhere((c) => c.id == id).nome;
    } catch (_) {
      return 'Quadra $id';
    }
  }

  String? getCourtImageUrl(int id) {
    try {
      return courts.firstWhere((c) => c.id == id).imagemUrl;
    } catch (_) {
      return null;
    }
  }

  Future<void> acceptBooking(int bookingId) async {
    try {
      final updated = await apiService.updateBookingStatus(bookingId, 'confirmado');
      pendingBookings.removeWhere((b) => b.id == bookingId);
      acceptedBookings.insert(0, updated);
      notifyListeners();
    } catch (e) {
      print('Erro ao aceitar agendamento: $e');
      rethrow;
    }
  }

  Future<void> rejectBooking(int bookingId) async {
    try {
      await apiService.updateBookingStatus(bookingId, 'recusado');
      pendingBookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } catch (e) {
      print('Erro ao recusar agendamento: $e');
      rethrow;
    }
  }

  Future<void> completeBooking(int bookingId) async {
    try {
      final updated = await apiService.updateBookingStatus(bookingId, 'concluido');
      final index = acceptedBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        acceptedBookings[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      print('Erro ao concluir agendamento: $e');
      rethrow;
    }
  }

  Future<void> createCourt({
    required String nome,
    required String esporte,
    required String precoHora,
    String? imagemUrl,
    String? endereco,
    String? descricao,
  }) async {
    try {
      final novaQuadra = await apiService.createCourt(
        nome: nome,
        esporte: esporte,
        precoHora: precoHora,
        prestadorId: currentPrestadorId,
        imagemUrl: imagemUrl,
        endereco: endereco,
        descricao: descricao,
      );
      courts.add(novaQuadra);
      notifyListeners();
    } catch (e) {
      print('Erro ao criar quadra: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    socketService.disconnect();
    _socketSubscription?.cancel();
    super.dispose();
  }
}
