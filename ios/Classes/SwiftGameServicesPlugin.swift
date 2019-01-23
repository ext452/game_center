import Flutter
import UIKit
import GameKit

public class SwiftGameServicesPlugin: UIViewController, GKGameCenterControllerDelegate, FlutterPlugin {
    
    let GC_LOGIN = "gcLogin"
    let GC_SUBMIT_SCORE = "gcSubmitScore"
    let GC_GET_SCORE = "gcGetScore"
    let GC_SUBMIT_ACHIV = "gcSubmitAchiv"
    let GC_SHOW_LEADERBOARD = "gcShowLeadBoard"
    let GC_SHOW_ACHIEVBOARD = "gcShowAchievBoard"
    let ERROR = "gcError"
    
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
        result(authPlayer())
        
    case GC_GET_SCORE:
        result(GC_GET_SCORE)
        
    case GC_SUBMIT_SCORE:
        let args = call.arguments as? NSArray
        
        let score = Int(args?[1] as! String)
        let leaderBoardId = args?[0] as? String
        
        if score != nil && leaderBoardId != nil {
            result(saveHighScore(leadBpardId: leaderBoardId!, score: score!))
        } else {
            result(false)
        }
        
    
    case GC_SHOW_LEADERBOARD:
        let leadBoardId = call.arguments as? String
        if leadBoardId != nil {
            result(showReaderBoard(leadBoardId: leadBoardId!))
        } else {
            result(false)
        }
        
    
    case GC_SHOW_ACHIEVBOARD:
        result(showAchivBoard())
        
    case GC_SUBMIT_ACHIV:
        let achivKey = call.arguments as? String
        result(achivKey)
        
    default:
        result("ERROR")
    }
  }

    
    func authPlayer() -> Bool {
        let localPlayer = GKLocalPlayer.localPlayer()
        var result = false
        localPlayer.authenticateHandler = {
            (view, error) in
            if error != nil {
                //error
            } else if view != nil {
                self.present(view!, animated: true, completion: nil)
                result = true
            }
            else {
                print(GKLocalPlayer.localPlayer().isAuthenticated)
                result = true
            }
            
        }
        
        return result
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func saveHighScore(leadBpardId: String, score: Int) -> Bool {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: leadBpardId)
            scoreReporter.value = Int64(score)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: nil)
            
            return true
        } else {
            return false
        }
    }
    
    func showReaderBoard(leadBoardId: String) -> Bool {
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let viewController = self.view.window?.rootViewController
            let gcVC = GKGameCenterViewController()
            
            gcVC.leaderboardIdentifier = leadBoardId
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.leaderboards
            viewController?.present(gcVC, animated: true, completion: nil)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(gcVC, animated: true, completion: nil)
            
            return true
        } else {
            return false
        }
        
        
    }
    
    func showAchivBoard() -> Bool {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let viewController = self.view.window?.rootViewController
            let gcVC = GKGameCenterViewController()
            
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.achievements
            viewController?.present(gcVC, animated: true, completion: nil)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(gcVC, animated: true, completion: nil)
            
            return true
        } else {
            return false
        }
        
    }
    
    func reportAchievement(achievement: String) -> Bool {
        var result = false
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let achieve = GKAchievement(identifier: achievement)
            achieve.showsCompletionBanner = true
            achieve.percentComplete = 100.0
            
            GKAchievement.report([achieve], withCompletionHandler: {(error: Error?) -> Void in
                if error != nil {
                    //error
                    print(error!)
                } else {
                    result = true
                }
            })
        }
        
        return result
    }
    
    public static func Save(saveData: String, fileName: String) -> Bool {
        var result = false
        
        if !GKLocalPlayer.localPlayer().isAuthenticated {
            return false
        }
        
        print("save data: \(saveData)")
        guard let data = saveData.data(using: String.Encoding.utf8) else {
            return false
        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.saveGameData(data, withName: fileName){
            (saveGame: GKSavedGame?, error: Error?) -> Void in
            if error != nil {
                print("Error saving: \(error)")
            } else {
                print("Save game success!")
                
                result = true
            }
        }
        
        return result
    }
    
    func Load() -> String {
        var result = self.ERROR
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if !localPlayer.isAuthenticated {
            return self.ERROR
        }
        
        localPlayer.fetchSavedGames() {
            (saveGames: [GKSavedGame]?, error: Error?) -> Void in
            if error != nil {
                print("fetch saving error: \(String(describing: error))")
                //error
            } else {
                print("game save lenth: \(String(describing: saveGames?.count))")
                guard (saveGames?.count)! > 0 else {
                    return
                }
                let save = saveGames?.first
                save?.loadData() {
                    (data: Data?, error: Error?) -> Void in
                    if error != nil {
                        print("Error load data: \(String(describing: error))")
                    } else {
                        guard let dataString = String(data: data!, encoding: .utf8) else {
                            return
                        }
                        print("base64Str: \(dataString)")
                        
                        result = dataString
                    }
                }
            }
        }
        
        return result
    }
    
    public static func Delete(fileName: String) -> Bool {
        var result = false
        
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.deleteSavedGames(withName: fileName) {
            (error: Error?) -> Void in
            if error != nil {
                print("Can not delete save game.")
            } else {
                result = true
                print("Delete save game succeed.")
            }
        }
        
        return result
    }
    
}
