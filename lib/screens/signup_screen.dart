import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  PhoneNumber number = PhoneNumber(isoCode: ''); // بدون دولة افتراضية
  bool _isPhoneNumberValid = false;
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  /// التحقق من صيغة الرقم الدولية E.164 (+كود الدولة وبقية الرقم)
  bool _validateInternationalNumber(String phone) {
    final regex = RegExp(r'^\+\d{6,15}$');
    return regex.hasMatch(phone);
  }

  void _submitPhoneNumber() async {
    if (!_isPhoneNumberValid || number.phoneNumber == null || !_validateInternationalNumber(number.phoneNumber!)) {
      setState(() {
        _errorMessage = "الرجاء إدخال رقم هاتف صحيح بصيغة دولية (+كود الدولة...).";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool success = await _authService.registerUser(number.phoneNumber!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(phoneNumber: number.phoneNumber!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل التسجيل. قد يكون الرقم مسجلاً مسبقًا.",
            style: GoogleFonts.ibmPlexSansArabic(),
          ),
          backgroundColor: Colors.red,
        ),
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
              Icon(
                Icons.shopping_cart_checkout,
                size: 80,
                color: const Color(0xFF1A237E),
              ),
              const SizedBox(height: 16),
              Text(
                "مرحبًا بك في متجر WalkOut",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "أدخل رقم هاتفك للتسجيل",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber num) {
                          setState(() {
                            number = num; // تحديث الدولة تلقائيًا
                          });
                        },
                        onInputValidated: (bool value) {
                          setState(() {
                            _isPhoneNumberValid = value &&
                                number.phoneNumber != null &&
                                _validateInternationalNumber(number.phoneNumber!);
                            _errorMessage = _isPhoneNumberValid ? null : "الرجاء إدخال رقم هاتف صحيح بصيغة دولية.";
                          });
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useBottomSheetSafeArea: true,
                          showFlags: true,
                          setSelectorButtonAsPrefixIcon: true,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        selectorTextStyle: GoogleFonts.ibmPlexSansArabic(
                          color: const Color(0xFF1A237E),
                          fontSize: 16,
                        ),
                        initialValue: number,
                        textFieldController: controller,
                        formatInput: true,
                        keyboardType: TextInputType.phone,
                        inputDecoration: InputDecoration(
                          hintText: 'رقم الهاتف',
                          hintStyle: GoogleFonts.ibmPlexSansArabic(
                            color: const Color(0xFF8A8A8F).withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (_isLoading || !_isPhoneNumberValid) ? null : _submitPhoneNumber,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: const Color(0xFF8A8A8F),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        "متابعة",
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
