// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'YE';
  PhoneNumber number = PhoneNumber(isoCode: 'YE');
  bool _isPhoneNumberValid = false; // To track phone number validity

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _submitPhoneNumber() async {
    // No need to check here, button will be disabled if number is invalid
    
    setState(() => _isLoading = true);

    bool success = await _authService.registerUser(number.phoneNumber!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(phoneNumber: number.phoneNumber!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Failed. This number may already be registered."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and text here
              const SizedBox(height: 60),

              // International phone number input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    this.number = number;
                  },
                  // --- This is the correct place for the property ---
                  onInputValidated: (bool value) {
                    setState(() {
                      _isPhoneNumberValid = value;
                    });
                  },
                  // ------------------------------------
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    useBottomSheetSafeArea: true,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.onUserInteraction, // Validate on user interaction
                  selectorTextStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  initialValue: number,
                  textFieldController: controller,
                  formatInput: true,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputBorder: InputBorder.none,
                  hintText: 'Phone Number',
                ),
              ),
              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                // Button is disabled if number is invalid or system is loading
                onPressed: (_isLoading || !_isPhoneNumberValid) ? null : _submitPhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey, // Button color when disabled
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}