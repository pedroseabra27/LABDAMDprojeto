import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/prestador_provider.dart';
import 'presentation/screens/pending_requests_screen.dart';
import 'presentation/screens/ongoing_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrestadorProvider()),
      ],
      child: const PrestadorApp(),
    ),
  );
}

class PrestadorApp extends StatelessWidget {
  const PrestadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDAMD Prestador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2838),
          background: const Color(0xFFF2F4F8),
        ),
        fontFamily: 'PTSerif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Caveat',
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class PrestadorMainScreen extends StatefulWidget {
  const PrestadorMainScreen({super.key});

  @override
  State<PrestadorMainScreen> createState() => _PrestadorMainScreenState();
}

class _PrestadorMainScreenState extends State<PrestadorMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const PendingRequestsScreen(),
    const OngoingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1B2838),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pendentes'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Em Andamento'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
