import 'package:flutter/foundation.dart';
import 'dart:io';

/// Configuration helper that provides the base URL for API calls,
/// adapting automatically to debug or release modes and emulator vs. physical device.
class ApiConfig {
  /// Returns the base URL for the backend API.
  ///
  /// - In **debug mode** (`kDebugMode`):
  ///   - On **Android emulator**, uses the special host `10.0.2.2` to reach localhost.
  ///   - On **Android physical device** or **iOS**, uses the configured laptop/server IP.
  /// - In **release mode**, always uses the configured laptop/server IP.
  ///
  /// **Usage:**
  /// ```dart
  /// final url = ApiConfig.baseUrl;
  /// ```
  static String get baseUrl {
    const laptopIp = '192.168.7.54'; // Change to your server’s IP or hostname

    if (kDebugMode) {
      if (Platform.isAndroid) {
        // When running on Android emulator, use 10.0.2.2 to reach host loopback
        bool isRunOnEmulator = _isProbablyEmulator();
        return isRunOnEmulator
            ? 'http://10.0.2.2:5145'
            : 'http://$laptopIp:5145';
      } else {
        // iOS simulator or physical iOS device in debug mode
        return 'http://$laptopIp:5145';
      }
    } else {
      // Release mode (physical devices)
      return 'http://$laptopIp:5145';
    }
  }

  /// Heuristic to detect if the app is running on an Android emulator.
  ///
  /// - Checks if the `FLUTTER_TEST` environment variable is set to `'true'` (useful for widget tests).
  /// - Checks for the presence of `ANDROID_EMULATOR_AVD` in the platform environment.
  ///
  /// Returns `true` if running on emulator or in a test environment; `false` otherwise.
  static bool _isProbablyEmulator() {
    const env = String.fromEnvironment('FLUTTER_TEST');
    return env == 'true' ||
        Platform.environment.containsKey('ANDROID_EMULATOR_AVD');
  }
}
