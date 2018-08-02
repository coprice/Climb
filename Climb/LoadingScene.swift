
//
//  File.swift
//  Climb
//
//  Created by Collin Price on 8/8/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import SpriteKit
import FBSDKLoginKit
import FacebookLogin

class LoadingScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .gray
        UserInfoManager()
        
    }
    
    func UserInfoManager() {
        
        self.startSpinner()
        
        API.get_user_info(fb_id: FBSDKAccessToken.current().userID, completion_handler: {
            (response, user_info) in
            
            // no internet connection
            if response == URLResponse.NotConnected {
                
                self.returnToMenu()
                Cache.createAlert(title: "Connection Error", message: "Please check your internet connection",
                                  view: viewDelegate)
                self.stopSpinner()
                return
                
            } else if response == URLResponse.ServerDown {
                
                self.returnToMenu()
                Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                  view: viewDelegate)
                self.stopSpinner()
                return
                
                // user not found in database
            } else if response == URLResponse.Error {
                
                // get user info from facebook
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name"]).start(completionHandler: { (connection, result, error) -> Void in
                    
                    // couldn't get facebook info
                    if error != nil {
                        self.stopSpinner()
                        self.returnToMenu()
                        Cache.createAlert(title: "Connection Error", message: "Couldn't Connect to Facebook",
                                          view: viewDelegate)
                        return
                        
                        // fb info retrieved
                    } else {
                        
                        let data = result as! [String : String]
                        
                        // create new user in backend
                        API.create_user(first_name: data["first_name"]!, last_name: data["last_name"]!, fb_id: data["id"]!, completion_handler: {
                            
                            (response, _) in
                            
                            // couldn't save user's info
                            if response == URLResponse.Error {
                                
                                self.stopSpinner()
                                self.returnToMenu()
                                Cache.createAlert(title: "Connection Error", message: "Unable to Save User Info",
                                                  view: viewDelegate)
                                return
                                
                                // no internet connectivity
                            } else if response == URLResponse.NotConnected {
                                
                                self.stopSpinner()
                                self.returnToMenu()
                                Cache.createAlert(title: "Connection Error", message: "Please check your internet connection", view: viewDelegate)
                                return
                                
                            } else if response == URLResponse.ServerDown {
                                
                                self.stopSpinner()
                                self.returnToMenu()
                                Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                                  view: viewDelegate)
                                return
                                
                                // user successfully created
                            } else {
                                
                                // remember user's name
                                defaults.set(data["first_name"], forKey: "firstname")
                                defaults.set(data["last_name"], forKey: "lastname")
                                
                                let totalSprites : [String : [Int]] =
                                    ["climber" : defaults.array(forKey: "climbers") as! [Int],
                                     "spikeball" : defaults.array(forKey: "spikeballs") as! [Int]]
                                
                                // save user's data from life as a guest user
                                API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: totalSprites, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extralives"), completion_handler: {
                                    
                                    (response, _) in
                                    
                                    if response != URLResponse.Success {
                                        defaults.set(true, forKey: "unsaved")
                                    }
                                    
                                })
                                
                                API.save_user_scores(fb_id: FBSDKAccessToken.current().userID, scores: defaults.array(forKey: "scores") as! [Int], completion_handler: {
                                    
                                    (response) in
                                    
                                    if response != URLResponse.Success {
                                        defaults.set(defaults.array(forKey: "scores") as! [Int], forKey: "cachedscores")
                                    }
                                })
                                
                                self.run(SKAction.sequence([SKAction.run(self.stopSpinner),
                                                            SKAction.run(self.loadMainMenu)]))
                            }
                        })
                    }
                })
                
                // user already exists and info was successfully retrieved
            } else {
                
                // set user stats
                let sprites = user_info!["sprites"] as! [String : [Int]]
                defaults.set(sprites["climber"]!, forKey: "climbers")
                defaults.set(sprites["spikeball"]!, forKey: "spikeballs")
                defaults.set(user_info!["coins"] as! Int, forKey: "coins")
                defaults.set(user_info!["extra_lives"] as! Int, forKey: "extralives")
                defaults.set(user_info!["ads"] as! Bool, forKey: "ads")
                defaults.set(user_info!["first_name"], forKey: "firstname")
                defaults.set(user_info!["last_name"], forKey: "lastname")
                defaults.set("white", forKey: "climber")
                defaults.set("white", forKey: "spikeball")
                
                // search for user's scores
                API.get_users_scores(fb_id: FBSDKAccessToken.current().userID, completion_handler: {
                    (response, data) in
                    
                    // no internet
                    if response == URLResponse.NotConnected {
                        
                        self.stopSpinner()
                        self.returnToMenu()
                        Cache.createAlert(title: "Connection Error", message: "Please check your internet connection",
                                          view: viewDelegate)
                        return
                        
                    } else if response == URLResponse.Error {
                        
                        self.stopSpinner()
                        self.returnToMenu()
                        Cache.createAlert(title: "Unknown Error", message: "An Unknown Error Occured",
                                          view: viewDelegate)
                        return
                        
                    } else if response == URLResponse.ServerDown {
                        
                        self.stopSpinner()
                        self.returnToMenu()
                        Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                          view: viewDelegate)
                        return
                        
                        // scores were retrieved
                    } else {
                        
                        // user has no scores yet
                        if data! == [] {
                            
                            defaults.set([], forKey: "scores")
                            
                            // user has scores: save up to the top 25 locally
                        } else {
                            
                            if data!.count < 25 {
                                defaults.set(data!, forKey: "scores")
                            } else {
                                defaults.set(Array(data![0..<25]), forKey: "scores")
                            }
                        }
                        
                        self.run(SKAction.sequence([SKAction.run(self.stopSpinner), SKAction.run(self.loadMainMenu)]))
                    }
                })
            }
        })
    }
    
    func returnToMenu() {
        
        LoginManager().logOut()
        let menu = MenuScene(size: self.size)
        view?.presentScene(menu, transition: SKTransition.fade(with: .gray, duration: 1))
    }
    
    func loadMainMenu() {
        
        defaults.set(false, forKey: "guest")
        let MainMenu = MenuScene(size: self.size)
        self.view?.presentScene(MainMenu, transition: SKTransition.fade(withDuration: 1))
    }
    
    func startSpinner() {
        
        // Position Activity Indicator in the center of the main view
        FBspinner.center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Start Activity Indicator
        FBspinner.startAnimating()
        
        viewDelegate.view.addSubview(FBspinner)
        
    }
    
    func stopSpinner() {
        
        FBspinner.stopAnimating()
    }
    
}

