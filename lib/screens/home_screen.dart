// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:walkout_app1/services/session_service.dart';
import 'product_service.dart';
import '../services/auth_service.dart';
import 'add_payment_screen.dart';
import 'profile_screen.dart';
import 'live_cart_screen.dart';
import 'store_entrance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasPaymentMethod = false;

  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserStatusAndLoadData();
  }

  // ملف: lib/screens/home_screen.dart
Future<void> _checkUserStatusAndLoadData() async {
  setState(() => _isLoading = true);

  // استدعاء مباشر للسرفر لتحديث البيانات
final currentUser = await _authService.getCurrentUser(forceRefresh: true);
  final bool userHasPayment = (currentUser != null && currentUser.paymentToken != null);

  setState(() {
    _hasPaymentMethod = userHasPayment;
    if (_hasPaymentMethod) {
      _productsFuture = _productService.getProducts();
    }
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WalkOut Store"),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasPaymentMethod
              ? _buildProductList()
              : _buildAddPaymentBanner(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreEntranceScreen()),
          );
        },
        label: const Text("Enter Store"),
        icon: const Icon(Icons.qr_code_scanner),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() => _currentIndex = index);

          if (index == 1) {
            final sessionId = await SessionService().getActiveSession();
            if (sessionId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LiveCartScreen(sessionId: sessionId)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No active session found.")),
              );
            }
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAddPaymentBanner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline,
                    color: Colors.red.shade400, size: 40),
                const SizedBox(height: 16),
                const Text(
                  "One last step to start shopping!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Add a payment method to your account.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
  ).then((result) {
    if (result == true) _checkUserStatusAndLoadData();
  });
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text("Add Now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No products found."));
        } else {
          final products = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF1A237E).withOpacity(0.1),
                    child: const Icon(Icons.shopping_basket_outlined,
                        color: Color(0xFF1A237E)),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    product.description ?? 'No description available',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: Color(0xFF8A8A8F),
                    ),
                  ),
                  trailing: Text(
                    product.price.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}