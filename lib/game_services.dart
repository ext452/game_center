import 'dart:async';

import 'package:flutter/services.dart';

class GameServices {
  static const MethodChannel _channel =
      const MethodChannel('game_services');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
