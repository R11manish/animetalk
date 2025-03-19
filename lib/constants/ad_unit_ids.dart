import 'dart:io';

class AdUnitIds {
  static String get nativeAdvanced {
    if (Platform.isAndroid) {
      // Test ID for Android
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      // Test ID for iOS
      return 'ca-app-pub-3940256099942544/3986624511';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get appId {
    // Your app ID remains the same for both platforms
    return 'ca-app-pub-8083231867045783~2531505005';
  }
}
