import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prestador_provider.dart';
import 'login_screen.dart';

class OngoingScreen extends StatefulWidget {
  const OngoingScreen({super.key});

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrestadorProvider>(context, listen: false).fetchBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado': return const Color(0xFF27AE60);
      case 'concluido': return const Color(0xFF2980B9);
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmado': return 'CONFIRMADO';
      case 'concluido': return 'CONCLUÍDO';
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrestadorProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 24),
            const SizedBox(width: 8),
            const Text('Em Andamento'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFE74C3C)),
            onPressed: () {
              provider.logout();
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.acceptedBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Nenhum agendamento em andamento',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.acceptedBookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.acceptedBookings[index];
                    final statusColor = _getStatusColor(booking.status);
                    final statusLabel = _getStatusLabel(booking.status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: statusColor.withOpacity(0.15),
                              child: Icon(Icons.sports_soccer, color: statusColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.getCourtName(booking.quadraId),
                                      style: const TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Data: ${booking.horarioInicio.toLocal().toString().substring(0, 16)}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(statusLabel,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                if (booking.status == 'confirmado') ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2980B9),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await provider.completeBooking(booking.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Agendamento concluído!')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Erro: ${e.toString()}')),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Concluir', style: TextStyle(fontSize: 12, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
