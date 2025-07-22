// lib/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // افترض أن هذه هي شاشتك الرئيسية التالية

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _submitVerification() async {
    // Do nothing if the input field is not 4 digits
    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 4-digit code."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final String? token = await _authService.verifyOtp(widget.phoneNumber, _pinController.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (token != null) {
    // If verification is successful, navigate to HomeScreen and remove all previous screens
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors from design charter
    const primaryColor = Color(0xFF1A237E);

    // OTP input field design
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Verification Code",
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                "A 4-digit code was sent via SMS to\n${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 16, color: Color(0xFF8A8A8F)),
              ),
              const SizedBox(height: 40),
              
              // 1. Changed to 4 digits
              Pinput(
                controller: _pinController,
                length: 4, 
                autofocus: true,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                ),
                // Auto-validation still works when input is complete
                onCompleted: (pin) => _submitVerification(),
              ),
              const SizedBox(height: 40),

              // 2. تمت إضافة زر التحقق
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Verify",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isLoading ? null : () { /* Resend code logic here */ },
                child: const Text(
                  "Resend code",
                  style: TextStyle(fontSize: 16, fontFamily: 'IBMPlexSansArabic', color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}