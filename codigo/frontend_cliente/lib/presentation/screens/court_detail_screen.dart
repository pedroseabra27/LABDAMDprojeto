import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/models/court.dart';
import '../providers/app_provider.dart';

class CourtDetailScreen extends StatefulWidget {
  final Court court;

  const CourtDetailScreen({super.key, required this.court});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _handleBooking(BuildContext context) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e hora para agendar.')),
      );
      return;
    }

    final dataHora = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await Provider.of<AppProvider>(context, listen: false).createBooking(widget.court.id, dataHora);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento solicitado com sucesso!')),
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
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(court.nome),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem da Quadra
            if (court.imagemUrl != null && court.imagemUrl!.isNotEmpty)
              Image.network(
                court.imagemUrl!,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackImage(),
              )
            else
              _buildFallbackImage(),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        court.esporte.toUpperCase(),
                        style: const TextStyle(color: Color(0xFFC06B52), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'R\$ ${court.precoHora} /h',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    court.nome,
                    style: const TextStyle(fontFamily: 'Caveat', fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Endereço
                  if (court.endereco != null && court.endereco!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(court.endereco!, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Descrição
                  if (court.descricao != null && court.descricao!.isNotEmpty) ...[
                    const Text('Sobre a quadra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(court.descricao!, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                    const SizedBox(height: 24),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),
                  
                  const Text('Fazer Agendamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate == null ? 'Data' : '${_selectedDate!.day}/${_selectedDate!.month}'),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime == null ? 'Hora' : _selectedTime!.format(context)),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) setState(() => _selectedTime = time);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC06B52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _handleBooking(context),
                      child: const Text('Confirmar Agendamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Icon(Icons.sports_tennis, size: 80, color: Colors.grey),
    );
  }
}
