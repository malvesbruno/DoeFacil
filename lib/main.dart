import 'package:doe_facil/homeScreen.dart';
import 'package:doe_facil/inventoryScreen.dart';
import 'package:doe_facil/addItemScreen.dart';
import 'package:doe_facil/reportsScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doe_facil/loginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DoeFacilApp());
  }

class DoeFacilApp extends StatelessWidget {
  const DoeFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B5E20),
      ),
      // O StreamBuilder escuta mudanças na autenticação em tempo real
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o status, mostra um loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Se tiver um usuário, vai para a MainNavigation
          if (snapshot.hasData) {
            return const MainNavigation();
          }
          // Se não, volta para o Login
          return const LoginScreen();
        },
      ),
    );
  }
}
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Lista das telas que você desenhou
  final List<Widget> _screens = [
    const HomeScreen(),
    const InventoryScreen(),
    const AddItemScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
        ],
      ),
    );
  }
}