import 'package:beer_sale/firebase_options.dart';
import 'package:beer_sale/providers/expense_provider.dart';
import 'package:beer_sale/providers/open_account_provider.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/providers/user_provider.dart';
import 'package:beer_sale/screens/login/login_screen.dart';
import 'package:beer_sale/screens/main/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OpenAccountProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProxyProvider<ProductProvider, SaleProvider>(
          create: (_) => SaleProvider(),
          update: (_, productProvider, saleProvider) =>
              saleProvider!..updateProductProvider(productProvider),
              
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beer Sale',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool> signInWithCustomFirestore(String email, String plainPassword) {
    return Provider.of<UserProvider>(context, listen: false)
        .signInPlaintext(email: email, plainPassword: plainPassword);
  }

  void _onSuccessLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
  final isLoggedIn = context.watch<UserProvider>().isLoggedIn;
    if (!isLoggedIn) {
      return LoginScreen(
        onLogin: (email, pass) {
          return context.read<UserProvider>().signInPlaintext(
                email: email,
                plainPassword: pass,
              );
        },
        onSuccess: () {}, // handled by provider state
      );
    }

    return const MainScreen();
  }
}
