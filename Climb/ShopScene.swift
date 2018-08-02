//
//  Shop.swift
//  Climb
//
//  Created by Collin Price on 5/18/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//
//  Scrollable menu adapted from https://github.com/crashoverride777/SwiftySKScrollView
//

import StoreKit
import SpriteKit
import FBSDKCoreKit
import GoogleMobileAds

struct Sprites {
    static let white = 0
    static let Red = 1
    static let Blue = 2
    static let Green = 3
    static let Orange = 4
    static let Purple = 5
    static let Yellow = 6
    static let Cyan = 7
    static let Magenta = 8
    static let Brown = 9
    static let Gray = 10
    static let Silver = 11
    static let Gold = 12
    static let Rainbow = 13
}

var requestingPurchase = false

class ShopScene: SKScene {
    
    let coinLabel = SKLabelNode(fontNamed: "Futura")
    let heartLabel = SKLabelNode(fontNamed: "Futura")
    
    var videoButton : SKShapeNode!
    var livesButton : SKShapeNode!
    var scoresButton : SKShapeNode!
    var homeButton : SKShapeNode!
    var noAdsButton : SKShapeNode!
    var firstPurchaseButton : SKShapeNode!
    var secondPurchaseButton : SKShapeNode!
    var thirdPurchaseButton : SKShapeNode!
    var restoreButton : SKShapeNode!
    
    var storeNotLoaded = true
    
    // store loading spinners
    let lifeSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let smallSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let mediumSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let largeSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let adSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    // scrollable menus
    let moveableNodeClimber = SKNode()
    let moveableNodeSpikeball = SKNode()
    weak var scrollViewClimber : SwiftySKScrollView?
    weak var scrollViewSpikeball : SwiftySKScrollView?
    
    // climber menu buttons
    let whiteClimberButton = SKSpriteNode(imageNamed: "whiteoutline")
    let redClimberButton = SKSpriteNode(imageNamed: "redoutline")
    let blueClimberButton = SKSpriteNode(imageNamed: "blueoutline")
    let greenClimberButton = SKSpriteNode(imageNamed: "greenoutline")
    let orangeClimberButton = SKSpriteNode(imageNamed: "orangeoutline")
    let purpleClimberButton = SKSpriteNode(imageNamed: "purpleoutline")
    let yellowClimberButton = SKSpriteNode(imageNamed: "yellowoutline")
    let cyanClimberButton = SKSpriteNode(imageNamed: "cyanoutline")
    let magentaClimberButton = SKSpriteNode(imageNamed: "magentaoutline")
    let brownClimberButton = SKSpriteNode(imageNamed: "brownoutline")
    let grayClimberButton = SKSpriteNode(imageNamed: "grayoutline")
    let silverClimberButton = SKSpriteNode(imageNamed: "silveroutline")
    let goldClimberButton = SKSpriteNode(imageNamed: "goldoutline")
    let rainbowClimberButton = SKSpriteNode(imageNamed: "rainbowoutline")
    
    // spikeball menu buttons
    let whiteSpikeballButton = SKSpriteNode(imageNamed: "whiteoutline")
    let redSpikeballButton = SKSpriteNode(imageNamed: "redoutline")
    let blueSpikeballButton = SKSpriteNode(imageNamed: "blueoutline")
    let greenSpikeballButton = SKSpriteNode(imageNamed: "greenoutline")
    let orangeSpikeballButton = SKSpriteNode(imageNamed: "orangeoutline")
    let purpleSpikeballButton = SKSpriteNode(imageNamed: "purpleoutline")
    let yellowSpikeballButton = SKSpriteNode(imageNamed: "yellowoutline")
    let cyanSpikeballButton = SKSpriteNode(imageNamed: "cyanoutline")
    let magentaSpikeballButton = SKSpriteNode(imageNamed: "magentaoutline")
    let brownSpikeballButton = SKSpriteNode(imageNamed: "brownoutline")
    let graySpikeballButton = SKSpriteNode(imageNamed: "grayoutline")
    let silverSpikeballButton = SKSpriteNode(imageNamed: "silveroutline")
    let goldSpikeballButton = SKSpriteNode(imageNamed: "goldoutline")
    let rainbowSpikeballButton = SKSpriteNode(imageNamed: "rainbowoutline")
    
    // dictionaries for easy lookup given a string of a color
    var climberButtons : [String : SKSpriteNode]!
    var spikeballButtons : [String : SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        videoButton = SKShapeNode(rectOf: CGSize(width: 0.42 * size.width, height: 0.13 * size.height))
        livesButton = SKShapeNode(rectOf: CGSize(width: 0.42 * size.width, height: 0.13 * size.height))
        scoresButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        homeButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        noAdsButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        firstPurchaseButton = SKShapeNode(rectOf: CGSize(width: 0.267 * size.width, height: 0.267 * size.width))
        secondPurchaseButton = SKShapeNode(rectOf: CGSize(width: 0.267 * size.width, height: 0.267 * size.width))
        thirdPurchaseButton = SKShapeNode(rectOf: CGSize(width: 0.267 * size.width, height: 0.267 * size.width))
        restoreButton = SKShapeNode(rectOf: CGSize(width: 0.225 * size.width, height: 0.05 * size.height),
                                    cornerRadius: 0.01 * size.height)
        
        // info for dictionaries
        climberButtons =
            ["white" : whiteClimberButton, "red" : redClimberButton, "blue" : blueClimberButton,
             "green" : greenClimberButton, "orange" : orangeClimberButton, "purple" : purpleClimberButton,
             "yellow" : yellowClimberButton, "cyan" : cyanClimberButton, "magenta" : magentaClimberButton,
             "brown" : brownClimberButton, "gray" : grayClimberButton, "silver" : silverClimberButton,
             "gold" : goldClimberButton, "rainbow" : rainbowClimberButton]
        spikeballButtons =
            ["white" : whiteSpikeballButton, "red" : redSpikeballButton, "blue" : blueSpikeballButton,
             "green" : greenSpikeballButton, "orange" : orangeSpikeballButton, "purple" : purpleSpikeballButton,
             "yellow" : yellowSpikeballButton, "cyan" : cyanSpikeballButton, "magenta" : magentaSpikeballButton,
             "brown" : brownSpikeballButton, "gray" : graySpikeballButton, "silver" : silverSpikeballButton,
             "gold" : goldSpikeballButton, "rainbow" : rainbowSpikeballButton]
        
        // coin image
        let coin = SKSpriteNode(imageNamed: "smallcoin")
        coin.position = CGPoint(x: coin.size.width, y: size.height * 0.95 + coin.size.height / 2)
        addChild(coin)
        
        // amount of coins user has
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        coinLabel.fontSize = 0.064 * size.width
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: coin.size.width * 1.75, y: size.height * 0.95)
        addChild(coinLabel)
        
        // heart image
        let heart = SKSpriteNode(imageNamed: "smallheart")
        heart.position = CGPoint(x: heart.size.width, y: size.height * 0.9 + heart.size.height / 2)
        addChild(heart)
        
        // amount of extra lives user has
        heartLabel.text = String(defaults.integer(forKey: "extralives"))
        heartLabel.fontSize = 0.064 * size.width
        heartLabel.horizontalAlignmentMode = .left
        heartLabel.position = CGPoint(x: heart.size.width * 1.75, y: size.height * 0.9)
        addChild(heartLabel)
        
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
        
        // restore purchase button
        restoreButton.strokeColor = .clear
        restoreButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        restoreButton.position = CGPoint(x: size.width * 0.86, y: size.height * 0.912)
        addChild(restoreButton)
        
        // restore purchase label
        let restore = SKLabelNode(fontNamed: "Futura")
        restore.text = "Restore"
        restore.fontSize = size.width * 0.05
        restore.fontColor = .lightGray
        restore.position = CGPoint(x: size.width * 0.86, y: size.height * 0.9)
        addChild(restore)
        
        // shop title
        let shopTitle = SKLabelNode(fontNamed: "Futura")
        shopTitle.text = "Shop"
        shopTitle.fontSize = 0.14 * size.width
        shopTitle.fontColor = .yellow
        shopTitle.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(shopTitle)
        
        // watch video button
        videoButton.position = CGPoint(x: size.width * 0.27, y: size.height * 0.76)
        videoButton.strokeColor = .clear
        videoButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        addChild(videoButton)
        
        // watch a video text
        let videoLabel = SKLabelNode(fontNamed: "Futura")
        videoLabel.text = "Watch A Video"
        videoLabel.fontSize = 0.05 * size.width
        videoLabel.verticalAlignmentMode = .center
        videoLabel.position = CGPoint(x: 0, y: size.height / 30)
        videoButton.addChild(videoLabel)
        
        // video image
        let videoImage = SKSpriteNode(imageNamed: "clapboard")
        videoImage.position = CGPoint(x: -size.width / 7, y: -size.height / 35)
        videoButton.addChild(videoImage)
        
        // plus label
        let plus = SKLabelNode(fontNamed: "Futura")
        plus.text = "+10"
        plus.fontColor = .yellow
        plus.fontSize = 0.075 * size.width
        plus.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        plus.verticalAlignmentMode = .center
        plus.position = CGPoint(x: size.width / 14, y: videoImage.position.y)
        videoButton.addChild(plus)
        
        // video coin image
        let videoCoin = SKSpriteNode(imageNamed: "coin")
        videoCoin.position = CGPoint(x: size.width / 7, y: videoImage.position.y)
        videoButton.addChild(videoCoin)
        
        // extra life button
        livesButton.position = CGPoint(x: size.width - size.width * 0.27, y: size.height * 0.76)
        livesButton.strokeColor = .clear
        livesButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        addChild(livesButton)
        
        // high scores button
        let scoresImage = SKSpriteNode(imageNamed: "scores")
        scoresImage.position = CGPoint(x: size.width * 0.25, y: size.height * 0.1)
        scoresButton.position = scoresImage.position
        scoresButton.strokeColor = .cyan
        addChild(scoresImage)
        addChild(scoresButton)
        
        // main menu button
        let homeImage = SKSpriteNode(imageNamed: "home")
        homeImage.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        homeButton.position = homeImage.position
        addChild(homeImage)
        addChild(homeButton)
        
        // no adds button
        noAdsButton.position = CGPoint(x: size.width * 0.75, y: size.height * 0.1)
        noAdsButton.strokeColor = .red
        addChild(noAdsButton)
        
        // if ads are disabled, display a share button
        if !defaults.bool(forKey: "ads") {
            let shareLabel = SKLabelNode(fontNamed: "Futura")
            shareLabel.text = "Share"
            shareLabel.fontSize = 0.064 * size.width
            shareLabel.fontColor = .red
            shareLabel.position = CGPoint(x: noAdsButton.position.x, y: noAdsButton.position.y - shareLabel.fontSize * 0.4)
            shareLabel.zPosition = 10
            addChild(shareLabel)
        }
        
        // purchase options
        firstPurchaseButton.position = CGPoint(x: size.width * 0.18, y: size.height / 4)
        firstPurchaseButton.strokeColor = .clear
        firstPurchaseButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        addChild(firstPurchaseButton)
        
        secondPurchaseButton.position = CGPoint(x: size.width / 2, y: size.height / 4)
        secondPurchaseButton.strokeColor = .clear
        secondPurchaseButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        addChild(secondPurchaseButton)
        
        thirdPurchaseButton.position = CGPoint(x: size.width * 0.82, y: size.height / 4)
        thirdPurchaseButton.strokeColor = .clear
        thirdPurchaseButton.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        addChild(thirdPurchaseButton)
        
        // add moveable node for scrollable menus
        addChild(moveableNodeClimber)
        addChild(moveableNodeSpikeball)
        
        // add scrollable menus
        climberMenu()
        spikeballMenu()
        
        // shapes to make edges of climber menu look good
        let climberMenuBackground = SKShapeNode(rectOf: CGSize(width: size.width, height: 90))
        climberMenuBackground.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        climberMenuBackground.strokeColor = .clear
        climberMenuBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        climberMenuBackground.zPosition = -10
        addChild(climberMenuBackground)
        
        let spikeballMenuBackground = SKShapeNode(rectOf: CGSize(width: size.width, height: 90))
        spikeballMenuBackground.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1)
        spikeballMenuBackground.strokeColor = .clear
        spikeballMenuBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.425)
        spikeballMenuBackground.zPosition = -10
        addChild(spikeballMenuBackground)
        
        let leftViewBlocker = SKShapeNode(rectOf: CGSize(width: 0.025 * size.width, height: size.height / 2))
        leftViewBlocker.position = CGPoint(x: 0.0125 * size.width, y: size.height * 0.55)
        leftViewBlocker.zPosition = 5
        leftViewBlocker.fillColor = .black
        leftViewBlocker.strokeColor = .clear
        addChild(leftViewBlocker)
        
        let rightViewBlocker = SKShapeNode(rectOf: CGSize(width: 0.025 * size.width, height: size.height / 2))
        rightViewBlocker.position = CGPoint(x: size.width - 0.0125 * size.width, y: size.height * 0.55)
        rightViewBlocker.zPosition = 5
        rightViewBlocker.fillColor = .black
        rightViewBlocker.strokeColor = .clear
        addChild(rightViewBlocker)
        
        // products have already been loaded
        if ClimbProducts.store.products != [] {
            self.storeNotLoaded = false
            self.displayStore()
            
            // products aren't loading
        } else {
            
            startSpinners()
            
            ClimbProducts.store.requestProducts{success, products in
                if success {
                    ClimbProducts.store.products = products!
                    self.storeNotLoaded = false
                }
                
                self.stopSpinners()
                self.displayStore()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // disable touches while requesting a purchase or loading a video
        if requestingPurchase || videoActive { return }
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        let node = atPoint(touchLocation)
        
        // returns to the main menu
        if homeButton.contains(touchLocation) {
            
            // disable scroll menus and sprites
            scrollViewClimber?.isUserInteractionEnabled = false
            scrollViewClimber?.showsHorizontalScrollIndicator = false
            scrollViewSpikeball?.isUserInteractionEnabled = false
            scrollViewSpikeball?.showsHorizontalScrollIndicator = false
            self.removeAllChildren()
            
            // stop any active spinners
            stopSpinners()
            
            let mainMenu = MenuScene(size: self.size)
            self.view?.presentScene(mainMenu)
            
            // goes to high scores menu
        } else if scoresButton.contains(touchLocation) {
            
            // disable scroll menus and sprites
            scrollViewClimber?.isUserInteractionEnabled = false
            scrollViewClimber?.showsHorizontalScrollIndicator = false
            scrollViewSpikeball?.isUserInteractionEnabled = false
            scrollViewSpikeball?.showsHorizontalScrollIndicator = false
            self.removeAllChildren()
            
            // stop any active spinners
            stopSpinners()
            
            let scoresStart = Leaderboards(size: self.size)
            self.view?.presentScene(scoresStart)
            
            // restore purchases
        } else if restoreButton.contains(touchLocation) {
            
            ClimbProducts.store.restorePurchases()
            
            // video ad button
        } else if videoButton.contains(touchLocation) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showVideoRewardAd"), object: nil)
            return
            
            // purchase no ads
        } else if noAdsButton.contains(touchLocation) {
            
            if defaults.bool(forKey: "ads") {
                
                if storeNotLoaded {
                    
                    Cache.createAlert(title: "Store Not Loaded", message: "Connect to the Internet and Reload",
                                      view: viewDelegate)
                } else {
                    
                    requestingPurchase = true
                    let product = ClimbProducts.store.products[3]
                    ClimbProducts.store.buyProduct(product)
                }
                
            } else {
                
                var textToShare: String
                if defaults.array(forKey: "scores") as! [Int] == [] {
                    textToShare = "Hey! Download this incredibly fun and free game called Climb! Find it here: https://itunes.apple.com/us/app/climb-platforms/id1250427510?ls=1&mt=8"
                } else {
                    textToShare = "Hey! Download this incredibly fun and free game called Climb! I've scored \((defaults.array(forKey: "scores") as! [Int]).first!). Can you beat me? Find it here: https://itunes.apple.com/us/app/climb-platforms/id1250427510?ls=1&mt=8"
                }
                
                let objectsToShare = [textToShare]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                viewDelegate.present(activityVC, animated: true, completion: nil)
            }
            
            // purchase extra life
        } else if livesButton.contains(touchLocation) {
            
            if storeNotLoaded {
                Cache.createAlert(title: "Store Not Loaded", message: "Connect to the Internet and Reload",
                                  view: viewDelegate)
            } else {
                
                requestingPurchase = true
                let product = ClimbProducts.store.products[0]
                ClimbProducts.store.buyProduct(product)
            }
            
            // purchase small coin bundle
        } else if firstPurchaseButton.contains(touchLocation) {
            
            if storeNotLoaded {
                Cache.createAlert(title: "Store Not Loaded", message: "Connect to the Internet and Reload",
                                  view: viewDelegate)
            } else {
                
                requestingPurchase = true
                let product = ClimbProducts.store.products[4]
                ClimbProducts.store.buyProduct(product)
            }
            
            // purchase medium coin bundle
        } else if secondPurchaseButton.contains(touchLocation) {
            
            if storeNotLoaded {
                Cache.createAlert(title: "Store Not Loaded", message: "Connect to the Internet and Reload",
                                  view: viewDelegate)
            } else {
                
                requestingPurchase = true
                let product = ClimbProducts.store.products[2]
                ClimbProducts.store.buyProduct(product)
            }
            
            // purchase large coin bundle
        } else if thirdPurchaseButton.contains(touchLocation) {
            
            if storeNotLoaded {
                Cache.createAlert(title: "Store Not Loaded", message: "Connect to the Internet and Reload",
                                  view: viewDelegate)
            } else {
                
                requestingPurchase = true
                let product = ClimbProducts.store.products[1]
                ClimbProducts.store.buyProduct(product)
            }
            
            // node is in a scrollable menu (only scrollable buttons are given names)
        } else if let name = node.name {
            
            let currentButton = node as! SKSpriteNode
            var price = 100
            
            // climber menu is clicked
            if String(name.suffix(7)) == "climber" {
                
                let colorEnd = name.index(name.endIndex, offsetBy: -7)
                let currentColor = String(name[name.startIndex..<colorEnd])
                
                // change price for special sprites
                if currentColor == "silver" { price = 250 } else if currentColor == "gold" { price = 500 }
                
                // get previously chosen button info
                guard let previousColor = defaults.string(forKey: "climber") else { return }
                guard let previousButton = climberButtons[previousColor] else { return }
                var climbers = defaults.array(forKey: "climbers") as! [Int]
                
                // unlock sprite if possible or select sprite
                checkSprite(currentButton: currentButton, previousButton: previousButton, price: price,
                            currentColor: currentColor, previousColor: previousColor, sprites: &climbers,
                            spriteType: "climber")
                
                // spikeball menu is clicked
            } else {
                
                let colorEnd = name.index(name.endIndex, offsetBy: -9)
                let currentColor = String(name[name.startIndex..<colorEnd])
                
                // change price for special sprites
                if currentColor == "silver" { price = 250 } else if currentColor == "gold" { price = 500 }
                
                // get previously chosen button info
                guard let previousColor = defaults.string(forKey: "spikeball") else { return }
                guard let previousButton = spikeballButtons[previousColor] else { return }
                var spikeballs = defaults.array(forKey: "spikeballs") as! [Int]
                
                // unlock sprite if possible or select sprite
                checkSprite(currentButton: currentButton, previousButton: previousButton, price: price,
                            currentColor: currentColor, previousColor: previousColor, sprites: &spikeballs,
                            spriteType: "spikeball")
            }
        }
    }
    
    /***** HELPERS *****/
    
    // scrolling menu for climbers
    func climberMenu() {
        
        // set up scrollView
        scrollViewClimber = SwiftySKScrollView(frame: CGRect(x: frame.width / 20, y: frame.height * 0.4 - 45,
                                                             width: frame.width - frame.width / 10, height: 90),
                                               moveableNode: moveableNodeClimber, direction: .horizontal)
        
        guard let scrollView = scrollViewClimber else { return }
        
        scrollView.contentSize = CGSize(width: 3.7 * size.width, height: 90)
        view?.addSubview(scrollView)
        
        // set scrollView to first page
        scrollView.setContentOffset(CGPoint(x: 2.8 * size.width, y: 0), animated: false)
        
        // highlighting menu for easy positioning of buttons
        let horizontalMenu = SKShapeNode(rectOf: CGSize(width: 1.8 * size.width, height: 0.267 * size.width))
        horizontalMenu.zPosition = -1
        horizontalMenu.position = CGPoint(x: frame.midX - (frame.width * 1.8), y: frame.height * 0.6)
        horizontalMenu.strokeColor = .clear
        moveableNodeClimber.addChild(horizontalMenu)
        
        /// Menu Images ///
        
        let climbers = defaults.array(forKey: "climbers") as! [Int]
        let currentClimberColor = defaults.string(forKey: "climber")!
        
        // white climber is unlocked by default
        whiteClimberButton.position = CGPoint(x: -size.width * 1.333, y: 0)
        whiteClimberButton.name = "whiteclimber"
        horizontalMenu.addChild(whiteClimberButton)
        
        let whiteClimber = SKSpriteNode(imageNamed: "whiteclimber")
        whiteClimber.zPosition = -1
        whiteClimberButton.addChild(whiteClimber)
        
        // all other climbers might be locked
        redClimberButton.position = CGPoint(x: -size.width * 1.067, y: 0)
        redClimberButton.name = "redclimber"
        horizontalMenu.addChild(redClimberButton)
        addButtonSprites(button: redClimberButton, isUnlocked: climbers.contains(Sprites.Red),
                         spriteName: "redclimber", price: "100")
        
        blueClimberButton.position = CGPoint(x: -size.width * 0.8, y: 0)
        blueClimberButton.name = "blueclimber"
        horizontalMenu.addChild(blueClimberButton)
        addButtonSprites(button: blueClimberButton, isUnlocked: climbers.contains(Sprites.Blue),
                         spriteName: "blueclimber", price: "100")
        
        greenClimberButton.position = CGPoint(x: -size.width * 0.533, y: 0)
        greenClimberButton.name = "greenclimber"
        horizontalMenu.addChild(greenClimberButton)
        addButtonSprites(button: greenClimberButton, isUnlocked: climbers.contains(Sprites.Green),
                         spriteName: "greenclimber", price: "100")
        
        orangeClimberButton.position = CGPoint(x: -size.width * 0.267, y: 0)
        orangeClimberButton.name = "orangeclimber"
        horizontalMenu.addChild(orangeClimberButton)
        addButtonSprites(button: orangeClimberButton, isUnlocked: climbers.contains(Sprites.Orange),
                         spriteName: "orangeclimber", price: "100")
        
        purpleClimberButton.position = CGPoint.zero
        purpleClimberButton.name = "purpleclimber"
        horizontalMenu.addChild(purpleClimberButton)
        addButtonSprites(button: purpleClimberButton, isUnlocked: climbers.contains(Sprites.Purple),
                         spriteName: "purpleclimber", price: "100")
        
        yellowClimberButton.position = CGPoint(x: size.width * 0.267, y: 0)
        yellowClimberButton.name = "yellowclimber"
        horizontalMenu.addChild(yellowClimberButton)
        addButtonSprites(button: yellowClimberButton, isUnlocked: climbers.contains(Sprites.Yellow),
                         spriteName: "yellowclimber", price: "100")
        
        cyanClimberButton.position = CGPoint(x: size.width * 0.533, y: 0)
        cyanClimberButton.name = "cyanclimber"
        horizontalMenu.addChild(cyanClimberButton)
        addButtonSprites(button: cyanClimberButton, isUnlocked: climbers.contains(Sprites.Cyan),
                         spriteName: "cyanclimber", price: "100")
        
        magentaClimberButton.position = CGPoint(x: size.width * 0.8, y: 0)
        magentaClimberButton.name = "magentaclimber"
        horizontalMenu.addChild(magentaClimberButton)
        addButtonSprites(button: magentaClimberButton, isUnlocked: climbers.contains(Sprites.Magenta),
                         spriteName: "magentaclimber", price: "100")
        
        brownClimberButton.position = CGPoint(x: size.width * 1.067, y: 0)
        brownClimberButton.name = "brownclimber"
        horizontalMenu.addChild(brownClimberButton)
        addButtonSprites(button: brownClimberButton, isUnlocked: climbers.contains(Sprites.Brown),
                         spriteName: "brownclimber", price: "100")
        
        grayClimberButton.position = CGPoint(x: size.width * 1.333, y: 0)
        grayClimberButton.name = "grayclimber"
        horizontalMenu.addChild(grayClimberButton)
        addButtonSprites(button: grayClimberButton, isUnlocked: climbers.contains(Sprites.Gray),
                         spriteName: "grayclimber", price: "100")
        
        
        // special buttons (sprites yet to be added)
        silverClimberButton.position = CGPoint(x: size.width * 1.6, y: 0)
        silverClimberButton.name = "silverclimber"
        horizontalMenu.addChild(silverClimberButton)
        addButtonSprites(button: silverClimberButton, isUnlocked: climbers.contains(Sprites.Silver),
                         spriteName: "silverclimber", price: "250")
        
        goldClimberButton.position = CGPoint(x: size.width * 1.867, y: 0)
        goldClimberButton.name = "goldclimber"
        horizontalMenu.addChild(goldClimberButton)
        addButtonSprites(button: goldClimberButton, isUnlocked: climbers.contains(Sprites.Gold),
                         spriteName: "goldclimber", price: "500")
        
        rainbowClimberButton.position = CGPoint(x: size.width * 2.133, y: 0)
        rainbowClimberButton.name = "rainbowclimber"
        horizontalMenu.addChild(rainbowClimberButton)
        addButtonSprites(button: rainbowClimberButton, isUnlocked: climbers.contains(Sprites.Rainbow),
                         spriteName: "rainbowclimber", price: "")
        
        // highlight the currently chosen climber
        climberButtons[currentClimberColor]!.texture = SKTexture(imageNamed: "highlightoutline")
    }
    
    // scrolling menu for spikeballs
    func spikeballMenu() {
        
        // set up scrollView
        scrollViewSpikeball = SwiftySKScrollView(frame: CGRect(x: frame.width / 20, y: frame.height * 0.575 - 45,
                                                               width: frame.width - frame.width / 10, height: 90),
                                                 moveableNode: moveableNodeSpikeball, direction: .horizontal)
        
        guard let scrollView = scrollViewSpikeball else { return }
        
        scrollView.contentSize = CGSize(width: 3.7 * size.width, height: 90)
        view?.addSubview(scrollView)
        
        // set scrollView to first page
        scrollView.setContentOffset(CGPoint(x: 2.8 * size.width, y: 0), animated: false)
        
        // highlighting menu for easy positioning of buttons
        let horizontalMenu = SKShapeNode(rectOf: CGSize(width: 1.8 * size.width, height: 0.267 * size.width))
        horizontalMenu.zPosition = -1
        horizontalMenu.position = CGPoint(x: frame.midX - (frame.width * 1.8), y: size.height * 0.425)
        horizontalMenu.strokeColor = .clear
        moveableNodeSpikeball.addChild(horizontalMenu)
        
        
        /// Menu Images ///
        
        let spikeballs = defaults.array(forKey: "spikeballs") as! [Int]
        let currentSpikeballColor = defaults.string(forKey: "spikeball")!
        
        // white spikeball is present by default
        whiteSpikeballButton.position = CGPoint(x: -size.width * 1.333, y: 0)
        whiteSpikeballButton.name = "whitespikeball"
        horizontalMenu.addChild(whiteSpikeballButton)
        
        let whiteSpikeball = SKSpriteNode(imageNamed: "whitespikeball")
        whiteSpikeball.zPosition = -1
        whiteSpikeballButton.addChild(whiteSpikeball)
        
        // all other spikeballs may be locked
        redSpikeballButton.position = CGPoint(x: -size.width * 1.067, y: 0)
        redSpikeballButton.name = "redspikeball"
        horizontalMenu.addChild(redSpikeballButton)
        addButtonSprites(button: redSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Red),
                         spriteName: "redspikeball", price: "100")
        
        blueSpikeballButton.position = CGPoint(x: -size.width * 0.8, y: 0)
        blueSpikeballButton.name = "bluespikeball"
        horizontalMenu.addChild(blueSpikeballButton)
        addButtonSprites(button: blueSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Blue),
                         spriteName: "bluespikeball", price: "100")
        
        greenSpikeballButton.position = CGPoint(x: -size.width * 0.533, y: 0)
        greenSpikeballButton.name = "greenspikeball"
        horizontalMenu.addChild(greenSpikeballButton)
        addButtonSprites(button: greenSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Green),
                         spriteName: "greenspikeball", price: "100")
        
        orangeSpikeballButton.position = CGPoint(x: -size.width * 0.267, y: 0)
        orangeSpikeballButton.name = "orangespikeball"
        horizontalMenu.addChild(orangeSpikeballButton)
        addButtonSprites(button: orangeSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Orange),
                         spriteName: "orangespikeball", price: "100")
        
        purpleSpikeballButton.position = CGPoint.zero
        purpleSpikeballButton.name = "purplespikeball"
        horizontalMenu.addChild(purpleSpikeballButton)
        addButtonSprites(button: purpleSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Purple),
                         spriteName: "purplespikeball", price: "100")
        
        yellowSpikeballButton.position = CGPoint(x: size.width * 0.267, y: 0)
        yellowSpikeballButton.name = "yellowspikeball"
        horizontalMenu.addChild(yellowSpikeballButton)
        addButtonSprites(button: yellowSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Yellow),
                         spriteName: "yellowspikeball", price: "100")
        
        cyanSpikeballButton.position = CGPoint(x: size.width * 0.533, y: 0)
        cyanSpikeballButton.name = "cyanspikeball"
        horizontalMenu.addChild(cyanSpikeballButton)
        addButtonSprites(button: cyanSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Cyan),
                         spriteName: "cyanspikeball", price: "100")
        
        magentaSpikeballButton.position = CGPoint(x: size.width * 0.8, y: 0)
        magentaSpikeballButton.name = "magentaspikeball"
        horizontalMenu.addChild(magentaSpikeballButton)
        addButtonSprites(button: magentaSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Magenta),
                         spriteName: "magentaspikeball", price: "100")
        
        brownSpikeballButton.position = CGPoint(x: size.width * 1.067, y: 0)
        brownSpikeballButton.name = "brownspikeball"
        horizontalMenu.addChild(brownSpikeballButton)
        addButtonSprites(button: brownSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Brown),
                         spriteName: "brownspikeball", price: "100")
        
        graySpikeballButton.position = CGPoint(x: size.width * 1.333, y: 0)
        graySpikeballButton.name = "grayspikeball"
        horizontalMenu.addChild(graySpikeballButton)
        addButtonSprites(button: graySpikeballButton, isUnlocked: spikeballs.contains(Sprites.Gray),
                         spriteName: "grayspikeball", price: "100")
        
        // Special Buttons (sprites yet to be added)
        silverSpikeballButton.position = CGPoint(x: size.width * 1.6, y: 0)
        silverSpikeballButton.name = "silverspikeball"
        horizontalMenu.addChild(silverSpikeballButton)
        addButtonSprites(button: silverSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Silver),
                         spriteName: "silverspikeball", price: "250")
        
        goldSpikeballButton.position = CGPoint(x: size.width * 1.867, y: 0)
        goldSpikeballButton.name = "goldspikeball"
        horizontalMenu.addChild(goldSpikeballButton)
        addButtonSprites(button: goldSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Gold),
                         spriteName: "goldspikeball", price: "500")
        
        rainbowSpikeballButton.position = CGPoint(x: size.width * 2.133, y: 0)
        rainbowSpikeballButton.name = "rainbowspikeball"
        horizontalMenu.addChild(rainbowSpikeballButton)
        addButtonSprites(button: rainbowSpikeballButton, isUnlocked: spikeballs.contains(Sprites.Rainbow),
                         spriteName: "rainbowspikeball", price: "")
        
        // highlight the currently chosen spikeball
        spikeballButtons[currentSpikeballColor]!.texture = SKTexture(imageNamed: "highlightoutline")
    }
    
    // aids in initial display of sprites for shop menu
    func addButtonSprites(button: SKSpriteNode, isUnlocked: Bool, spriteName: String, price: String) {
        var sprite = SKSpriteNode()
        if isUnlocked {
            sprite = SKSpriteNode(imageNamed: spriteName)
        } else {
            sprite = SKSpriteNode(imageNamed: "lock")
            sprite.position.y = 7
            
            let endIndex = spriteName.index(spriteName.startIndex, offsetBy: 7)
            
            // display prices for non-rainbow sprites
            if spriteName[spriteName.startIndex..<endIndex] != "rainbow" {
                
                let miniCoin = SKSpriteNode(imageNamed: "minicoin")
                miniCoin.position = CGPoint(x: -15, y: -25)
                miniCoin.zPosition = -5
                button.addChild(miniCoin)
                
                let priceLabel = SKLabelNode(fontNamed: "Futura")
                priceLabel.text = price
                priceLabel.fontSize = 0.032 * size.width
                priceLabel.position = CGPoint(x: miniCoin.position.x + 20, y: miniCoin.position.y - priceLabel.fontSize * 0.4)
                priceLabel.zPosition = -5
                button.addChild(priceLabel)
                
                // display locked rainbow sprite info
            } else {
                let unlockAll = SKLabelNode(fontNamed: "Futura")
                unlockAll.text = "Unlock All"
                unlockAll.fontSize = 0.032 * size.width
                unlockAll.position = CGPoint(x: 0, y: -25 - unlockAll.fontSize * 0.4)
                unlockAll.zPosition = -5
                button.addChild(unlockAll)
            }
        }
        sprite.zPosition = -1
        button.addChild(sprite)
    }
    
    // performs switch of current sprite images if already unlocked or facilitates unlocking process
    func checkSprite (currentButton: SKSpriteNode, previousButton: SKSpriteNode, price: Int,
                      currentColor: String, previousColor: String, sprites: inout [Int], spriteType: String) {
        
        let currentInt = colorToInt(color: currentColor)
        
        // sprite already unlocked
        if sprites.contains(currentInt) {
            
            // restore previous sprite outline
            previousButton.texture = SKTexture(imageNamed: "\(previousColor)outline")
            
            // set new current sprite and update sprite outline
            defaults.set(currentColor, forKey: spriteType)
            currentButton.texture = SKTexture(imageNamed: "highlightoutline")
            
            // sprite hasn't been unlocked
        } else {
            // invariants: not enough coins, rainbow climber isn't unlocked through purchase
            if currentColor == "rainbow" || defaults.integer(forKey: "coins") < price { return }
            else {
                
                // update players coins after purchase
                defaults.set(defaults.integer(forKey: "coins") - price, forKey: "coins")
                coinLabel.text = String(defaults.integer(forKey: "coins"))
                
                // unlock color for player and set color as current climber
                sprites.append(currentInt)
                defaults.set(sprites, forKey: "\(spriteType)s")
                defaults.set(currentColor, forKey: spriteType)
                
                // restore previous sprite outline
                previousButton.texture = SKTexture(imageNamed: "\(previousColor)outline")
                
                // set current button's color
                currentButton.texture = SKTexture(imageNamed: "highlightoutline")
                
                // remove lock, price, and coin
                currentButton.removeAllChildren()
                
                // add new sprite image
                let newSprite = SKSpriteNode(imageNamed: "\(currentColor)\(spriteType)")
                newSprite.zPosition = -1
                currentButton.addChild(newSprite)
                
                // unlock rainbow if all others unlocked
                if sprites.count == 13 {
                    
                    // set rainbow as unlocked
                    sprites.append(Sprites.Rainbow)
                    defaults.set(sprites, forKey: "\(spriteType)s")
                    
                    // prepare new sprite
                    let newSprite = SKSpriteNode(imageNamed: "rainbow\(spriteType)")
                    newSprite.zPosition = -1
                    
                    // remove appropriate sprites from button and add new sprite
                    if spriteType == "climber" {
                        rainbowClimberButton.removeAllChildren()
                        rainbowClimberButton.addChild(newSprite)
                    } else {
                        rainbowSpikeballButton.removeAllChildren()
                        rainbowSpikeballButton.addChild(newSprite)
                    }
                }
                
                let totalSprites : [String : [Int]] =
                    ["climber" : defaults.array(forKey: "climbers") as! [Int],
                     "spikeball" : defaults.array(forKey: "spikeballs") as! [Int]]
                
                // update API of new coin amount and new sprite unlock if signed in
                
                if FBSDKAccessToken.current() != nil {
                    API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: totalSprites, ads: nil, extra_lives: nil, completion_handler: {
                        
                        (response, _) in
                        
                        if response != URLResponse.Success {
                            
                            defaults.set(true, forKey: "unsaved")
                            //print("purchase not saved. unsaved bool triggered")
                            return
                        }
                        //print("sprites and coins updated")
                    })
                }
            }
        }
    }
    
    // adds purchase information for shop scene
    func addPurchaseSprites (button: SKShapeNode, coins: String, cost: String) {
        
        let coinImage = SKSpriteNode(imageNamed: "smallcoin")
        coinImage.position = CGPoint(x: 0.08 * size.width, y: 0.0225 * size.height + coinImage.size.height / 2)
        button.addChild(coinImage)
        
        let coinAmount = SKLabelNode(fontNamed: "Futura")
        coinAmount.text = "+\(coins)"
        coinAmount.fontColor = .yellow
        coinAmount.fontSize = 0.0587 * size.width
        coinAmount.position = CGPoint(x: -0.04 * size.width, y: 0.0225 * size.height)
        button.addChild(coinAmount)
        
        let price = SKLabelNode(fontNamed: "Futura")
        price.text = "$\(cost)"
        price.fontSize = 0.0853 * size.width
        price.position = CGPoint(x: 0, y: -0.05 * size.height)
        button.addChild(price)
        
    }
    
    func colorToInt (color: String) -> Int {
        if color == "white" {
            return Sprites.white
        } else if color == "red" {
            return Sprites.Red
        } else if color == "blue" {
            return Sprites.Blue
        } else if color == "green" {
            return Sprites.Green
        } else if color == "orange" {
            return Sprites.Orange
        } else if color == "purple" {
            return Sprites.Purple
        } else if color == "yellow" {
            return Sprites.Yellow
        } else if color == "cyan" {
            return Sprites.Cyan
        } else if color == "magenta" {
            return Sprites.Magenta
        } else if color == "brown" {
            return Sprites.Brown
        } else if color == "gray" {
            return Sprites.Gray
        } else if color == "silver" {
            return Sprites.Silver
        } else if color == "gold" {
            return Sprites.Gold
        } else {
            return Sprites.Rainbow
        }
    }
    
    func startSpinners() {
        
        lifeSpinner.center = CGPoint(x: livesButton.position.x, y: size.height - livesButton.position.y)
        lifeSpinner.hidesWhenStopped = true
        lifeSpinner.startAnimating()
        viewDelegate.view.addSubview(lifeSpinner)
        
        smallSpinner.center = CGPoint(x: firstPurchaseButton.position.x, y: size.height - firstPurchaseButton.position.y)
        smallSpinner.hidesWhenStopped = true
        smallSpinner.startAnimating()
        viewDelegate.view.addSubview(smallSpinner)
        
        mediumSpinner.center = CGPoint(x: secondPurchaseButton.position.x, y: size.height - secondPurchaseButton.position.y)
        mediumSpinner.hidesWhenStopped = true
        mediumSpinner.startAnimating()
        viewDelegate.view.addSubview(mediumSpinner)
        
        largeSpinner.center = CGPoint(x: thirdPurchaseButton.position.x, y: size.height - thirdPurchaseButton.position.y)
        largeSpinner.hidesWhenStopped = true
        largeSpinner.startAnimating()
        viewDelegate.view.addSubview(largeSpinner)
        
        if defaults.bool(forKey: "ads") {
            adSpinner.center = CGPoint(x: noAdsButton.position.x, y: size.height - noAdsButton.position.y)
            adSpinner.hidesWhenStopped = true
            adSpinner.startAnimating()
            viewDelegate.view.addSubview(adSpinner)
        }
    }
    
    func stopSpinners() {
        
        lifeSpinner.stopAnimating()
        smallSpinner.stopAnimating()
        mediumSpinner.stopAnimating()
        largeSpinner.stopAnimating()
        adSpinner.stopAnimating()
    }
    
    func displayStore() {
        
        // add extra life info
        let livesLabel = SKLabelNode(fontNamed: "Futura")
        livesLabel.text = "Extra Life"
        livesLabel.fontSize = 0.05 * self.size.width
        livesLabel.verticalAlignmentMode = .center
        livesLabel.position = CGPoint(x: 0, y: self.size.height / 30)
        self.livesButton.addChild(livesLabel)
        
        let livesHeart = SKSpriteNode(imageNamed: "mediumheart")
        livesHeart.position = CGPoint(x: self.size.width / 8, y: -self.size.height / 35)
        self.livesButton.addChild(livesHeart)
        
        let livesPrice = SKLabelNode(fontNamed: "Futura")
        livesPrice.text = "$0.99"
        livesPrice.fontColor = .red
        livesPrice.fontSize = 0.0853 * self.size.width
        livesPrice.verticalAlignmentMode = .center
        livesPrice.position = CGPoint(x: -self.size.width / 14, y: -self.size.height / 35)
        self.livesButton.addChild(livesPrice)
        
        // add coin purchase info
        self.addPurchaseSprites(button: self.firstPurchaseButton, coins: "100", cost: "0.99")
        self.addPurchaseSprites(button: self.secondPurchaseButton, coins: "275", cost: "1.99")
        self.addPurchaseSprites(button: self.thirdPurchaseButton, coins: "850", cost: "4.99")
        
        // add ads info
        if defaults.bool(forKey: "ads") {
            let no = SKLabelNode(fontNamed: "Futura")
            no.text = "No"
            no.fontSize = 0.0533 * size.width
            no.fontColor = .red
            no.position = CGPoint(x: noAdsButton.position.x, y: noAdsButton.position.y)
            let ads = SKLabelNode(fontNamed: "Futura")
            ads.text = "Ads"
            ads.fontSize = 0.0533 * size.width
            ads.fontColor = .red
            ads.position = CGPoint(x: noAdsButton.position.x, y: noAdsButton.position.y - ads.fontSize)
            addChild(no)
            addChild(ads)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        heartLabel.text = String(defaults.integer(forKey: "extralives"))
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
}

