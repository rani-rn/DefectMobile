import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    const laptopIp = '192.168.182.54';

    if (kDebugMode) {
      if (Platform.isAndroid) {
        bool isRunOnEmulator = _isProbablyEmulator();
        return isRunOnEmulator
            ? 'http://10.0.2.2:5145/api/defect'
            : 'http://$laptopIp:5145/api/defect';
      } else {
        return 'http://$laptopIp:5145/api/defect';
      }
    } else {
      return 'http://$laptopIp:5145/api/defect';
    }
  }

  static bool _isProbablyEmulator() {
    const env = String.fromEnvironment('FLUTTER_TEST');
    return env == 'true' || Platform.environment.containsKey('ANDROID_EMULATOR_AVD');
  }
}
