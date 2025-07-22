// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkout_app1/screens/signup_screen.dart';
// import 'add_payment_screen.dart'; // سنستخدمها لاحقًا
// import 'purchase_history_screen.dart'; // سننشئها الآن

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "My Account",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Info"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              /* Navigate to My Info screen */
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: const Text("Payment Methods"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text("Purchase History"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseHistoryScreen()));
            },
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignupScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "My Smart Experience",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Enable Instant Cart Notifications"),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: true, // dummy value for now
            onChanged: (bool value) {},
          ),
          SwitchListTile(
            title: const Text("Enable Haptic Feedback"),
            secondary: const Icon(Icons.vibration),
            value: false, // dummy value for now
            onChanged: (bool value) {},
          ),
        ],
      ),
    );
  }
}
