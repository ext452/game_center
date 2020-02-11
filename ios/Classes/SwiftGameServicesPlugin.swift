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
    let GC_SAVE_GAME_DATA = "gcSaveGameData"
    let GC_LOAD_GAME_DATA = "gcLoadGameData"
    let ERROR = "ERROR"
    
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
        authPlayer() {(on_ressult) in result(on_ressult)}
        
    case GC_GET_SCORE:
        result(GC_GET_SCORE)
        
    case GC_SUBMIT_SCORE:
        let args = call.arguments as? NSDictionary
        
        let leaderBoardId = args?.allKeys[0] as! String
        
        let score = args?.value(forKey: leaderBoardId) as! Int
        
        
        
        saveHighScore(leadBpardId: leaderBoardId, score: score) {(on_result) in result(on_result)}
    
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
        result(reportAchievement(achievement: achivKey!))
        
    case GC_SAVE_GAME_DATA:
        let args = call.arguments as? NSArray
        
        if args != nil && args?.count == 2 {
            let data = args?[0] as! String
            let fileName = args?[1] as! String
            
            
            saveGameData(saveData: data, fileName: fileName) { (output) in
                result(output)
            }
        } else {
            result("arguments error")
        }
        
    case GC_LOAD_GAME_DATA:
        loadGameData() { (output) in
            result(output)
        }
        
        
    default:
        result(self.ERROR)
    }
  }

    
    func authPlayer(completion:@escaping (Bool) -> Void) {
        
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            view, error in
                if error != nil {
                    completion(false)
                } else if view != nil {
                    UIApplication.shared.keyWindow?.rootViewController?.present(view!, animated: true, completion: nil)
                    completion(true)
                } else if (GKLocalPlayer.localPlayer().isAuthenticated) {
                    print(GKLocalPlayer.localPlayer().isAuthenticated)
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func saveHighScore(leadBpardId: String, score: Int, completion:@escaping (String) -> Void ) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: leadBpardId)
            scoreReporter.value = Int64(score)
            scoreReporter.leaderboardIdentifier = leadBpardId
            
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report([scoreReporter], withCompletionHandler: {(error: Error?) -> Void in
                if error != nil {
                    //error
                    completion("Error while report score: \(String(describing: error))")
                } else {
                    completion("true")
                }
            })
        } else {
            completion("not authenticated!!!")
        }
    }
    
    func showReaderBoard(leadBoardId: String) -> Bool {
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let gcVC = GKGameCenterViewController()
            
            gcVC.leaderboardIdentifier = leadBoardId
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.leaderboards
            
            UIApplication.shared.keyWindow?.rootViewController?.present(gcVC, animated: true, completion: nil)
            
            return true
        } else {
            return false
        }
        
        
    }
    
    func showAchivBoard() -> Bool {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let gcVC = GKGameCenterViewController()
            
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.achievements
            
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
    
    func saveGameData(saveData: String, fileName: String, completion:@escaping (String) -> Void) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            guard let data = saveData.data(using: String.Encoding.utf8) else {
                completion("encoding error")
                return
            }
            
            let localPlayer = GKLocalPlayer.localPlayer()
            localPlayer.saveGameData(data, withName: fileName){
                (saveGame: GKSavedGame?, error: Error?) -> Void in
                if error != nil {
                    print("Error saving: \(String(describing: error))")
                    
                    completion("Error saving: \(String(describing: error))")
                } else {
                    print("Save game success!")
                    
                    completion("true")
                }
            }
        } else {
            completion("Not authenticated!")
        }
        
    }
    
    func loadGameData(completion:@escaping (String) -> Void) {
        var result = self.ERROR
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            localPlayer.fetchSavedGames() {
                (saveGames: [GKSavedGame]?, error: Error?) -> Void in
                if error != nil {
                    print("fetch saving error: \(String(describing: error))")
                    result = String(describing: error)
                    
                    completion(result)
                    //error
                } else {
                    print("game save lenth: \(String(describing: saveGames?.count))")
                    guard (saveGames?.count)! > 0 else {
                        result = "SAVE LENTH 0"
                        completion(result)
                        return
                    }
                    let save = saveGames?.first
                    save?.loadData() {
                        (data: Data?, error: Error?) -> Void in
                        if error != nil {
                            print("Error load data: \(String(describing: error))")
                            result = String(describing: error)
                            
                            completion(result)
                        } else {
                            guard let dataString = String(data: data!, encoding: .utf8) else {
                                result = "Error encoding"
                                
                                completion(result)
                                return
                            }
                            print("base64Str: \(dataString)")
                            
                            result = dataString
                            
                            completion(result)
                        }
                    }
                }
            }
        }
    }
    
    func deleteGameData(fileName: String) -> Bool {
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
