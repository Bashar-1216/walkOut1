import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
    if (_formKey.currentState!.validate() && _card?.complete == true) {
      setState(() => _isLoading = true);

      try {
        final billingDetails = BillingDetails(
          name: _nameController.text,
        );

        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
        );

        final token = paymentMethod.id;

        final success = await AuthService().updatePaymentToken(token);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Card added successfully!"),
              backgroundColor: Color(0xFF50D890),
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to save payment method."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // إذا لم يتم إدخال بيانات البطاقة كاملة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter complete card details."),
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
        title: const Text("Add Payment Method"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              CardField(
                onCardChanged: (card) {
                  setState(() {
                    _card = card;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name on Card"),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter the name on the card' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50D890),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Add Card",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
