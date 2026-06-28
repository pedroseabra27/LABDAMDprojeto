import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/models/court.dart';
import '../providers/app_provider.dart';
import 'court_detail_screen.dart';
import 'login_screen.dart';
import '../widgets/modern_card.dart';

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
      backgroundColor: const Color(0xFFF9F9F9), // Cinza muito claro / branco off
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/map_icon.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Quadras Disponíveis'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courts.isEmpty
              ? const Center(child: Text('Nenhuma quadra encontrada.'))
              : ListView.builder(
                  itemCount: _courts.length,
                  itemBuilder: (context, index) {
                    final court = _courts[index];
                    return ModernCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourtDetailScreen(court: court),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset('assets/images/map_icon.png', width: 32, height: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  court.nome, 
                                  style: const TextStyle(
                                    fontFamily: 'Caveat', 
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${court.esporte} - R\$ ${court.precoHora}/h',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontFamily: 'sans-serif'
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
