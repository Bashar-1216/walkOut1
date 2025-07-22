// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 
import 'package:flutter_stripe/flutter_stripe.dart';


void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  Stripe.merchantIdentifier = 'merchant.flutter.stripe';
  Stripe.urlScheme = 'flutterstripe';

    Stripe.publishableKey = "pk_test_51RmeSkCDGvmlZBYhdrpkez8FmUQzvH6nyacCyNhlHi0T2PtVoY0MYJdcmPmV2ELQmHrGzxZTZ2IX5wgelmJniMxk00OGbDJyUV";
    await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkOut Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}