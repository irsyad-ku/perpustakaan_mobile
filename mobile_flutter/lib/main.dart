import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/data_providers.dart';

import 'utils/theme.dart';

// Import Screens (Akan dibuat setelah ini)
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => BukuProvider()),
        ChangeNotifierProvider(create: (_) => AnggotaProvider()),
        ChangeNotifierProvider(create: (_) => PeminjamanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// Widget sementara sebelum file screen dibuat
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Halaman $title sedang dikerjakan', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Silakan kirimkan kode Screen Anda.'),
          ],
        ),
      ),
    );
  }
}
