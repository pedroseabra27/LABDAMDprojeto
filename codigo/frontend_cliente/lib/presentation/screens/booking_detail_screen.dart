import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/models/booking.dart';
import '../providers/app_provider.dart';
import '../widgets/status_badge.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

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
    final provider = Provider.of<AppProvider>(context, listen: false);
    final courtName = provider.getCourtName(booking.quadraId);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, size: 80, color: Color(0xFFC06B52)),
                  const SizedBox(height: 16),
                  Text(
                    courtName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C59),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_today, 'Data e Hora', booking.horarioInicio.toLocal().toString().substring(0, 16)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.confirmation_num, 'Código do Agendamento', '#${booking.id.toString().padLeft(4, '0')}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 16),
                      const Text(
                        'Status:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const Spacer(),
                      StatusBadge(
                        label: booking.status,
                        baseColor: _getStatusColor(booking.status),
                      ),
                    ],
                  ),
                ],
              ),
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
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
