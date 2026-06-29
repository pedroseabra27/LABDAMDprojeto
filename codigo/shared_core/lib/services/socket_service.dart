import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' show Platform;
import '../models/booking.dart';

String get _getSocketUrl {
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3001';
  } catch (_) {}
  return 'http://127.0.0.1:3001';
}

class SocketService {
  late IO.Socket socket;
  String get serverUrl => _getSocketUrl;

  final _bookingUpdateController = StreamController<Booking>.broadcast();
  Stream<Booking> get onBookingUpdated => _bookingUpdateController.stream;

  final _newBookingController = StreamController<Booking>.broadcast();
  Stream<Booking> get onNewBooking => _newBookingController.stream;

  // Conecta como CLIENTE
  void connectAndSubscribe(int clienteId) {
    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .enableForceNew()
      .build()
    );

    socket.connect();

    socket.onConnect((_) {
      print('[Socket] Conectado como cliente $clienteId');
      socket.emit('subscribe_cliente', clienteId);
    });

    socket.on('booking_updated', (data) {
      print('[Socket] booking_updated recebido: $data');
      final updatedBooking = Booking.fromJson(data);
      _bookingUpdateController.add(updatedBooking);
    });

    socket.onDisconnect((_) => print('[Socket] Desconectado'));
  }

  // Conecta como PRESTADOR
  void connectAndSubscribeAsPrestador(int prestadorId) {
    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .enableForceNew()
      .build()
    );

    socket.connect();

    socket.onConnect((_) {
      print('[Socket] Conectado como prestador $prestadorId');
      socket.emit('subscribe_prestador', prestadorId);
    });

    socket.on('new_booking', (data) {
      print('[Socket] new_booking recebido: $data');
      final newBooking = Booking.fromJson(data);
      _newBookingController.add(newBooking);
    });

    socket.onDisconnect((_) => print('[Socket] Desconectado'));
  }

  void disconnect() {
    socket.disconnect();
  }
}
