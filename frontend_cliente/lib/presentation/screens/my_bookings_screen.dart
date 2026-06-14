import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega a lista inicial do banco via REST.
    // As futuras atualizações chegarão sozinhas pelo WebSocket.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchMyBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'solicitado': return Colors.orange;
      case 'confirmado': return Colors.green;
      case 'recusado': return Colors.red;
      case 'concluido': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escutando as mudanças do Provider (incluindo as que vêm do WebSocket)
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Agendamentos')),
      body: provider.isLoadingBookings
          ? const Center(child: CircularProgressIndicator())
          : provider.myBookings.isEmpty
              ? const Center(child: Text('Você não tem agendamentos.'))
              : ListView.builder(
                  itemCount: provider.myBookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.myBookings[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.sports_soccer),
                        title: Text('Quadra ID: ${booking.quadraId}'),
                        subtitle: Text('Data: ${booking.horarioInicio.toString().substring(0, 16)}'),
                        trailing: Chip(
                          label: Text(booking.status.toUpperCase(), 
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: _getStatusColor(booking.status),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
