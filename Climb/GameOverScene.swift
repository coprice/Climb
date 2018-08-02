//
//  GameOverScene.swift
//  Climb
//
//  Created by Collin Price on 5/14/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import SpriteKit
import FBSDKCoreKit

class GameOverScene: SKScene {
    
    var replayButton : SKShapeNode!
    var shareButton : SKShapeNode!
    var scoresButton : SKShapeNode!
    var shopButton : SKShapeNode!
    var homeButton : SKShapeNode!
    
    init(size: CGSize, score: Int) {
        
        if defaults.bool(forKey: "ads") {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayInterstitialAd"), object: nil)
        }
        
        replayButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        shareButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        scoresButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        shopButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        homeButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        
        super.init(size: size)
        
        backgroundColor = .black
        
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
        
        // new game
        let replayLabel = SKSpriteNode(imageNamed: "replay")
        replayLabel.position = CGPoint(x: size.width * 0.375, y: size.height * 0.225)
        replayButton.position = replayLabel.position
        addChild(replayLabel)
        addChild(replayButton)
        
        // share with friends button
        shareButton.strokeColor = .red
        shareButton.position = CGPoint(x: size.width * 0.625, y: size.height * 0.225)
        let shareLabel = SKLabelNode(fontNamed: "Futura")
        shareLabel.text = "Share"
        shareLabel.fontSize = 0.064 * size.width
        shareLabel.fontColor = .red
        shareLabel.position = CGPoint(x: shareButton.position.x, y: shareButton.position.y - shareLabel.fontSize * 0.4)
        addChild(shareLabel)
        addChild(shareButton)
        
        // high scores menu
        let scoresImage = SKSpriteNode(imageNamed: "scores")
        scoresImage.position = CGPoint(x: size.width * 0.25, y: size.height * 0.1)
        scoresButton.position = scoresImage.position
        scoresButton.strokeColor = .cyan
        addChild(scoresImage)
        addChild(scoresButton)
        
        // shop
        let shopLabel = SKSpriteNode(imageNamed: "shop")
        shopLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        shopButton.position = shopLabel.position
        shopButton.strokeColor = .yellow
        addChild(shopLabel)
        addChild(shopButton)
        
        // main menu
        let homeImage = SKSpriteNode(imageNamed: "home")
        homeImage.position = CGPoint(x: size.width * 0.75, y: size.height * 0.1)
        homeButton.position = homeImage.position
        
        addChild(homeImage)
        addChild(homeButton)
        
        // game over title
        let GameOverLabel = SKLabelNode(fontNamed: "Futura")
        if score < 1000000 {
            GameOverLabel.text = "Game Over"
        } else {
            GameOverLabel.text = "You Win"
        }
        
        GameOverLabel.fontSize = 0.128 * size.width
        GameOverLabel.fontColor = .yellow
        GameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(GameOverLabel)
        
        let bestScore = SKLabelNode(fontNamed: "Futura")
        let localScores = defaults.array(forKey: "scores") as! [Int]
        
        // scores arent empty
        if localScores != [] {
            
            // new best
            if score > localScores.first! {
                bestScore.text = "New Best: \(score)"
                
                // not new best
            } else {
                bestScore.text = "Best: \(localScores.first!)"
            }
            
            // score is automatically new best
        } else {
            bestScore.text = "New Best: \(score)"
        }
        
        // display
        bestScore.fontSize = 0.064 * size.width
        bestScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        bestScore.position = CGPoint(x: size.width * 0.98, y: size.height * 0.95)
        addChild(bestScore)
        
        // player score
        let ScoreLabel = SKLabelNode(fontNamed: "Futura")
        ScoreLabel.text = String(score)
        ScoreLabel.fontColor = .yellow
        ScoreLabel.fontSize = 0.17 * size.width
        ScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.525)
        addChild(ScoreLabel)
        
        // text surrounding player score
        let youClimbed = SKLabelNode(fontNamed: "Futura")
        youClimbed.text = "You Climbed"
        youClimbed.fontSize = 0.1 * size.width
        youClimbed.position = CGPoint(x: size.width / 2, y: ScoreLabel.position.y + ScoreLabel.fontSize)
        addChild(youClimbed)
        let platforms = SKLabelNode(fontNamed: "Futura")
        if score == 1 {
            platforms.text = "Platform"
        } else {
            platforms.text = "Platforms"
        }
        platforms.fontSize = 0.1 * size.width
        platforms.position = CGPoint(x: size.width / 2, y: ScoreLabel.position.y - ScoreLabel.fontSize * 0.7)
        addChild(platforms)
        
        // update local score data
        updateLocalScores(score: score)
        
        // save score and coins to backend if logged in
        if FBSDKAccessToken.current() != nil {
            updateScore(score: score)
            updateCoins()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if replayButton.contains(touchLocation) {
            self.removeAllChildren()
            let gameStart = GameScene(size: self.size, initNumPlatforms: 0)
            self.view?.presentScene(gameStart)
        }
        
        if shareButton.contains(touchLocation) {
            let textToShare = "Hey! Download this incredibly fun and free game called Climb! I've scored \((defaults.array(forKey: "scores") as! [Int]).first!). Can you beat me? Find it here: https://itunes.apple.com/us/app/climb-platforms/id1250427510?ls=1&mt=8"
            
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            let currentViewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
            
            currentViewController.present(activityVC, animated: true, completion: nil)
        }
        
        if scoresButton.contains(touchLocation) {
            self.removeAllChildren()
            
            let scoresStart = Leaderboards(size: self.size)
            self.view?.presentScene(scoresStart)
        }
        
        if shopButton.contains(touchLocation) {
            self.removeAllChildren()
            let shopStart = ShopScene(size: self.size)
            self.view?.presentScene(shopStart)
        }
        
        if homeButton.contains(touchLocation) {
            self.removeAllChildren()
            
            let mainMenu = MenuScene(size: self.size)
            self.view?.presentScene(mainMenu)
        }
    }
    
    // updates scores saved locally
    func updateLocalScores (score: Int) {
        
        var localscores = defaults.array(forKey: "scores")! as! [Int]
        
        if localscores.count < 25 {
            
            // create room with a value that will always get beaten
            localscores.append(-1)
            
            // search until we beat a score
            for index in 0..<localscores.count {
                
                if score > localscores[index] {
                    
                    // score is not last in array so we shift values after it
                    if index < localscores.count - 1 {
                        localscores[index+1..<localscores.count] = localscores[index..<localscores.count - 1]
                    }
                    
                    // update score in proper place
                    localscores[index] = score
                    defaults.set(localscores, forKey: "scores")
                    return
                }
            }
            
            // already 20 scores
        } else {
            
            // keep searching until we find a score we beat
            for index in 0..<25 {
                
                if score > localscores[index] {
                    
                    // score is not last in array so we shift values after it
                    if index < 24  {
                        localscores[index+1...24] = localscores[index..<24]
                    }
                    
                    // update score in its position
                    localscores[index] = score
                    defaults.set(localscores, forKey: "scores")
                    return
                }
            }
        }
    }
    
    func updateScore(score: Int) {
        
        API.save_score(fb_id: FBSDKAccessToken.current().userID, score: score, completion_handler: {
            (response) in
            
            // not online, so cache the score
            if response != URLResponse.Success {
                
                var cache = defaults.array(forKey: "cachedscores") as! [Int]
                cache.append(score)
                defaults.set(cache, forKey: "cachedscores")
                print("scores cached, not saved")
                return
            }
            print("score saved")
        })
    }
    
    func updateCoins() {
        
        API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: nil, ads: nil, extra_lives: defaults.integer(forKey: "extralives"), completion_handler: {
            (response, _) in
            
            if response != URLResponse.Success {
                
                defaults.set(true, forKey: "unsaved")
                print("coins not saved")
                return
            }
            print("coins saved")
        })
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

