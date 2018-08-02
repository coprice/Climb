//
//  GameScene.swift
//  Climb
//
//  Created by Collin Price on 5/12/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import AVFoundation
import SpriteKit
import ObjectiveC
import GoogleMobileAds

// physics info
struct PhysicsCategory {
    static let None     : UInt32 = 0
    static let Climber  : UInt32 = 1
    static let Spikeball: UInt32 = 2
    static let Coin     : UInt32 = 3
    static let Platform : UInt32 = 4
}

// vector operations for CGPoints
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// random number generators
func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

var AssociatedObjectHandle: UInt8 = 0

// extend SKSpriteNode to contain a duration field for speed calculations
extension SKSpriteNode {
    private struct SwiftlyFuncCustomProperties {
        static var duration: CGFloat? = nil
        static var platformSize: Int? = nil
        static var dragEntered: Bool = false
        static var dragExited: Bool = false
    }
    var duration: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &SwiftlyFuncCustomProperties.duration) as? CGFloat
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &SwiftlyFuncCustomProperties.duration, unwrappedValue as CGFloat, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "whiteclimber")
    var initPlatform = SKSpriteNode()
    
    let pauseButton = SKSpriteNode(imageNamed: "pausebutton")
    let taptoShoot = SKLabelNode(fontNamed: "Futura")
    let scoreLabel = SKLabelNode(fontNamed: "Futura")
    let coinLabel = SKLabelNode(fontNamed: "Futura")
    
    var pauseBackground : UIButton!
    var pauseText : UILabel!
    var Continue : UIButton!
    var Quit : UIButton!
    
    var nodeToCheck: SKSpriteNode? = nil
    var popSound: SKAction!
    var coinSound: SKAction!
    
    // player score
    var numPlatforms = 0
    
    // event markers
    var isFlying = false
    var firstTouch = true
    
    // initiates game
    init(size: CGSize, initNumPlatforms: Int) {
        
        super.init(size: size)
        
        if defaults.bool(forKey: "ads") {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshInterstitialAd"), object: nil)
        }
        
        // allow external audio
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error as NSError {
            print("audio error: \(error)")
        }
        
        popSound = SKAction.playSoundFileNamed("/sounds/pop.mp3", waitForCompletion: false)
        coinSound = SKAction.playSoundFileNamed("/sounds/coin_collect.mp3", waitForCompletion: false)
        
        backgroundColor = .black
        numPlatforms = initNumPlatforms
        let (platformSize, _) = PlatformInfo()
        
        // initiate gravity of world
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        initPlatform = SKSpriteNode(imageNamed: "\(platformSize)platform")
        initPlatform.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        initPlatform.physicsBody = SKPhysicsBody(rectangleOf: initPlatform.size)
        initPlatform.physicsBody?.isDynamic = true
        initPlatform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        initPlatform.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        initPlatform.physicsBody?.collisionBitMask = PhysicsCategory.None
        initPlatform.physicsBody?.usesPreciseCollisionDetection = true
        
        player.position = CGPoint(x: size.width / 2, y: (size.height / 4))
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.None
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Spikeball
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.texture = SKTexture(imageNamed: "\(defaults.string(forKey: "climber")!)climber")
        
        addChild(initPlatform)
        addChild(player)
        
        // player score
        scoreLabel.text = "0"
        scoreLabel.fontSize = 0.064 * size.width
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.95)
        addChild(scoreLabel)
        
        // coin image
        let coin = SKSpriteNode(imageNamed: "smallcoin")
        coin.position = CGPoint(x: coin.size.width, y: size.height * 0.95 + coin.size.height / 2)
        coin.zPosition = 10
        addChild(coin)
        
        // amount of coins user has
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        coinLabel.fontSize = 0.064 * size.width
        coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        coinLabel.position = CGPoint(x: coin.size.width * 1.75, y: size.height * 0.95)
        coinLabel.zPosition = 10
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
        
        if numPlatforms == 0 {
            taptoShoot.text = "Tap to Climb!"
            taptoShoot.fontSize = 0.11 * size.width
            taptoShoot.fontColor = .yellow
            taptoShoot.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(taptoShoot)
        }
        
        // background music
        if defaults.bool(forKey: "music") {
            
            let backgroundMusic = SKAudioNode(fileNamed: "sounds/sylenth-shiz.mp3")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        // pause button
        pauseButton.position = CGPoint(x: size.width / 2, y: size.height / 40 + pauseButton.size.height / 2)
    }
    
    // returns (Platform size, Platform duration) based on numPlatforms
    func PlatformInfo() -> (Int, CGFloat) {
        // integer of 0 or 1
        let randomInt = Int(arc4random_uniform(2))
        
        if numPlatforms < 20 {
            return (5, 3.0)
        } else if numPlatforms < 50 {
            return (4 + randomInt, 2.5)
        } else if numPlatforms < 100 {
            return (3 + randomInt, 2.25)
        } else if numPlatforms < 175 {
            return (2 + randomInt, 2.0)
        } else if numPlatforms < 275 {
            return (1 + randomInt, 1.8)
        } else {return (1, 1.8)}
    }
    
    func addPlatform() {
        
        let (platformSize, platformDuration) = PlatformInfo()
        let platform = SKSpriteNode(imageNamed: "\(platformSize)platform")
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = true
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        platform.physicsBody?.collisionBitMask = PhysicsCategory.None
        platform.physicsBody?.usesPreciseCollisionDetection = true
        
        // Determine where to spawn the platform along the Y axis
        let Xpos = random(min: platform.size.width/2, max: size.width - platform.size.width/2)
        
        // position randomly on x axis, at top of screen
        platform.position = CGPoint(x: Xpos, y: size.height)
        
        // save platform duration
        platform.duration = platformDuration
        
        // Add the platform to the scene
        addChild(platform)
        
        // Create the actions
        let movePlatform = SKAction.move(to: CGPoint(x: Xpos, y: -20), duration: TimeInterval(platformDuration))
        let moveDone = SKAction.removeFromParent()
        
        platform.run(SKAction.sequence([movePlatform, moveDone]))
        
    }
    
    func addSpikeball() {
        let (_, duration) = PlatformInfo()
        let randomInt = arc4random_uniform(2)
        
        let spikeball = SKSpriteNode(imageNamed: "\(defaults.string(forKey: "spikeball")!)spikeball")
        spikeball.zPosition = -1.0
        spikeball.physicsBody = SKPhysicsBody(circleOfRadius: spikeball.size.width/2)
        spikeball.physicsBody?.isDynamic = true
        spikeball.physicsBody?.categoryBitMask = PhysicsCategory.Spikeball
        spikeball.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        spikeball.physicsBody?.collisionBitMask = PhysicsCategory.None
        spikeball.physicsBody?.usesPreciseCollisionDetection = true
        
        // spawn spikeballs on top half of screen
        let Ypos = random(min: size.height / 2 + spikeball.size.height / 2, max: size.height - spikeball.size.height / 2)
        var moveSpikeball : SKAction
        let moveDone = SKAction.removeFromParent()
        
        if randomInt == 0 {
            
            // spawn ball on left side
            spikeball.position = CGPoint(x: -20, y: Ypos)
            moveSpikeball = SKAction.move(to: CGPoint(x: size.height, y: Ypos), duration: TimeInterval(duration))
            
        } else {
            
            // spawn ball on right side
            spikeball.position = CGPoint(x: size.width + 20, y: Ypos)
            moveSpikeball = SKAction.move(to: CGPoint(x: spikeball.position.x - size.height, y: Ypos),
                                          duration: TimeInterval(duration))
        }
        
        addChild(spikeball)
        spikeball.run(SKAction.sequence([moveSpikeball, moveDone]))
        
    }
    
    func addCoin() {
        let (_, duration) = PlatformInfo()
        let randomInt = arc4random_uniform(2)
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.zPosition = -2.0
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.isDynamic = true
        coin.physicsBody?.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Climber
        coin.physicsBody?.collisionBitMask = PhysicsCategory.None
        coin.physicsBody?.usesPreciseCollisionDetection = true
        
        // spawn coins in middle half of screen
        let Ypos = random(min: size.height / 4 + coin.size.height / 2, max: size.height * 0.75 - coin.size.height/2)
        var moveCoin : SKAction
        let moveDone = SKAction.removeFromParent()
        
        if randomInt == 0 {
            
            // spawn coin on left side
            coin.position = CGPoint(x: -20, y: Ypos)
            moveCoin = SKAction.move(to: CGPoint(x: size.height, y: Ypos), duration: TimeInterval(duration))
            
        } else {
            
            // spawn coin on right side
            coin.position = CGPoint(x: size.width + 20, y: Ypos)
            moveCoin = SKAction.move(to: CGPoint(x: coin.position.x - size.height, y: Ypos),
                                     duration: TimeInterval(duration))
        }
        
        addChild(coin)
        coin.run(SKAction.sequence([moveCoin, moveDone]))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // allow game touches if game is not paused
        if !isPaused {
            
            // initiate game on first valid touch
            if firstTouch && (touchLocation.y >= player.position.y) {
                
                firstTouch = false
                addChild(pauseButton)
                
                let (_, duration) = PlatformInfo()
                initPlatform.duration = duration
                let moveInitPlatform = SKAction.move(to: CGPoint(x: initPlatform.position.x, y: -20), duration: TimeInterval(initPlatform.duration! * ((initPlatform.position.y + 20) / (size.height + 20))))
                let moveDone = SKAction.removeFromParent()
                initPlatform.run(SKAction.sequence([moveInitPlatform, moveDone]))
                
                // starting point of game based on carried over score
                if numPlatforms == 0 {
                    
                    let moveTaptoShoot = SKAction.move(to: CGPoint(x: taptoShoot.position.x, y: -20), duration : TimeInterval(3.0 * (taptoShoot.position.y + 20) / (size.height + 20)))
                    taptoShoot.run(SKAction.sequence([moveTaptoShoot, moveDone]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.5)]), count: 19),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.2)]), count: 30),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.1)]), count: 50),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]), count: 75),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.5),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.5)]), count: 5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.3),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.3)]), count: 6),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.1),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.1)]), count: 13),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                    
                } else if numPlatforms < 20 {
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.5)]),
                                        count: 20 - numPlatforms),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.2)]), count: 30),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.1)]), count: 50),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]), count: 75),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.5),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.5)]),
                                        count: 5 - numPlatforms % 4),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.3),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.3)]), count: 6),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.1),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.1)]), count: 13),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                } else if numPlatforms < 50 {
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.2)]),
                                        count: 50 - numPlatforms),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.1)]), count: 50),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]), count: 75),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.3),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.3)]),
                                        count: 6 - (numPlatforms - 20) % 5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.1),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.1)]),
                                        count: 13),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                } else if numPlatforms < 100 {
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.1)]),
                                        count: 100 - numPlatforms),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]), count: 75),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2.1),
                                                           SKAction.run(addCoin), SKAction.wait(forDuration: 2.1)]),
                                        count: 13 - (numPlatforms - 50) % 4),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                    
                } else if numPlatforms < 175 {
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeat(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]),
                                        count: 175 - numPlatforms),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                    
                } else {
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1.0)]))]))
                    
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.repeatForever(SKAction.sequence([SKAction.run(addSpikeball), SKAction.wait(forDuration: 2),
                                                                  SKAction.run(addCoin), SKAction.wait(forDuration: 2)]))]))
                }
                
            }
            
            if pauseButton.contains(touchLocation) {
                
                isGamePaused = true
                isPaused = true
                
                // display pause menu
                
                pauseBackground = UIButton(frame: CGRect(x: 0, y: size.height / 4, width: size.width,
                                                         height: size.height * 0.4))
                pauseBackground.backgroundColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                
                pauseText = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                pauseText.font = UIFont(name: "Futura", size: size.width * 0.12)
                pauseText.text = "Game Paused"
                pauseText.textColor = .white
                pauseText.center.x = pauseText.frame.width * 0.625
                pauseText.center.y = pauseBackground.center.y * 0.7
                
                Continue = UIButton(frame: CGRect(x: size.width * 0.175, y: size.height * 0.4,
                                                  width: size.width * 0.65, height: size.height / 16))
                Continue.layer.cornerRadius = 10
                Continue.backgroundColor = UIColor.init(red: 240/255, green: 128/255, blue: 128/255, alpha: 1)
                Continue.setTitle("Continue", for: .normal)
                Continue.titleLabel?.font = UIFont(name: "Futura", size: size.width * 0.064)
                Continue.addTarget(self, action: #selector(continueGame), for: .touchUpInside)
                
                Quit = UIButton(frame: CGRect(x: size.width * 0.175 , y: size.height * 0.5,
                                              width: size.width * 0.65, height: size.height / 16))
                Quit.layer.cornerRadius = 10
                Quit.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
                Quit.setTitle("Quit", for: .normal)
                Quit.titleLabel?.font = UIFont(name: "Futura", size: size.width * 0.064)
                Quit.addTarget(self, action: #selector(quitGame), for: .touchUpInside)
                
                viewDelegate.view.addSubview(pauseBackground)
                viewDelegate.view.addSubview(pauseText)
                viewDelegate.view.addSubview(Continue)
                viewDelegate.view.addSubview(Quit)
            }
            
            // projectile shooting manager
            if isFlying { return } else {
                
                isFlying = true
                
                // set up projectile physics
                let projectile = SKSpriteNode(imageNamed: "\(defaults.string(forKey: "climber")!)climber")
                projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
                projectile.physicsBody?.isDynamic = true
                projectile.physicsBody?.categoryBitMask = PhysicsCategory.Climber
                projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
                projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
                projectile.physicsBody?.usesPreciseCollisionDetection = true
                
                projectile.position = player.position
                
                // bail out if you are shooting backwards
                if (touchLocation.y < player.position.y) {
                    isFlying = false
                    return
                }
                
                // stop moving and remove player
                player.removeAllActions()
                player.removeFromParent()
                addChild(projectile)
                
                // get the direction of where to shoot
                let offset = touchLocation - projectile.position
                let direction = offset.normalized()
                let shootAmount = direction * 1000
                let realDest = shootAmount + projectile.position
                
                // create the actions
                let (_, platformDuration) = PlatformInfo()
                let moveProjectile = SKAction.move(to: realDest, duration: Double(platformDuration))
                let moveDone = SKAction.removeFromParent()
                
                // remember projectile
                nodeToCheck = projectile
                projectile.run(SKAction.sequence([moveProjectile, moveDone]))
                
            }
        }
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
        
        // climber has landed on a platform
        if firstBody.categoryBitMask == PhysicsCategory.Climber && secondBody.categoryBitMask == PhysicsCategory.Platform {
            if let climber = firstBody.node as? SKSpriteNode, let platform = secondBody.node as? SKSpriteNode {
                isFlying = false
                numPlatforms += 1
                
                // place player on top of platform of impact
                player.position = CGPoint(x: climber.position.x, y: platform.position.y + platform.size.height * 0.9)
                addChild(player)
                
                // remove projectile climber
                climber.removeAllActions()
                climber.removeFromParent()
                
                // make player fall with platform
                let duration = Float(platform.duration! * ((player.position.y + 20) / (size.height + 20)))
                let movePlayer = SKAction.move(to: CGPoint(x: player.position.x, y: -20), duration: TimeInterval(duration))
                let moveDone = SKAction.removeFromParent()
                player.run(SKAction.sequence([movePlayer, moveDone]))
                
                // landing sound
                if defaults.bool(forKey: "sound") {
                    run(popSound)
                }
            }
            
            // climber has hit a spikeball
        } else if (firstBody.categoryBitMask == PhysicsCategory.Climber &&
            secondBody.categoryBitMask == PhysicsCategory.Spikeball) ||
            (firstBody.categoryBitMask == PhysicsCategory.None &&
                secondBody.categoryBitMask == PhysicsCategory.Spikeball) {
            gameOver()
            
            // climber has hit a coin
        } else if (firstBody.categoryBitMask == PhysicsCategory.Climber &&
            secondBody.categoryBitMask == PhysicsCategory.Coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.None &&
                secondBody.categoryBitMask == PhysicsCategory.Coin) {
            if let coin = secondBody.node as? SKSpriteNode {
                coin.removeAllActions()
                coin.removeFromParent()
                let newCoins = defaults.integer(forKey: "coins") + 1
                defaults.set(newCoins, forKey: "coins")
                
                // coin collection sound
                if defaults.bool(forKey: "sound") {
                    run(coinSound)
                }
            }
        }
    }
    
    func gameOver () {
        self.removeAllActions()
        self.removeAllChildren()
        
        if defaults.integer(forKey: "extralives") > 0 && numPlatforms < 1000000 {
            
            let extraLifeScene = ExtraLifeMenu (size: self.size, score: numPlatforms)
            self.view?.presentScene(extraLifeScene)
            
        } else {
            let gameOverScene = GameOverScene(size: self.size, score: numPlatforms)
            self.view?.presentScene(gameOverScene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // update score info
        scoreLabel.text = String(numPlatforms)
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        
        if isGamePaused {
            self.isPaused = true
            return
        }
        
        if nodeToCheck == nil { return } else {
            
            // projectile has hit the boundary
            if nodeToCheck!.position.x < 0 || nodeToCheck!.position.x > size.width || nodeToCheck!.position.y > size.height {
                gameOver()
            }
        }
        
        if self.player.position.y < 0 || numPlatforms == 1000000 {
            gameOver()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func continueGame() {
        
        isGamePaused = false
        self.isPaused = false
        pauseBackground.removeFromSuperview()
        pauseText.removeFromSuperview()
        Continue.removeFromSuperview()
        Quit.removeFromSuperview()
    }
    
    @objc func quitGame() {
        
        isGamePaused = false
        pauseBackground.removeFromSuperview()
        pauseText.removeFromSuperview()
        Continue.removeFromSuperview()
        Quit.removeFromSuperview()
        
        let mainMenu = MenuScene(size: self.size)
        self.view?.presentScene(mainMenu)
        
    }
}

