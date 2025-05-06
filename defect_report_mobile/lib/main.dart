import 'package:defect_report_mobile/Screens/Auth/login_page.dart';
//import 'package:defect_report_mobile/Screens/nav.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: Nav(),
      home: LoginPage(),
    );
  }
}
