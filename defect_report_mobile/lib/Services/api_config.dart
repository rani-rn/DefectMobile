
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5145/api/defect'; 
      } else {
        return 'http://localhost:5145/api/defect';
      }
    } else {
      return 'http://192.168.3.37:5145/api/defect';
    }
  }
}
