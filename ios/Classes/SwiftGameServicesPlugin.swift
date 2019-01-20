import Flutter
import UIKit
import GameKit

public class SwiftGameServicesPlugin: UIViewController, GKGameCenterControllerDelegate, FlutterPlugin {
    
    let GC_LOGIN = "gcLogin"
    let GC_LOGOUT = "gcLogout"
    let GC_SUBMIT_SCORE = "gcSubmitScore"
    let GC_GET_SCORE = "gcGetScore"
    let GC_SUBMIT_ACHIV = "gcSubmitAchiv"
    let GC_SHOW_LEADERBOARD = "gcShowLeadBoard"
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    let gameCenterPlayer = GKLocalPlayer.localPlayer()
    
    var score = 0
    
    let LEADERBOARD_ID = "com.orbita.words4"
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "game_services", binaryMessenger: registrar.messenger())
    let instance = SwiftGameServicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case GC_LOGIN:
        authPlayer()
        result(GC_LOGIN)
        
    case GC_LOGOUT:
        result(GC_LOGOUT)
        
    case GC_GET_SCORE:
        result(GC_GET_SCORE)
        
    case GC_SUBMIT_SCORE:
        result(GC_SUBMIT_SCORE)
    
    case GC_SHOW_LEADERBOARD:
        showReaderBoard()
        result(GC_SHOW_LEADERBOARD)
        
    case GC_SUBMIT_ACHIV:
        result(GC_SUBMIT_ACHIV)
        
    default:
        result("ERROR")
    }
  }

    
    func authPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view, error) in
            if view != nil {
                self.present(view!, animated: true, completion: nil)
            }
            else {
                print("dddddd")
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
            
        }
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func saveHighScore(number: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "test")
            scoreReporter.value = Int64(number)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func showReaderBoard(){
        let viewController = self.view.window?.rootViewController
        let gcVC = GKGameCenterViewController()
        
        gcVC.gameCenterDelegate = self
        viewController?.present(gcVC, animated: true, completion: nil)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(gcVC, animated: true, completion: nil)
        
    }
    
}
