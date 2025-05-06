import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    const laptopIp = '192.168.11.54';

    if (kDebugMode) {
      if (Platform.isAndroid) {
        bool isRunOnEmulator = _isProbablyEmulator();
        return isRunOnEmulator
            ? 'http://10.0.2.2:5145'
            : 'http://$laptopIp:5145';
      } else {
        return 'http://$laptopIp:5145';
      }
    } else {
      return 'http://$laptopIp:5145';
    }
  }

  static bool _isProbablyEmulator() {
    const env = String.fromEnvironment('FLUTTER_TEST');
    return env == 'true' || Platform.environment.containsKey('ANDROID_EMULATOR_AVD');
  }
}
