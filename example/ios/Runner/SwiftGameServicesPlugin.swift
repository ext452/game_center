import Flutter
import UIKit
import GameKit

public class SwiftGameServicesPlugin: NSObject, FlutterPlugin, GKGameCenterControllerDelegate {
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    let GC_LOGIN = "gcLogin"
    let GC_LOGOUT = "gcLogout"
    let GC_SUBMIT_SCORE = "gcSubmitScore"
    let GC_GET_SCORE = "gcGetScore"
    let GC_SUBMIT_ACHIV = "gcSubmitAchiv"
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    let gameCenterPlayer = GKLocalPlayer.localPlayer()
    
    var score = 0
    
    let LEADERBOARD_ID = "com.orbita.words4"
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "game_services", binaryMessenger: registrar.messenger())
    var instance = SwiftGameServicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case GC_LOGIN:
        authenticateLocalPlayer()
        result(GC_LOGIN)
        
    case GC_LOGOUT:
        result(GC_LOGOUT)
        
    case GC_GET_SCORE:
        result(GC_GET_SCORE)
        
    case GC_SUBMIT_SCORE:
        result(GC_SUBMIT_SCORE)
        
    case GC_SUBMIT_ACHIV:
        result(GC_SUBMIT_ACHIV)
        
    default:
        result("ERROR")
    }
  }

    func notificationReceived()
    {
        println("GKPlayerAuthenticationDidChangeNotificationName - Authentication Status: \(self.localPlayer.authenticated)")
    }
    
    //MARK: 2 Authenticate the Player
    func authenticateLocalPlayer()
    {
        println(__FUNCTION__)
        self.delegate?.willSignIn()
        
        self.localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            
            if (viewController != nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAuthenticationDialogueWhenReasonable(viewController)
                })
            }
                
            else if (self.localPlayer.authenticated == true)
            {
                println("Player is Authenticated")
                self.registerListener()
                self.downloadCachedMatches()
                self.delegate?.didSignIn()
            }
                
            else
            {
                println("User Still Not Authenticated")
                self.delegate?.failedToSignIn()
            }
            
            if (error)
            {
                self.delegate?.failedToSignInWithError(error)
            }
        }
    }
    
    //MARK: 2a Show Authentication Dialogue
    func showAuthenticationDialogueWhenReasonable(viewController:UIViewController!) -> Void
    {
        println(__FUNCTION__)
        UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(viewController, animated: true, completion: nil)
    }
}
