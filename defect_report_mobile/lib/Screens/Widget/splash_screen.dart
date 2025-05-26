import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defect_report_mobile/Screens/Auth/login_page.dart';
import 'package:defect_report_mobile/Screens/nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    int? expiredMillis = prefs.getInt('token_expired'); 

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (token != null && expiredMillis != null && currentTime < expiredMillis) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Nav()),
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
