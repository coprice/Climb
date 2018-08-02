//
//  ExtraLifeMenu.swift
//  Climb
//
//  Created by Collin Price on 6/7/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import SpriteKit

class ExtraLifeMenu: SKScene {
    
    let xButton = SKSpriteNode(imageNamed: "xbutton")
    let checkmark = SKSpriteNode(imageNamed: "checkmark")
    var numPlatforms = 0
    
    init(size: CGSize, score: Int) {
        
        super.init(size: size)
        
        backgroundColor = .black
        numPlatforms = score
        
        let scoreLabel = SKLabelNode(fontNamed: "Futura")
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 0.064 * size.width
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.95)
        addChild(scoreLabel)
        
        let coin = SKSpriteNode(imageNamed: "smallcoin")
        coin.position = CGPoint(x: coin.size.width, y: size.height * 0.95 + coin.size.height / 2)
        addChild(coin)
        
        let coinLabel = SKLabelNode(fontNamed: "Futura")
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        coinLabel.fontSize = 0.064 * size.width
        coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        coinLabel.position = CGPoint(x: coin.size.width * 1.75, y: size.height * 0.95)
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
        
        let heart = SKSpriteNode(imageNamed: "heart")
        heart.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        addChild(heart)
        
        let extraLife = SKLabelNode(fontNamed: "Times")
        extraLife.text = "Extra Life?"
        extraLife.fontSize = 40
        extraLife.position.y = heart.frame.size.height * 0.7
        heart.addChild(extraLife)
        
        let numHearts = SKLabelNode(fontNamed: "Futura")
        numHearts.text = String(defaults.integer(forKey: "extralives"))
        numHearts.fontSize = 40
        numHearts.verticalAlignmentMode = .center
        numHearts.position = heart.position
        numHearts.zPosition = 1
        addChild(numHearts)
        
        xButton.position = CGPoint(x: heart.position.x - size.width * 0.13,
                                   y: heart.position.y - heart.frame.size.height * 0.7)
        addChild(xButton)
        
        checkmark.position = CGPoint(x: heart.position.x + size.width * 0.13, y: xButton.position.y)
        addChild(checkmark)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if xButton.contains(touchLocation) {
            self.removeAllChildren()
            let gameOverScene = GameOverScene(size: self.size, score: numPlatforms)
            self.view?.presentScene(gameOverScene)
            
        } else if checkmark.contains(touchLocation) {
            
            // take away an extra life
            defaults.set(defaults.integer(forKey: "extralives") - 1, forKey: "extralives")
            
            // set the game up to restart
            self.removeAllChildren()
            let resumeGame = GameScene(size: self.size, initNumPlatforms: numPlatforms)
            self.view?.presentScene(resumeGame)
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

