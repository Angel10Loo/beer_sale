import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/providers/user_provider.dart';
import 'package:beer_sale/screens/login/login_screen.dart';
import 'package:beer_sale/screens/main/main_screen.dart';
import 'package:beer_sale/screens/sale/sale_screen.dart';
import 'package:beer_sale/screens/expenses/expenses_screen.dart';
import 'package:beer_sale/shared/widgets/custom_corusel_widget.dart';
import 'package:beer_sale/shared/widgets/custom_product_grid_widget.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

// Add TickerProviderStateMixin to provide vsync for animations
class _MyHomeScreenState extends State<MyHomeScreen> with TickerProviderStateMixin {
  final List<String> images = [
   'assets/images/vitoria.png',
        'assets/images/GORRA.webp',
     'assets/images/gorra_blanca.webp',
     'assets/images/vitoriaagua.webp',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
    Future.microtask(() =>
        Provider.of<SaleProvider>(context, listen: false).getTodaySales());
  }

  Future<bool> signInWithCustomFirestore(String email, String plainPassword) {
    return Provider.of<UserProvider>(context, listen: false)
        .signInPlaintext(email: email, plainPassword: plainPassword);
  }

  @override
  Widget build(BuildContext context) {
    final _products = context.watch<ProductProvider>().products;
    final _sales = context.watch<SaleProvider>().todaySale;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text("Hola, ${userProvider.user?.name ?? 'Usuario'}"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userProvider.user?.name ?? 'Usuario'),
                accountEmail: Text(userProvider.user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userProvider.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                decoration: const BoxDecoration(color: Colors.deepPurple),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Gastos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>  ExpensesTrackerScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  userProvider.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        onLogin: signInWithCustomFirestore,
                        onSuccess: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const MainScreen()),
                          );
                        },
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // ─── Cash Info + Carousel ─────────────────────
            Container(
              height: MediaQuery.of(context).size.height * 0.28,
              decoration: const BoxDecoration(
                color: Color.fromARGB(213, 9, 9, 9),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  SafeImageCarousel(
                    images: images,
                    vsync: this,
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Colors.deepPurple.shade700.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Text(
                          "Efectivo en Caja: \$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(_sales))}",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (context.watch<ProductProvider>().loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_products.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.yellow, size: 50),
                      SizedBox(height: 16),
                      Text(
                        "😢 No hay Productos Agregados",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return GestureDetector(
                        onTap: () {
                          if (p.stock == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.red[200],
                                content: Text(
                                  "Producto ${p.name} Agotado",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SalesScreen(product: p),
                            ),
                          );
                        },
                        child: ProductCard(
                          price: p.price,
                          name: p.name,
                          quantity: p.stock,
                          image: p.imageName,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper for ImageCarousel that passes vsync to avoid _ticker errors
class SafeImageCarousel extends StatefulWidget {
  final List<String> images;
  final TickerProvider vsync;

  const SafeImageCarousel({super.key, required this.images, required this.vsync});

  @override
  State<SafeImageCarousel> createState() => _SafeImageCarouselState();
}

class _SafeImageCarouselState extends State<SafeImageCarousel> {
  late final PageController _pageController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
  child: Image.asset(
    widget.images[index],
    fit: BoxFit.contain,
    alignment: Alignment.center,
  ),
);
      },
    );
  }
}
