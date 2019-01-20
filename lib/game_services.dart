import 'dart:async';

import 'package:flutter/services.dart';

/**
 * let GC_LOGIN = "gcLogin"
    let GC_LOGOUT = "gcLogout"
    let GC_SUBMIT_SCORE = "gcSubmitScore"
    let GC_GET_SCORE = "gcGetScore"
    let GC_SUBMIT_ACHIV = "gcSubmitAchiv"
 */
const GC_LOGIN = "gcLogin";
const GC_LOGOUT = "gcLogout";
const GC_SUBMIT_SCORE = "gcSubmitScore";
const GC_GET_SCORE = "gcGetScore";
const GC_SUBMIT_ACHIV = "gcSubmitAchiv";
const GC_SHOW_LEADERBOARD = "gcShowLeadBoard";

class GameServices {
  static const MethodChannel _channel = const MethodChannel('game_services');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get gcLogin async {
    final String result = await _channel.invokeMethod(GC_LOGIN);
    return result;
  }

  static Future<String> get showLeadBoard async {
    final String result = await _channel.invokeMethod(GC_SHOW_LEADERBOARD);
    return result;
  }
}
