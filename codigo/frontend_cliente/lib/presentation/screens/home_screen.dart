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
  String _searchQuery = '';
  String _selectedSport = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      await provider.fetchCourts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar quadras: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredCourts = provider.courts.where((c) {
            final matchesName = c.nome.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesSport = _selectedSport == 'Todos' || c.esporte.toLowerCase() == _selectedSport.toLowerCase();
            return matchesName && matchesSport;
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar quadra...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSport,
                            isExpanded: true,
                            items: ['Todos', 'Tênis', 'Futebol', 'Vôlei'].map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSport = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredCourts.length,
                  itemBuilder: (context, index) {
                    final court = filteredCourts[index];
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
              ),
            ],
          );
        },
      ),
    );
  }
}
