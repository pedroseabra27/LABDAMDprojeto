import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/booking.dart';

class SocketService {
  late IO.Socket socket;
  final String serverUrl = 'http://10.0.2.2:3001';

  final _bookingUpdateController = StreamController<Booking>.broadcast();
  Stream<Booking> get onBookingUpdated => _bookingUpdateController.stream;

  void connectAndSubscribe(int clienteId) {
    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket.IO Server');
      // Avisa ao backend que queremos ouvir atualizações deste cliente específico
      socket.emit('subscribe_cliente', clienteId);
    });

    socket.on('booking_updated', (data) {
      print('Recebido update do booking: $data');
      final updatedBooking = Booking.fromJson(data);
      _bookingUpdateController.add(updatedBooking);
    });

    socket.onDisconnect((_) => print('Disconnected from Socket.IO Server'));
  }

  void disconnect() {
    socket.disconnect();
    _bookingUpdateController.close();
  }
}
