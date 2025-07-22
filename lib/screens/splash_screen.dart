// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // انتظر ثانيتين لإظهار الشعار
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token != null) {
      // إذا كان هناك توكن، انتقل للشاشة الرئيسية
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen())
      );
    } else {
      // إذا لم يكن هناك توكن، انتقل لشاشة التسجيل
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignupScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // يمكنك وضع شعار المشروع هنا
            Icon(
              Icons.shopping_cart_checkout,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}