import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cities_screen.dart';
import 'accounts_screen.dart'; // Import the new AccountsScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CitiesScreen(),
    AccountsScreen(), // Add the new AccountsScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Make the nav bar float over the body
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.15),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                selectedItemColor: Colors.teal,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: false,
                showSelectedLabels: true,
                iconSize: 26, // Make default icons bigger
                selectedIconTheme: const IconThemeData(
                    size: 32), // Make active icon even bigger
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: const Icon(Icons.home),
                      label: 'Home'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.search_outlined),
                      activeIcon: const Icon(Icons.search),
                      label: 'Search'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.location_city_outlined),
                      activeIcon: const Icon(Icons.location_city),
                      label: 'Cities'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      label: 'Accounts'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
