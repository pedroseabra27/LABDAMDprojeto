import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/court.dart';
import '../providers/app_provider.dart';

class CourtDetailScreen extends StatefulWidget {
  final Court court;

  const CourtDetailScreen({super.key, required this.court});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  DateTime? _selectedDate;
  bool _isBooking = false;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _bookCourt() async {
    if (_selectedDate == null) return;
    
    setState(() => _isBooking = true);
    try {
      await Provider.of<AppProvider>(context, listen: false).createBooking(
        widget.court.id,
        _selectedDate!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento solicitado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.court.nome)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Esporte: ${widget.court.esporte}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Preço: R\$ ${widget.court.precoHora} / hora', style: const TextStyle(fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null 
                  ? 'Selecionar Data e Hora' 
                  : 'Horário: ${_selectedDate.toString().substring(0, 16)}'),
              onPressed: () => _selectDate(context),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: _selectedDate == null || _isBooking ? null : _bookCourt,
              child: _isBooking 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar Agendamento', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
