import 'package:flutter/material.dart';

class SummaryBox extends StatelessWidget {
  final String title;
  final int value;
  const SummaryBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF5fc7cf2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}