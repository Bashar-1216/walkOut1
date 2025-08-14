import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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


Future<void> _checkUserStatusAndLoadData() async {
  print("HomeScreen: Starting _checkUserStatusAndLoadData..."); 
  setState(() => _isLoading = true);

  try {
   
    final currentUser = await _authService.getCurrentUser(forceRefresh: true);

    final bool userHasPayment = (currentUser != null && currentUser.paymentToken != null && currentUser.paymentToken!.isNotEmpty);
    
    print("HomeScreen: User has payment method? $userHasPayment"); // للتتبع

    // 3. قم بتحديث حالة الواجهة بناءً على النتيجة
    setState(() {
      _hasPaymentMethod = userHasPayment;
      // إذا كان لديه طريقة دفع، ابدأ في تحميل المنتجات
      if (_hasPaymentMethod) {
        _productsFuture = _productService.getProducts();
      }
      _isLoading = false;
    });
  } catch (e) {
    print("HomeScreen: Error in _checkUserStatusAndLoadData: $e"); // للتتبع
    setState(() => _isLoading = false);
    // يمكنك عرض رسالة خطأ هنا إذا أردت
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "متجر WalkOut",
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: const Color(0xFF1A237E),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A237E)),
            onPressed: _checkUserStatusAndLoadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF50D890)),
              ),
            )
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
        label: Text(
          "دخول المتجر",
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: const Icon(Icons.qr_code_scanner, size: 24),
        backgroundColor: const Color(0xFF50D890),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: const Color(0xFF8A8A8F),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 8,
        selectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, size: 28),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart, size: 28),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 28),
            label: 'الملف الشخصي',
          ),
        ],
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
                SnackBar(
                  content: Text(
                    "لم يتم العثور على جلسة نشطة.",
                    style: GoogleFonts.ibmPlexSansArabic(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAddPaymentBanner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFFF8F9FA),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF1A237E),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "ابدأ رحلة التسوق الآن!",
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "أضف طريقة دفع لتجربة تسوق سلسة وذكية.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    color: const Color(0xFF8A8A8F),
                  ),
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "أضف طريقة دفع",
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Experience Section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF1A237E),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "تجربتي الذكية",
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "استمتع بتوصيات مخصصة وتتبع فوري للسلة",
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 14,
                            color: const Color(0xFF8A8A8F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Placeholder for smart experience action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF50D890),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "تفعيل",
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Product List
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF50D890)),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "خطأ: ${snapshot.error}",
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      color: const Color(0xFF8A8A8F),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد منتجات متاحة حاليًا",
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      color: const Color(0xFF8A8A8F),
                    ),
                  ),
                );
              } else {
                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Placeholder for product details navigation
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Placeholder for product image
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 40,
                                  color: const Color(0xFF1A237E),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A237E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description ?? 'لا يوجد وصف متاح',
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 12,
                                      color: const Color(0xFF8A8A8F),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${product.price.toStringAsFixed(2)} \$",
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
