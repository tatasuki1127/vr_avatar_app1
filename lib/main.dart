import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VRAvatarApp());
}

class VRAvatarApp extends StatelessWidget {
  const VRAvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VR Avatar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.notoSansJp().fontFamily,
        // GPU最適化アプリらしいダークテーマ
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        primaryColor: const Color(0xFFE94560),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE94560),
          secondary: Color(0xFF16213E),
          surface: Color(0xFF0F3460),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}