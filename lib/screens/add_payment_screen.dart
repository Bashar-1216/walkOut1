import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkout_app1/services/auth_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  CardFieldInputDetails? _card;
  final _nameController = TextEditingController();

  Future<void> _addCard() async {
    if (_formKey.currentState!.validate() && (_card?.complete ?? false)) {

      setState(() => _isLoading = true);
      try {
        final billingDetails = BillingDetails(name: _nameController.text);
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
          ),
        );
        final token = paymentMethod.id;
        final success = await AuthService().updatePaymentToken(token);
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "تمت إضافة البطاقة بنجاح!",
                style: GoogleFonts.ibmPlexSansArabic(),
              ),
              backgroundColor: const Color(0xFF50D890),
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "فشل في حفظ طريقة الدفع.",
                style: GoogleFonts.ibmPlexSansArabic(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "خطأ: ${e.toString()}",
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "يرجى إدخال تفاصيل البطاقة كاملة.",
            style: GoogleFonts.ibmPlexSansArabic(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "إضافة طريقة دفع",
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أدخل تفاصيل البطاقة",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              CardField(
                style: GoogleFonts.ibmPlexSansArabic(
                  color: const Color(0xFF8A8A8F),
                ),
                onCardChanged: (card) {
                  setState(() {
                    _card = card;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "الاسم على البطاقة",
                  labelStyle: GoogleFonts.ibmPlexSansArabic(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'يرجى إدخال الاسم على البطاقة' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addCard,
                        child: Text(
                          "إضافة البطاقة",
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
