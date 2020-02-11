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
const GC_SAVE_GAME_DATA = "gcSaveGameData";
const GC_LOAD_GAME_DATA = "gcLoadGameData";

const ERROR = 'ERROR';

class GameServices {
  static const MethodChannel _channel = const MethodChannel('game_services');

  ///Login into Game Center
  ///
  ///Return `true` if operation was successful or Throw `Future.error`
  static Future<bool> get gcSignIn async {
    final bool result = await _channel.invokeMethod(GC_LOGIN);
    if (!result) {
      return Future.error(false);
    } else {
      return true;
    }
  }

  ///Show native leader board passing [leaderBoardID]
  ///
  ///Return `true` if operation was successful or Throw `Future.error`
  static Future<bool> showLeadBoard(String leaderBoardID) async {
    final bool result =
        await _channel.invokeMethod(GC_SHOW_LEADERBOARD, leaderBoardID);

    if(result == true) {
      return true;
    } else {
      return Future.error(false);
    }
  }

  ///Just show native achievement board
  ///
  //////Return `true` if operation was successful or Throw `Future.error`
  static Future<bool> showAchieventBoard() async {
    final bool result = await _channel.invokeMethod(GC_SHOW_ACHIEVBOARD);

    if(result == true) {
      return true;
    } else {
      return Future.error(false);
    }
  }

  ///Open achievement by [achivKey]
  ///
  ///Return `true` if operation was successful or Throw `Future.error`
  static Future<bool> openAchievement(String achivKey) async {
    final bool result = await _channel.invokeMethod(GC_SUBMIT_ACHIV, achivKey);

    return result;
  }

  ///Submit score to GameCenter by leadBoardId
  ///It takes [params] as Map - {[leadBoardId], [score]}
  ///
  ///Returns `true` if operation was successful or Throw `Future.error`
  static Future<String> reportScore(Map<String, int> params) async {
    final String result = await _channel.invokeMethod(GC_SUBMIT_SCORE, params);

    if (result == "true") {
      return "Report score result: OK";
    } else {
      return Future.error(result);
    }
  }

  ///Save game process to GameCenter passing [data] and [fileName] as `List`
  ///
  ///Return `String` error message if process was successful or Throw `Future.error`
  static Future<String> saveData(String data, String fileName) async {
    final String result = await _channel.invokeMethod(GC_SAVE_GAME_DATA, [data, fileName]);

    if(result == "true") {
      return result;
    } else {
      return Future.error(result);
    }
  }

  ///Load last saved game proccess from GameCenter
  ///
  ///Return `String` data or `ERROR` if any error is occurred
  ///or Throw `Future.error` with `ERROR` message
  static Future<String> loadData() async {
    final String result = await _channel.invokeMethod(GC_LOAD_GAME_DATA);

    if(result != ERROR) {
      return result;
    } else {
      return Future.error(ERROR);
    }
  }
}
