import 'package:flutter/material.dart';

class SummaryBox extends StatelessWidget {
  final String title;
  final int value;
  const SummaryBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F58A8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
