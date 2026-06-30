import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/modern_card.dart';
import '../widgets/status_badge.dart';
import 'login_screen.dart';
import 'booking_detail_screen.dart';

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

  void _showReviewDialog(BuildContext context, int bookingId) {
    int nota = 5;
    String comentario = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Avaliar Quadra'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('De 1 a 5, qual a sua nota?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < nota ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setStateSB(() => nota = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Deixe um comentário (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (val) => comentario = val,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC06B52)),
                  onPressed: () async {
                    try {
                      await Provider.of<AppProvider>(context, listen: false).reviewBooking(bookingId, nota, comentario);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação enviada!')));
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    }
                  },
                  child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFC06B52)),
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).logout();
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailScreen(booking: booking),
                          ),
                        );
                      },
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(
                                label: booking.status, 
                                baseColor: _getStatusColor(booking.status),
                              ),
                              if (booking.status == 'concluido' && booking.nota == null) ...[
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.star_outline, size: 16, color: Colors.amber),
                                  label: const Text('Avaliar', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _showReviewDialog(context, booking.id),
                                ),
                              ],
                              if (booking.nota != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    Text(' ${booking.nota}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
