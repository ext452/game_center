import 'dart:async';

import 'package:flutter/services.dart';

///Small library to work with Apple Game Center
///
///
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
const GC_SHOW_ACHIEVBOARD = "gcShowAchievBoard";


class GameServices {
  static const MethodChannel _channel = const MethodChannel('game_services');


  ///Login into Game Center
  ///
  ///Return `true` if operation was successful
  static Future<bool> get gcSignIn async {
    final bool result = await _channel.invokeMethod(GC_LOGIN);
    return result;
  }

  ///Show native leader board passing [leaderBoardID]
  ///
  ///Return `true` if operation was successful
  static Future<String> showLeadBoard(String leaderBoardID) async {
    final String result = await _channel.invokeMethod(GC_SHOW_LEADERBOARD, leaderBoardID);
    return Future.error("error");
  }

  ///Just show native achievement board
  static Future<bool> showAchieventBoard() async {
    final bool result = await _channel.invokeMethod(GC_SHOW_ACHIEVBOARD);
    return result;
  }

  ///Open achievement by [achivKey]
  ///
  ///Return `true` if operation was successful
  static Future<bool> openAchievement(String achivKey) async {
    final bool result = await _channel.invokeMethod(GC_SUBMIT_ACHIV, achivKey);
    return result;
  }

  ///Submit score to GameCenter by leadBoardId
  ///It takes [params] as Map - {[leadBoardId], [score]}
  ///
  ///Returns `true` if operation was successful
  static Future<bool> reportScore(Map<String, int> params) async {
    final bool result = await _channel.invokeMethod(GC_SUBMIT_SCORE, params);
    return result;
  }
}
