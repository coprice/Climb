//
//  Playground.swift
//  Climb
//
//  Created by Brandon Price on 5/29/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import SpriteKit
import FBSDKLoginKit
import FacebookLogin

class LoginScene: SKScene {
    
    let continueButton = SKSpriteNode(imageNamed: "FBContinue")
    let guestButton = SKShapeNode(rectOf: CGSize(width: 186, height: 30),
                                  cornerRadius: 5)
    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .gray
        
        continueButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.55)
        addChild(continueButton)
        
        guestButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.45)
        guestButton.fillColor = .white
        guestButton.strokeColor = .black
        addChild(guestButton)
        
        let guest = SKLabelNode(fontNamed: "Futura")
        guest.text = "CONTINUE AS A GUEST"
        guest.fontColor = .black
        guest.position = guestButton.position
        guest.verticalAlignmentMode = .center
        guest.fontSize = 11
        addChild(guest)
        
        // reset sprite selectables
        defaults.set("white", forKey: "climber")
        defaults.set("white", forKey: "spikeball")
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if continueButton.contains(touchLocation) {
            
            // start facebook login process
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "user_friends"],
                                      from: viewDelegate, handler: {
                                        (result, error) in
                                        
                                        // box cancelled
                                        if (result?.isCancelled)! {
                                            return
                                            
                                            // some error occured
                                        } else if error != nil {
                                            return
                                            
                                            // login was successful
                                        } else {
                                            
                                            self.removeAllChildren()
                                            self.UserInfoManager()
                                            
                                        }
            })
            
        } else if guestButton.contains(touchLocation) {
            
            // set all default values
            defaults.set([], forKey: "scores")
            defaults.set(0, forKey: "coins")
            defaults.set([0], forKey: "climbers")
            defaults.set([0], forKey: "spikeballs")
            defaults.set(0, forKey: "extralives")
            defaults.set(true, forKey: "ads")
            defaults.set("", forKey: "firstname")
            defaults.set("", forKey: "lastname")
            defaults.set([], forKey: "cachedscores")
            defaults.set(false, forKey: "unsaved")
            
            defaults.set(true, forKey: "guest")
            loadMainMenu()
        }
    }
    
    func UserInfoManager() {
        
        self.startSpinner()
        
        API.get_user_info(fb_id: FBSDKAccessToken.current().userID, completion_handler: {
            (response, user_info) in
            
            // no internet connection
            if response == URLResponse.NotConnected {
                
                self.returnToLogin()
                Cache.createAlert(title: "Connection Error", message: "Please check your internet connection",
                                  view: viewDelegate)
                self.stopSpinner()
                return
                
            } else if response == URLResponse.ServerDown {
                
                self.returnToLogin()
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
                        self.returnToLogin()
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
                                self.returnToLogin()
                                Cache.createAlert(title: "Connection Error", message: "Unable to Save User Info",
                                                  view: viewDelegate)
                                return
                                
                                // no internet connectivity
                            } else if response == URLResponse.NotConnected {
                                
                                self.stopSpinner()
                                self.returnToLogin()
                                Cache.createAlert(title: "Connection Error", message: "Please check your internet connection", view: viewDelegate)
                                return
                                
                            } else if response == URLResponse.ServerDown {
                                
                                self.stopSpinner()
                                self.returnToLogin()
                                Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                                  view: viewDelegate)
                                return
                                
                                // user successfully created
                            } else {
                                
                                // set default values
                                defaults.set([], forKey: "scores")
                                defaults.set(0, forKey: "coins")
                                defaults.set([0], forKey: "climbers")
                                defaults.set([0], forKey: "spikeballs")
                                defaults.set(0, forKey: "extralives")
                                defaults.set(true, forKey: "ads")
                                
                                // remember user's name
                                defaults.set(data["first_name"], forKey: "firstname")
                                defaults.set(data["last_name"], forKey: "lastname")
                                
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
                
                // search for user's scores
                API.get_users_scores(fb_id: FBSDKAccessToken.current().userID, completion_handler: {
                    (response, data) in
                    
                    // no internet
                    if response == URLResponse.NotConnected {
                        
                        self.stopSpinner()
                        self.returnToLogin()
                        Cache.createAlert(title: "Connection Error", message: "Please check your internet connection",
                                          view: viewDelegate)
                        return
                        
                    } else if response == URLResponse.Error {
                        
                        self.stopSpinner()
                        self.returnToLogin()
                        Cache.createAlert(title: "Unknown Error", message: "An Unknown Error Occured",
                                          view: viewDelegate)
                        return
                        
                    } else if response == URLResponse.ServerDown {
                        
                        self.stopSpinner()
                        self.returnToLogin()
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
    
    func returnToLogin() {
        
        LoginManager().logOut()
        
        let login = LoginScene(size: self.size)
        view?.presentScene(login, transition: SKTransition.fade(with: .gray, duration: 1))
    }
    
    func loadMainMenu() {
        
        let MainMenu = MenuScene(size: self.size)
        self.view?.presentScene(MainMenu, transition: SKTransition.fade(withDuration: 1))
    }
    
    func startSpinner() {
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        viewDelegate.view.addSubview(myActivityIndicator)
        
    }
    
    func stopSpinner() {
        
        myActivityIndicator.stopAnimating()
    }
}

