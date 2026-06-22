import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/modern_card.dart';
import '../widgets/status_badge.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
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
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/map_icon.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Meus Agendamentos'),
          ],
        ),
      ),
      body: provider.isLoadingBookings
          ? const Center(child: CircularProgressIndicator())
          : provider.myBookings.isEmpty
              ? const Center(child: Text('Você não tem agendamentos.'))
              : ListView.builder(
                  itemCount: provider.myBookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.myBookings[index];
                    return ModernCard(
                      child: Row(
                        children: [
                          const Icon(Icons.sports_soccer, size: 36, color: Color(0xFFC06B52)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.getCourtName(booking.quadraId),
                                  style: const TextStyle(
                                    fontFamily: 'Caveat', 
                                    fontSize: 22, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Data: ${booking.horarioInicio.toLocal().toString().substring(0, 16)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontFamily: 'sans-serif',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: booking.status, 
                            baseColor: _getStatusColor(booking.status),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
