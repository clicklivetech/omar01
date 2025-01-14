import 'package:flutter/material.dart';
import 'dart:async';
import '../services/supabase_service.dart';
import '../services/logger_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // تهيئة الخدمات
      await SupabaseService.client.auth.currentSession;
      
      if (!mounted) return;
      
      Timer(
        const Duration(seconds: 3),
        () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      );
    } catch (e) {
      LoggerService.error('Error initializing app: $e');
      if (mounted) {
        Timer(
          const Duration(seconds: 3),
          () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Untitled design (63).png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
