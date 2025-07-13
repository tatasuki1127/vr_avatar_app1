import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 2000,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // VRアバターアプリらしいアイコン
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFE94560).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xFFE94560),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt,
              size: 60,
              color: Color(0xFFE94560),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'VR Avatar App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'GPU最適化リアルタイムVR化',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Metal API + Neural Engine',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFE94560),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          // GPU最適化を表現するプログレスインジケーター
          Container(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'GPU システム初期化中...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
      nextScreen: const HomeScreen(),
      splashIconSize: 300,
      backgroundColor: Color(0xFF1A1A2E),
      animationDuration: Duration(milliseconds: 800),
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}