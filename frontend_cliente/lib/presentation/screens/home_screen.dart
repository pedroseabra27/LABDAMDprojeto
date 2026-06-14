import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/court.dart';
import '../providers/app_provider.dart';
import 'court_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Court> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      final courts = await provider.apiService.getCourts();
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar quadras: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadras Disponíveis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courts.isEmpty
              ? const Center(child: Text('Nenhuma quadra encontrada.'))
              : ListView.builder(
                  itemCount: _courts.length,
                  itemBuilder: (context, index) {
                    final court = _courts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(court.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${court.esporte} - R\$ ${court.precoHora}/h'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourtDetailScreen(court: court),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
