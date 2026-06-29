import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/models/booking.dart';
import '../providers/prestador_provider.dart';

class RequestDetailScreen extends StatelessWidget {
  final Booking booking;

  const RequestDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrestadorProvider>(context, listen: false);
    final courtName = provider.getCourtName(booking.quadraId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        backgroundColor: const Color(0xFF1B2838),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de informações
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF1B2838)),
                  const SizedBox(height: 16),
                  Text(courtName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Caveat', fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B2838)),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_today, 'Data e Hora',
                      booking.horarioInicio.toLocal().toString().substring(0, 16)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.confirmation_num, 'Código',
                      '#${booking.id.toString().padLeft(4, '0')}'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person, 'Cliente ID',
                      '${booking.clienteId}'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('STATUS: SOLICITADO',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Recusar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        try {
                          await provider.rejectBooking(booking.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Solicitação recusada.')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Aceitar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        try {
                          await provider.acceptBooking(booking.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Solicitação aceita!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}
