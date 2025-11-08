import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cities_screen.dart';
import 'accounts_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  double _targetX = 0;
  double _currentX = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CitiesScreen(),
    AccountsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          _currentX = _animation.value;
        });
      });
  }

  void _onItemTapped(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / _screens.length;
    _targetX = (index * itemWidth) + (itemWidth / 2);
    _animation = Tween<double>(begin: _currentX, end: _targetX)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / _screens.length;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: _CurvedNavPainter(_currentX),
            child: Container(
              height: 80,
              color: Colors.transparent,
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_screens.length, (index) {
                final icons = [
                  Icons.home_rounded,
                  Icons.search_rounded,
                  Icons.location_city_rounded,
                  Icons.person_rounded,
                ];
                final labels = ["Home", "Search", "Cities", "Account"];
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: isSelected ? 50 : 40,
                        width: isSelected ? 50 : 40,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          icons[index],
                          color: isSelected ? Colors.white : Colors.black54,
                          size: isSelected ? 26 : 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black54,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedNavPainter extends CustomPainter {
  final double centerX;
  _CurvedNavPainter(this.centerX);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.fill;

    final path = Path();
    const double curveHeight = 35;
    final double width = size.width;
    final double height = size.height;

    path.moveTo(0, 0);
    path.lineTo(centerX - 45, 0);
    path.quadraticBezierTo(centerX, -curveHeight, centerX + 45, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawShadow(path, Colors.black26, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavPainter oldDelegate) {
    return oldDelegate.centerX != centerX;
  }
}
