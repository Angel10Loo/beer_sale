import 'package:beer_sale/model/enums/userRole.dart';
import 'package:beer_sale/providers/user_provider.dart';
import 'package:beer_sale/screens/borrow/borrow_screen.dart';
import 'package:beer_sale/screens/clossing/closing_screen.dart';
import 'package:beer_sale/screens/clossing/perfoming_closing_screen.dart';
import 'package:beer_sale/screens/game/revenue_screen.dart';
import 'package:beer_sale/screens/home/home_screen.dart';
import 'package:beer_sale/screens/inventory/inventory_screen.dart';
import 'package:beer_sale/screens/login/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Create a controller for persistent bottom navigation
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens(UserRole role) {
   List<Widget> screens = [
    const MyHomeScreen(),
    const BorrowScreen(),
      const PerformClosingScreen(),

  ];

  if (role == UserRole.admin) {
    screens.addAll([
      const InventoryScreen(),
       RevenueScreen(),
      const CreateUserScreen(),
    ]);
  }
  return screens;
  }

  List<PersistentBottomNavBarItem> _navBarsItems(UserRole role) {
    final items = [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: 'Home',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.archive),
      title: 'Borrow',
      activeColorPrimary: Colors.orange,
      inactiveColorPrimary: Colors.grey,
    ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.lock),
        title: 'Cierre de Caja',
        activeColorPrimary: Colors.redAccent,
        inactiveColorPrimary: Colors.grey,
      ),
  ];
     if (role == UserRole.admin) {
    // Additional tabs only for admins
    items.addAll([
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.inventory),
        title: 'Inventory',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.document_scanner),
        title: 'Reportes',
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_add),
        title: 'Users',
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
    ]);
  }
  return items;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    UserRole role = UserRole.normal;
    if(currentUser!.role != "normal"){
      role = UserRole.admin;
    }
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(role),
      items: _navBarsItems(role),
      navBarHeight: 60.0, // Height of the BottomNavBar
      backgroundColor: const Color.fromARGB(255, 27, 19, 19), // Background color of the BottomNavBar
      decoration: NavBarDecoration(
        colorBehindNavBar: Colors.blue.shade50, // Optional, color behind the navbar
      ),
      selectedTabScreenContext: (context) {
      },
      onItemSelected: (int index) {
        setState(() {});
      },
    );
  }
}