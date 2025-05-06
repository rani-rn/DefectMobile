import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:defect_report_mobile/Screens/profile_view.dart';
import 'package:defect_report_mobile/Screens/add_screen.dart';
import 'package:defect_report_mobile/Screens/dashboard.dart';
import 'package:defect_report_mobile/Screens/list_screen.dart';
import 'package:flutter/material.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AddScreen(),
    RecordListScreen(),
  ];
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(      
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
      ],
    ),
    backgroundColor: Colors.white,
    body: _pages[_currentIndex],
    bottomNavigationBar: CurvedNavigationBar(
      backgroundColor: Colors.white,
      color: const Color(0xFF0F58A8),
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.add_circle_outlined, color: Colors.white),
        Icon(Icons.view_list_rounded, color: Colors.white),
      ],
    ),
  );
}
}