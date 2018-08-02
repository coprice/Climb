//
//  MainMenu.swift
//  Climb
//
//  Created by Collin Price on 5/16/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import SpriteKit
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

let FBspinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

class MenuScene: SKScene, SKPhysicsContactDelegate {
    
    // buttons and labels
    var playButton : SKShapeNode!
    var scoresButton : SKShapeNode!
    var shopButton : SKShapeNode!
    var tipsButton : SKShapeNode!
    var tipsWindow : SKShapeNode!
    var musicButton : SKShapeNode!
    var soundButton : SKShapeNode!
    let musicLabel = SKSpriteNode(imageNamed: "rednotes")
    let soundLabel = SKSpriteNode(imageNamed: "sound")
    var FBButton : SKSpriteNode!
    var logoutInactive = true
    
    // background animation variables
    let climber = SKSpriteNode(imageNamed: "whiteclimber")
    let projectile = SKSpriteNode(imageNamed: "whiteclimber")
    let platform1 = SKSpriteNode(imageNamed: "5platform")
    let platform2 = SKSpriteNode(imageNamed: "5platform")
    let initPlatform = SKSpriteNode(imageNamed: "5platform")
    var firstContact = true
    
    override init(size: CGSize) {
        
        playButton = SKShapeNode(rectOf: CGSize(width: 0.37 * size.width, height: 0.15 * size.height),
                                 cornerRadius: 0.1 * size.width)
        scoresButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        shopButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        tipsButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        tipsWindow = SKShapeNode(rectOf: CGSize(width: 0.867 * size.width, height: 0.412 * size.height),
                                 cornerRadius: 0.05 * size.width)
        musicButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        soundButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        
        if FBSDKAccessToken.current() != nil {
            FBButton = SKSpriteNode(imageNamed: "FBSignOut")
        } else {
            FBButton = SKSpriteNode(imageNamed: "FBSignIn")
        }
        
        super.init(size: size)
        
        backgroundColor = .black
        
        climber.texture = SKTexture(imageNamed: "\(defaults.string(forKey: "climber")!)climber")
        projectile.texture = SKTexture(imageNamed: "\(defaults.string(forKey: "climber")!)climber")
        
        // initiate gravity of world
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        // coin image
        let coin = SKSpriteNode(imageNamed: "smallcoin")
        coin.position = CGPoint(x: coin.size.width, y: size.height * 0.95 + coin.size.height / 2)
        coin.zPosition = 1
        addChild(coin)
        
        // amount of coins user has
        let coinLabel = SKLabelNode(fontNamed: "Futura")
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        coinLabel.fontSize = 0.064 * size.width
        coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        coinLabel.position = CGPoint(x: coin.size.width * 1.75, y: size.height * 0.95)
        coinLabel.zPosition = 1
        addChild(coinLabel)
        
        // player high score
        let localScores = defaults.array(forKey: "scores") as! [Int]
        if localScores != [] {
            let bestScore = SKLabelNode(fontNamed: "Futura")
            bestScore.text = "Best: \(localScores.first!)"
            bestScore.fontSize = 0.064 * size.width
            bestScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            bestScore.position = CGPoint(x: size.width * 0.98, y: size.height * 0.95)
            bestScore.zPosition = 1
            addChild(bestScore)
        }
        
        // title
        let Title = SKLabelNode(fontNamed: "Futura")
        Title.zPosition = 1
        Title.text = "Climb"
        Title.fontSize = 0.17 * size.width
        Title.fontColor = .yellow
        Title.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        Title.zPosition = 1
        addChild(Title)
        
        // fb sign in/out
        FBButton.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        FBButton.zPosition = 1
        addChild(FBButton)
        
        // play button
        let playLabel = SKSpriteNode(imageNamed: "play")
        playLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5375)
        playLabel.zPosition = 1
        playButton.position = playLabel.position
        playButton.zPosition = 1
        addChild(playLabel)
        addChild(playButton)
        
        // tips button
        tipsButton.position = CGPoint(x: size.width * 0.375, y: size.height * 0.225)
        tipsButton.zPosition = 1
        tipsButton.strokeColor = .green
        let question = SKLabelNode(fontNamed: "Times")
        question.text = "?"
        question.fontSize = 0.14 * size.width
        question.fontColor = .green
        question.verticalAlignmentMode = .center
        question.position = tipsButton.position
        question.zPosition = 1
        addChild(question)
        addChild(tipsButton)
        
        // sound effects button
        soundButton.position = CGPoint(x: size.width * 0.625, y: size.height * 0.225)
        soundButton.zPosition = 1
        soundButton.strokeColor = .orange
        if !defaults.bool(forKey: "sound") {
            soundLabel.texture = SKTexture(imageNamed: "graysound")
            soundButton.strokeColor = .gray
        }
        soundLabel.position = soundButton.position
        soundLabel.zPosition = 1
        addChild(soundLabel)
        addChild(soundButton)
        
        // high scores button
        let scoresImage = SKSpriteNode(imageNamed: "scores")
        scoresImage.position = CGPoint(x: size.width * 0.25, y: size.height * 0.1)
        scoresImage.zPosition = 1
        scoresButton.position = scoresImage.position
        scoresButton.zPosition = 1
        scoresButton.strokeColor = .cyan
        addChild(scoresImage)
        addChild(scoresButton)
        
        // shop menu button
        let shopLabel = SKSpriteNode(imageNamed: "shop")
        shopLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        shopLabel.zPosition = 1
        shopButton.position = shopLabel.position
        shopButton.zPosition = 1
        shopButton.strokeColor = .yellow
        addChild(shopLabel)
        addChild(shopButton)
        
        musicButton.position = CGPoint(x: size.width * 0.75, y: size.height * 0.1)
        musicButton.zPosition = 1
        musicButton.strokeColor = .red
        // if music was off, make sound label gray
        if !defaults.bool(forKey: "music") {
            musicLabel.texture = SKTexture(imageNamed: "graynotes")
            musicButton.strokeColor = .gray
        }
        musicLabel.position = musicButton.position
        musicLabel.zPosition = 1
        addChild(musicLabel)
        addChild(musicButton)
        
        // try to save any cached data silently if logged in
        if FBSDKAccessToken.current() != nil {
            Cache.save_cache_silent(completion: nil)
        }
        
        // background animation
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(backgroundAnimation),
            SKAction.wait(forDuration: 8.0)])))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if playButton.contains(touchLocation) && !isPaused {
            
            self.removeAllActions()
            self.removeAllChildren()
            
            let gameStart = GameScene(size: self.size, initNumPlatforms: 0)
            self.view?.presentScene(gameStart)
            
        } else if tipsButton.contains(touchLocation) {
            
            if isPaused {
                tipsWindow.removeFromParent()
                isPaused = false
            } else {
                
                tipsWindow.fillColor = .black
                tipsWindow.position = playButton.position
                tipsWindow.zPosition = 2
                addChild(tipsWindow)
                
                let lineOne = SKLabelNode(fontNamed: "Futura")
                lineOne.text = "- Tap above the ball to Climb"
                lineOne.fontSize = 0.0533 * size.width
                lineOne.verticalAlignmentMode = .center
                lineOne.horizontalAlignmentMode = .left
                lineOne.position = CGPoint(x: -0.4 * size.width, y: lineOne.fontSize * 5)
                tipsWindow.addChild(lineOne)
                
                let lineTwo = SKLabelNode(fontNamed: "Futura")
                lineTwo.text = "upward"
                lineTwo.fontSize = 0.0533 * size.width
                lineTwo.verticalAlignmentMode = .center
                lineTwo.horizontalAlignmentMode = .left
                lineTwo.position = CGPoint(x: -0.37 * size.width, y: lineTwo.fontSize * 4)
                tipsWindow.addChild(lineTwo)
                
                let lineThree = SKLabelNode(fontNamed: "Futura")
                lineThree.text = "- Survive by Climbing from"
                lineThree.fontSize = 0.0533 * size.width
                lineThree.verticalAlignmentMode = .center
                lineThree.horizontalAlignmentMode = .left
                lineThree.position = CGPoint(x: -0.4 * size.width, y: lineThree.fontSize * 2.5)
                tipsWindow.addChild(lineThree)
                
                let lineFour = SKLabelNode(fontNamed: "Futura")
                lineFour.text = "platform to platform"
                lineFour.fontSize = 0.0533 * size.width
                lineFour.verticalAlignmentMode = .center
                lineFour.horizontalAlignmentMode = .left
                lineFour.position = CGPoint(x: -0.37 * size.width, y: lineFour.fontSize * 1.5)
                tipsWindow.addChild(lineFour)
                
                let lineFive = SKLabelNode(fontNamed: "Futura")
                lineFive.text = "- Don't touch any edges!"
                lineFive.fontSize = 0.0533 * size.width
                lineFive.verticalAlignmentMode = .center
                lineFive.horizontalAlignmentMode = .left
                lineFive.position = CGPoint(x: -0.4 * size.width, y: 0)
                tipsWindow.addChild(lineFive)
                
                let lineSix = SKLabelNode(fontNamed: "Futura")
                lineSix.text = "- Avoid spikeballs, which spawn"
                lineSix.fontSize = 0.0533 * size.width
                lineSix.verticalAlignmentMode = .center
                lineSix.horizontalAlignmentMode = .left
                lineSix.position = CGPoint(x: -0.4 * size.width, y: -lineSix.fontSize * 1.5)
                tipsWindow.addChild(lineSix)
                
                let lineSeven = SKLabelNode(fontNamed: "Futura")
                lineSeven.text = "on the upper half of the screen"
                lineSeven.fontSize = 0.0533 * size.width
                lineSeven.verticalAlignmentMode = .center
                lineSeven.horizontalAlignmentMode = .left
                lineSeven.position = CGPoint(x: -0.37 * size.width, y: -lineSeven.fontSize * 2.5)
                tipsWindow.addChild(lineSeven)
                
                let lineEight = SKLabelNode(fontNamed: "Futura")
                lineEight.text = "- Collect coins to unlock more"
                lineEight.fontSize = 0.0533 * size.width
                lineEight.verticalAlignmentMode = .center
                lineEight.horizontalAlignmentMode = .left
                lineEight.position = CGPoint(x: -0.4 * size.width, y: -lineEight.fontSize * 4)
                tipsWindow.addChild(lineEight)
                
                let lineNine = SKLabelNode(fontNamed: "Futura")
                lineNine.text = "sprites!"
                lineNine.fontSize = 0.0533 * size.width
                lineNine.verticalAlignmentMode = .center
                lineNine.horizontalAlignmentMode = .left
                lineNine.position = CGPoint(x: -0.37 * size.width, y: -lineNine.fontSize * 5)
                tipsWindow.addChild(lineNine)
                
                // pause animation
                isPaused = true
                
            }
            
        } else if scoresButton.contains(touchLocation) {
            
            self.removeAllActions()
            self.removeAllChildren()
            
            let scoresStart = Leaderboards(size: self.size)
            self.view?.presentScene(scoresStart)
            
        } else if shopButton.contains(touchLocation) {
            
            self.removeAllActions()
            self.removeAllChildren()
            
            let shopStart = ShopScene(size: self.size)
            self.view?.presentScene(shopStart)
            
        } else if soundButton.contains(touchLocation) {
            
            if defaults.bool(forKey: "sound") {
                soundLabel.texture = SKTexture(imageNamed: "graysound")
                soundButton.strokeColor = .gray
                defaults.set(false, forKey: "sound")
            } else {
                soundLabel.texture = SKTexture(imageNamed: "sound")
                soundButton.strokeColor = .orange
                defaults.set(true, forKey: "sound")
            }
            
        } else if musicButton.contains(touchLocation) {
            
            if defaults.bool(forKey: "music") {
                musicLabel.texture = SKTexture(imageNamed: "graynotes")
                musicButton.strokeColor = .gray
                defaults.set(false, forKey: "music")
            } else {
                musicLabel.texture = SKTexture(imageNamed: "rednotes")
                musicButton.strokeColor = .red
                defaults.set(true, forKey: "music")
            }
            
            // tries to save user's cached data (if any)
        } else if FBButton.contains(touchLocation) && logoutInactive {
            
            // sign out currently active button
            if FBSDKAccessToken.current() != nil {
                
                logoutInactive = false
                
                let cache = defaults.array(forKey: "cachedscores") as! [Int]
                let sprites : [String : [Int]] =
                    ["climber" : defaults.array(forKey: "climbers") as! [Int],
                     "spikeball" : defaults.array(forKey: "spikeballs") as! [Int]]
                
                // something needs to be saved
                if !cache.isEmpty || defaults.bool(forKey: "unsaved") {
                    
                    // both need to be saved, so attempt both sequentially
                    if !cache.isEmpty && defaults.bool(forKey: "unsaved") {
                        
                        // attempt to save user scores (with an alert of failure)
                        API.save_user_scores(fb_id: FBSDKAccessToken.current().userID, scores: cache, completion_handler: {
                            (response) in
                            
                            if response == URLResponse.NotConnected {
                                
                                Cache.createAlert(title: "Warning: Unsaved User Data", message: "Connect to the Internet",
                                                  view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.Error {
                                
                                Cache.createAlert(title: "Unknown Error",
                                                  message: "Couldn't log out", view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.ServerDown {
                                
                                Cache.createAlert(title: "Unsaved User Data",
                                                  message: "Sorry, our servers are down, so we cannot currently save your data.", view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else {
                                //print("cached scores saved")
                                defaults.set([], forKey: "cachedscores")
                                
                                // attempt to save the user's info
                                API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: sprites, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extra_lives"), completion_handler: {
                                    
                                    (response, _) in
                                    
                                    if response == URLResponse.NotConnected {
                                        
                                        Cache.createAlert(title: "Warning: Unsaved User Data", message: "Connect to the Internet",
                                                          view: viewDelegate)
                                        self.logoutInactive = true
                                        return
                                        
                                    } else if response == URLResponse.Error {
                                        
                                        Cache.createAlert(title: "Unknown Error",
                                                          message: "Couldn't save user data",
                                                          view: viewDelegate)
                                        self.logoutInactive = true
                                        return
                                        
                                    } else if response == URLResponse.ServerDown {
                                        
                                        Cache.createAlert(title: "Unsaved User Data",
                                                          message: "Sorry, our servers are down, so we cannot currently save your data.", view: viewDelegate)
                                        self.logoutInactive = true
                                        return
                                        
                                    } else {
                                        //print("cached user info saved")
                                        defaults.set(false, forKey: "unsaved")
                                        self.logout()
                                    }
                                })
                            }
                        })
                        
                        // only scores need to be saved
                    } else if !cache.isEmpty {
                        
                        API.save_user_scores(fb_id: FBSDKAccessToken.current().userID, scores: cache, completion_handler: {
                            (response) in
                            
                            if response == URLResponse.NotConnected {
                                
                                Cache.createAlert(title: "Warning: Unsaved User Data", message: "Connect to the Internet",
                                                  view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.Error {
                                
                                Cache.createAlert(title: "Unknown Error", message: "Couldn't save user scores",
                                                  view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.ServerDown {
                                
                                Cache.createAlert(title: "Unsaved User Data",
                                                  message: "Sorry, our servers are down, so we cannot currently save your data.", view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else {
                                
                                //print("cached scores saved")
                                defaults.set([], forKey: "cachedscores")
                                self.logout()
                            }
                        })
                        
                        // only user info needs to be saved
                    } else {
                        
                        API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: sprites, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extra_lives"), completion_handler: {
                            
                            (response, _) in
                            
                            if response == URLResponse.NotConnected {
                                
                                Cache.createAlert(title: "Warning: Unsaved User Data", message: "Connect to the Internet",
                                                  view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.Error {
                                
                                Cache.createAlert(title: "Unknown Error", message: "Couldn't save user data",
                                                  view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else if response == URLResponse.ServerDown {
                                
                                Cache.createAlert(title: "Unsaved User Data",
                                                  message: "Sorry, our servers are down, so we cannot currently save your data.", view: viewDelegate)
                                self.logoutInactive = true
                                return
                                
                            } else {
                                print("cached user info saved")
                                defaults.set(false, forKey: "unsaved")
                                self.logout()
                            }
                        })
                    }
                    
                    // don't need to save any cached info
                } else {
                    self.logout()
                }
                
                // fb sign in button is active
            } else {
                
                // start facebook login process
                FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "user_friends"], from: viewDelegate, handler: {
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
                        self.removeAllActions()
                        
                        let loading = LoadingScene(size: self.size)
                        self.view?.presentScene(loading, transition: SKTransition.fade(with: .gray, duration: 1))
                    }
                })
            }
        }
    }
    
    func backgroundAnimation () {
        
        platform1.position = CGPoint(x: size.width * 0.8, y: size.height * 2.0)
        platform1.physicsBody = SKPhysicsBody(rectangleOf: platform1.size)
        platform1.physicsBody?.isDynamic = true
        platform1.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform1.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        platform1.physicsBody?.collisionBitMask = PhysicsCategory.None
        platform1.physicsBody?.usesPreciseCollisionDetection = true
        
        platform2.position = CGPoint(x: size.width * 0.2, y: size.height * 2.6)
        platform2.physicsBody = SKPhysicsBody(rectangleOf: platform2.size)
        platform2.physicsBody?.isDynamic = true
        platform2.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform2.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        platform2.physicsBody?.collisionBitMask = PhysicsCategory.None
        platform2.physicsBody?.usesPreciseCollisionDetection = true
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Climber
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        initPlatform.position = CGPoint(x: size.width * 0.2, y: size.height * 1.4)
        climber.zPosition = 0.5
        climber.position = CGPoint(x: size.width * 0.2, y: initPlatform.position.y + initPlatform.size.height * 1.3)
        
        addChild(platform1)
        addChild(platform2)
        addChild(initPlatform)
        addChild(climber)
        
        let movePlatform1 = SKAction.move(to: CGPoint(x: size.width * 0.8, y: -20), duration: TimeInterval(6.0))
        let movePlatform2 = SKAction.move(to: CGPoint(x: size.width * 0.2, y: -20),
                                          duration: TimeInterval(6.0 * (platform2.position.y + 20) / (size.height * 2 + 20)))
        let moveClimber = SKAction.move(to: CGPoint(x: climber.position.x, y: size.height / 4),
                                        duration: TimeInterval(6.0 * (climber.position.y - size.height / 4) / (size.height * 2 + 20)))
        let moveinitPlatform = SKAction.move(to: CGPoint(x: initPlatform.position.x, y: -20),
                                             duration: TimeInterval(6.0 * (initPlatform.position.y + 20) / (size.height * 2 + 20)))
        let moveDone = SKAction.removeFromParent()
        
        platform1.run(SKAction.sequence([movePlatform1, moveDone]))
        platform2.run(SKAction.sequence([movePlatform2, moveDone]))
        climber.run(SKAction.sequence([moveClimber, moveDone, SKAction.run(shoot1)]))
        initPlatform.run(SKAction.sequence([moveinitPlatform, moveDone]))
    }
    
    func shoot1() {
        projectile.position = CGPoint(x: climber.position.x, y: climber.position.y + size.height * 0.007)
        addChild(projectile)
        
        let moveProjectile = SKAction.move(to: CGPoint(x: size.width * 1.2, y: size.height * 0.7), duration: TimeInterval(1.1))
        let moveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveProjectile, moveDone]))
    }
    
    func shoot2() {
        projectile.position = CGPoint(x: climber.position.x, y: climber.position.y + size.height * 0.007)
        addChild(projectile)
        
        let moveProjectile = SKAction.move(to: CGPoint(x: 0, y: size.height * 0.7), duration: TimeInterval(1.1))
        let moveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveProjectile, moveDone]))
    }
    
    func shoot3() {
        projectile.position = CGPoint(x: climber.position.x, y: climber.position.y + size.height * 0.007)
        addChild(projectile)
        
        let moveProjectile = SKAction.move(to: CGPoint(x: size.width / 2, y: size.height * 1.1), duration: TimeInterval(1.0))
        let moveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveProjectile, moveDone]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // make first body the smaller mass
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // if smallest mass isn't zero, a projectile hit a platform
        if firstBody.categoryBitMask != 0 {
            if let projectile = firstBody.node as? SKSpriteNode, let platform = secondBody.node as? SKSpriteNode {
                climber.position = CGPoint(x: projectile.position.x, y: platform.position.y + platform.size.height * 0.95)
                addChild(climber)
                
                let moveDone = SKAction.removeFromParent()
                
                // remove projectile climber
                projectile.removeAllActions()
                projectile.removeFromParent()
                
                if firstContact {
                    firstContact = false
                    
                    let spikeball = SKSpriteNode(imageNamed: "\(defaults.string(forKey: "spikeball")!)spikeball")
                    spikeball.position = CGPoint(x: size.width + 20, y: size.height * 0.74)
                    spikeball.zPosition = -1.0
                    addChild(spikeball)
                    
                    let moveSpikeball = SKAction.move(to: CGPoint(x: size.width - size.height, y: size.height * 0.74), duration: 2.5)
                    spikeball.run(SKAction.sequence([moveSpikeball, moveDone]))
                    
                    let moveClimber = SKAction.move(to: CGPoint(x: climber.position.x, y: size.height / 4), duration: TimeInterval(6.0 * (climber.position.y - size.height / 4) / (size.height * 2 + 20)))
                    climber.run(SKAction.sequence([moveClimber, moveDone, SKAction.run(shoot2)]))
                } else {
                    firstContact = true
                    let moveClimber = SKAction.move(to: CGPoint(x: climber.position.x, y: size.height * 0.4),
                                                    duration: TimeInterval(6.0 * (climber.position.y - size.height * 0.4) / (size.height * 2 + 20)))
                    climber.run(SKAction.sequence([moveClimber, moveDone, SKAction.run(shoot3)]))
                }
            }
        }
    }
    
    func logout() {
        
        LoginManager().logOut()
        self.removeAllActions()
        self.removeAllChildren()
        
        let login = LoginScene(size: self.size)
        self.view?.presentScene(login, transition: SKTransition.fade(with: .gray, duration: 1))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

