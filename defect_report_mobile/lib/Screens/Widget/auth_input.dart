import 'package:flutter/material.dart';

InputDecoration buildAuthInputDecoration(String hint, IconData icon){
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      )
    );
  }