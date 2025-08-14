import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() async {
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
        primaryColor: const Color(0xFF1A237E),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF50D890),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: Color(0xFFF8F9FA),
          onSurface: Color(0xFF8A8A8F),
        ),
        
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFFF8F9FA),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.1),
          margin: const EdgeInsets.all(8),
        ),
        
        textTheme: TextTheme(
          displayLarge: GoogleFonts.ibmPlexSansArabic(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A237E),
          ),
          titleLarge: GoogleFonts.ibmPlexSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A237E),
          ),
          bodyMedium: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF8A8A8F),
          ),
          bodySmall: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF8A8A8F),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF50D890),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.ibmPlexSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1A237E),
              width: 2,
            ),
          ),
          labelStyle: GoogleFonts.ibmPlexSansArabic(
            color: const Color(0xFF8A8A8F),
          ),
          hintStyle: GoogleFonts.ibmPlexSansArabic(
            color: const Color(0xFF8A8A8F).withOpacity(0.6),
          ),
        ),
        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A237E)),
          titleTextStyle: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
