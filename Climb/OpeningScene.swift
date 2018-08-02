//
//  OpeningScene.swift
//  Climb
//
//  Created by Collin Price on 6/14/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import StoreKit
import SpriteKit
import FBSDKCoreKit

class OpeningScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        backgroundColor = .black
        
        let appIcon = SKSpriteNode(imageNamed: "climbicon")
        appIcon.position = view.center
        addChild(appIcon)
        
        if FBSDKAccessToken.current() != nil || defaults.bool(forKey: "guest") {
            run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(loadMainMenu)]))
        } else {
            run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(loadLogin)]))
        }
        
    }
    
    func loadMainMenu() {
        
        let mainMenu = MenuScene(size: self.size)
        self.view?.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 1))
    }
    
    func loadLogin() {
        
        let Login = LoginScene(size: size)
        view?.presentScene(Login, transition: SKTransition.fade(with: .gray, duration: 1))
        
    }
    
}

