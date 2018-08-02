//
//  HighScores.swift
//  Climb
//
//  Created by Collin Price on 5/17/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//
//  Scrollable menu adapted from https://github.com/crashoverride777/SwiftySKScrollView
//

import SpriteKit
import FBSDKCoreKit

class Leaderboards: SKScene {
    
    var homeButton : SKShapeNode!
    var shopButton : SKShapeNode!
    var shareButton : SKShapeNode!
    var userButton : SKShapeNode!
    var friendButton : SKShapeNode!
    var globalButton : SKShapeNode!
    let moveableNode = SKNode()
    let bestScore = SKLabelNode(fontNamed: "Futura")
    
    var scoreState = ScoreStates.User
    var rankLoading = false
    var rankPrinted = false
    var friendLoading = false
    var globalLoading = false
    
    var friendScores : [(String, Int)]? = nil
    var globalScores : [(String, Int)]? = nil
    
    let scoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let rankSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    weak var scrollView : SwiftySKScrollView?
    
    override func didMove(to view: SKView) {
        
        homeButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        shopButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        shareButton = SKShapeNode(circleOfRadius: 0.1 * size.width)
        userButton = SKShapeNode(rectOf: CGSize(width: 0.27 * size.width, height: 0.05 * size.height))
        friendButton = SKShapeNode(rectOf: CGSize(width: 0.27 * size.width, height: 0.05 * size.height))
        globalButton = SKShapeNode(rectOf: CGSize(width: 0.27 * size.width, height: 0.05 * size.height))
        
        backgroundColor = .black
        
        // coin image
        let coin = SKSpriteNode(imageNamed: "smallcoin")
        coin.position = CGPoint(x: coin.size.width, y: size.height * 0.95 + coin.size.height / 2)
        coin.zPosition = 10
        addChild(coin)
        
        // amount of coins user has
        let coinLabel = SKLabelNode(fontNamed: "Futura")
        coinLabel.text = String(defaults.integer(forKey: "coins"))
        coinLabel.fontSize = 0.064 * size.width
        coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        coinLabel.position = CGPoint(x: coin.size.width * 1.75, y: size.height * 0.95)
        coinLabel.zPosition = 10
        addChild(coinLabel)
        
        // display leaderboard label
        let title = SKLabelNode(fontNamed: "Futura")
        title.text = "Leaderboards"
        title.fontSize = 0.128 * size.width
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        title.zPosition = 10
        addChild(title)
        
        // main menu button
        let homeImage = SKSpriteNode(imageNamed: "home")
        homeImage.position = CGPoint(x: size.width * 0.25, y: size.height * 0.1)
        homeImage.zPosition = 10
        homeButton.position = homeImage.position
        homeButton.zPosition = 10
        addChild(homeImage)
        addChild(homeButton)
        
        // shop menu button
        let shopLabel = SKSpriteNode(imageNamed: "shop")
        shopLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        shopLabel.zPosition = 10
        shopButton.position = shopLabel.position
        shopButton.zPosition = 10
        shopButton.strokeColor = .yellow
        addChild(shopLabel)
        addChild(shopButton)
        
        // share button
        shareButton.strokeColor = .red
        shareButton.position = CGPoint(x: size.width * 0.75, y: size.height * 0.1)
        shareButton.zPosition = 10
        let shareLabel = SKLabelNode(fontNamed: "Futura")
        shareLabel.text = "Share"
        shareLabel.fontSize = 0.064 * size.width
        shareLabel.fontColor = .red
        shareLabel.position = CGPoint(x: shareButton.position.x, y: shareButton.position.y - shareLabel.fontSize * 0.4)
        shareLabel.zPosition = 10
        addChild(shareLabel)
        addChild(shareButton)
        
        // toggle Buttons
        userButton.position = CGPoint(x: size.width / 2 - 0.27 * size.width, y: size.height * 0.8)
        userButton.zPosition = 10
        userButton.fillColor = .darkGray
        userButton.strokeColor = .darkGray
        let userTitle = SKLabelNode(fontNamed: "Futura")
        userTitle.text = "User"
        userTitle.fontSize = 0.064 * size.width
        userTitle.position = CGPoint(x: userButton.position.x, y: userButton.position.y - userTitle.fontSize * 0.4)
        userTitle.zPosition = 10
        addChild(userButton)
        addChild(userTitle)
        
        friendButton.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        friendButton.zPosition = 10
        friendButton.strokeColor = .darkGray
        let friendTitle = SKLabelNode(fontNamed: "Futura")
        friendTitle.text = "Friends"
        friendTitle.fontSize = 0.064 * size.width
        friendTitle.position = CGPoint(x: friendButton.position.x, y: friendButton.position.y - friendTitle.fontSize * 0.4)
        friendTitle.zPosition = 10
        addChild(friendButton)
        addChild(friendTitle)
        
        globalButton.position = CGPoint(x: size.width / 2 + 0.27 * size.width, y: size.height * 0.8)
        globalButton.zPosition = 10
        globalButton.strokeColor = .darkGray
        let globalTitle = SKLabelNode(fontNamed: "Futura")
        globalTitle.text = "Global"
        globalTitle.fontSize = 0.064 * size.width
        globalTitle.position = CGPoint(x: globalButton.position.x, y: globalButton.position.y - globalTitle.fontSize * 0.4)
        globalTitle.zPosition = 10
        addChild(globalButton)
        addChild(globalTitle)
        
        let localScores = defaults.array(forKey: "scores") as! [Int]
        if localScores != [] {
            bestScore.text = "Best: \(localScores.first!)"
            bestScore.fontSize = 0.064 * size.width
            bestScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            bestScore.position = CGPoint(x: size.width * 0.98, y: size.height * 0.95)
            bestScore.zPosition = 10
            addChild(bestScore)
        }
        
        // background for scrollable menu
        let verticalBackground = SKShapeNode(rectOf: CGSize(width: 0.8 * size.width, height: 0.56 * size.height))
        verticalBackground.position = CGPoint(x: size.width / 2, y: 0.46 * size.height)
        verticalBackground.zPosition = -10
        verticalBackground.fillColor = .darkGray
        verticalBackground.strokeColor = .clear
        addChild(verticalBackground)
        
        let topViewBlocker = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        topViewBlocker.position = CGPoint(x: size.width / 2, y: 1.24 * size.height)
        topViewBlocker.zPosition = 5
        topViewBlocker.fillColor = .black
        topViewBlocker.strokeColor = .clear
        addChild(topViewBlocker)
        
        let bottomViewBlocker = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bottomViewBlocker.position = CGPoint(x: size.width / 2, y: -0.32 * size.height)
        bottomViewBlocker.zPosition = 5
        bottomViewBlocker.fillColor = .black
        bottomViewBlocker.strokeColor = .clear
        addChild(bottomViewBlocker)
        
        scoreSpinner.center = CGPoint(x: size.width / 2, y: size.height * 0.54 - scoreSpinner.frame.height / 2)
        scoreSpinner.hidesWhenStopped = true
        viewDelegate.view.addSubview(scoreSpinner)
        
        userscores()
        
        // add scrollable menu and rank
        addChild(moveableNode)
        
        if FBSDKAccessToken.current() != nil {
            
            // save any cached scores silently
            Cache.save_cache_silent(completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if homeButton.contains(touchLocation) {
            
            SwiftySKScrollView.isDisabled = true
            scrollView?.showsVerticalScrollIndicator = false
            stopScoreSpinner()
            stopRankSpinner()
            self.removeAllChildren()
            
            let mainMenu = MenuScene(size: self.size)
            self.view?.presentScene(mainMenu)
            
        } else if shopButton.contains(touchLocation) {
            
            SwiftySKScrollView.isDisabled = true
            scrollView?.showsVerticalScrollIndicator = false
            stopScoreSpinner()
            stopRankSpinner()
            self.removeAllChildren()
            
            let shopStart = ShopScene(size: self.size)
            self.view?.presentScene(shopStart)
            
        } else if shareButton.contains(touchLocation) {
            
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
            
        } else if userButton.contains(touchLocation) {
            
            var fromButton : SKShapeNode
            
            if scoreState != ScoreStates.User {
                if scoreState == ScoreStates.Friends {
                    fromButton = friendButton
                } else {
                    fromButton = globalButton
                }
                changeMenu(fromButton: fromButton, toState: ScoreStates.User, toButton: userButton)
                moveableNode.removeAllChildren()
                friendLoading = false
                globalLoading = false
                userscores()
                
            }
            
        } else if friendButton.contains(touchLocation) {
            
            if FBSDKAccessToken.current() == nil {
                Cache.createAlert(title: "Sign In", message: "Connect to Facebook to See Your Friends' Scores",
                                  view: viewDelegate)
                return
                
            } else if scoreState != ScoreStates.Friends {
                
                var fromButton : SKShapeNode
                if scoreState == ScoreStates.User {
                    fromButton = userButton
                } else {
                    fromButton = globalButton
                }
                
                changeMenu(fromButton: fromButton, toState: ScoreStates.Friends, toButton: friendButton)
                moveableNode.removeAllChildren()
                globalLoading = false
                
                if !friendLoading {
                    friendscores(fb_id: FBSDKAccessToken.current().userID)
                }
                
            } else {
                
                if friendLoading { return } else {
                    friendscores(fb_id: FBSDKAccessToken.current().userID)
                }
            }
            
        } else if globalButton.contains(touchLocation) {
            
            if FBSDKAccessToken.current() == nil {
                
                if scoreState != ScoreStates.Global {
                    Cache.createAlert(title: "Sign In", message: "Connect to Facebook to Compete Globally",
                                      view: viewDelegate)
                }
                
            } else if !rankPrinted && !rankLoading {
                
                startRankSpinner()
                userrank(fb_id: FBSDKAccessToken.current().userID)
            }
            
            if scoreState != ScoreStates.Global {
                
                var fromButton : SKShapeNode
                if scoreState == ScoreStates.User {
                    fromButton = userButton
                } else {
                    fromButton = friendButton
                }
                
                changeMenu(fromButton: fromButton, toState: ScoreStates.Global, toButton: globalButton)
                moveableNode.removeAllChildren()
                
                if !globalLoading {
                    globalscores()
                    
                }
                
            } else {
                if globalLoading { return } else {
                    globalscores()
                }
            }
        }
    }
    
    
    /* HELPERS */
    
    // handles toggling between user, friend, and global high scores
    func changeMenu (fromButton: SKShapeNode, toState: ScoreStates, toButton: SKShapeNode) {
        
        stopScoreSpinner()
        
        // reset scrollView
        scrollView?.setContentOffset(CGPoint.zero, animated: false)
        scrollView?.removeFromSuperview()
        scrollView?.isUserInteractionEnabled = false
        scrollView = nil
        
        // update score state and button colors
        scoreState = toState
        fromButton.fillColor = .clear
        toButton.fillColor = .darkGray
        
    }
    
    // displays scrollable menu, with a max number of lines
    func DisplayScores(scores: [(String, Int)], max: Int) {
        
        if scores.count == 0 { return }
        
        var numLines = scores.count
        if numLines > max {
            numLines = max
        }
        
        // set up scrollView
        scrollView = SwiftySKScrollView(frame: CGRect(x: 0, y: 0, width: size.width * 0.8, height: 0.56 * size.height), moveableNode: moveableNode, direction: .vertical)
        guard let scrollView = scrollView else { return }
        scrollView.center = CGPoint(x: frame.midX, y: size.height - 0.46 * size.height)
        scrollView.contentSize = CGSize(width: frame.midX, height: 0.056 * size.height * CGFloat(numLines))
        view?.addSubview(scrollView)
        
        // highlighting menu for easy positioning of labels
        let verticalMenu = SKSpriteNode(color: SKColor.clear, size: CGSize(width: size.width, height: size.height))
        verticalMenu.position = CGPoint(x: size.width / 2, y: 0.46 * size.height)
        moveableNode.addChild(verticalMenu)
        
        // add places
        for index in 0..<numLines {
            
            let (inputName, score) = scores[index]
            
            // remove extra names
            var name = inputName
            let split = name.split(separator: " ")
            name = split[0] + " " + split[split.count - 1]
            
            // only allow up to 15 characters for name
            if name.count > 15 {
                let endIndex = name.index(name.startIndex, offsetBy: 15)
                name = String(name[name.startIndex..<endIndex])
            }
            
            let label = SKLabelNode(fontNamed: "Futura")
            label.text = "\(index + 1)."
            label.fontSize = 0.064 * size.width
            label.position = CGPoint(x: -size.width * 0.375, y: 0.25 * size.height - 0.056 * size.height * CGFloat(index))
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            
            let nameLabel = SKLabelNode(fontNamed: "Futura")
            nameLabel.text = name
            nameLabel.fontSize = 0.05 * size.width
            nameLabel.position = CGPoint(x: -size.width * 0.2, y: label.position.y)
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.verticalAlignmentMode = .center
            
            let scoreLabel = SKLabelNode(fontNamed: "Futura")
            scoreLabel.text = String(score)
            scoreLabel.fontSize = 0.064 * size.width
            scoreLabel.position = CGPoint(x: size.width * 0.375, y: label.position.y)
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.verticalAlignmentMode = .center
            
            verticalMenu.addChild(label)
            verticalMenu.addChild(nameLabel)
            verticalMenu.addChild(scoreLabel)
        }
    }
    
    // prints out user's global rank
    func userrank(fb_id: String) {
        
        startRankSpinner()
        rankLoading = true
        bestScore.removeFromParent()
        
        API.get_rank(fb_id: fb_id, completion_handler: {
            (response, data) in
            
            self.stopRankSpinner()
            
            if response == URLResponse.Error {
                
                Cache.createAlert(title: "Unknown Error", message: "Couldn't get user rank",
                                  view: viewDelegate)
                self.rankLoading = false
                self.addChild(self.bestScore)
                return
                
            } else if response == URLResponse.NotConnected {
                
                Cache.createAlert(title: "No Internet Connection", message: "Please connect to the Internet",
                                  view: viewDelegate)
                self.rankLoading = false
                self.addChild(self.bestScore)
                return
                
            } else if response == URLResponse.ServerDown {
                
                Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                  view: viewDelegate)
                self.rankLoading = false
                self.addChild(self.bestScore)
                return
            }
            
            if let place = data {
                
                // if user isn't unranked
                if place != 0 {
                    
                    // initiate player rank positioning and info
                    let rank = SKLabelNode(fontNamed: "Futura")
                    rank.text = "Rank: " + String(place)
                    rank.fontSize = 0.064 * self.size.width
                    rank.horizontalAlignmentMode = .right
                    rank.position = CGPoint(x: self.size.width * 0.98, y: self.size.height * 0.95)
                    rank.zPosition = 10
                    self.addChild(rank)
                    self.rankPrinted = true
                    self.rankLoading = false
                }
            }
            
        })
    }
    
    // obtains a user's top scores for displayal
    func userscores() {
        
        stopScoreSpinner()
        
        // create (name, score) list for user
        var userScores : [(String, Int)]
        if FBSDKAccessToken.current() != nil {
            
            let last_name : String = defaults.string(forKey: "lastname")!
            let name = defaults.string(forKey: "firstname")! + " " + String(last_name[last_name.startIndex]) + "."
            userScores = (defaults.array(forKey: "scores") as! [Int]).map({ (elem) in (name, elem)})
            
        } else {
            
            userScores = (defaults.array(forKey: "scores") as! [Int]).map({ (elem) in ("Guest", elem)})
        }
        
        DisplayScores(scores: userScores, max: 25)
    }
    
    // obtains a user's friends scores for displayal
    func friendscores (fb_id: String) {
        
        if let scores = friendScores {
            self.DisplayScores(scores: scores, max: 50)
            return
        }
        
        startScoreSpinner()
        friendLoading = true
        
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
            
            // couldn't connect
            if error != nil {
                
                Cache.createAlert(title: "No Internet Connection", message: "Connect to the Internet",
                                  view: viewDelegate)
                self.stopScoreSpinner()
                self.friendLoading = false
                return
                
                // data received
            } else {
                
                // construct a list of friends' ids, and add user's id
                let result = result as! [String:Any]
                let friendlist = result["data"] as! [[String : String]]
                var idlist = friendlist.map({ (elem) in elem["id"]! })
                idlist.append(FBSDKAccessToken.current().userID)
                
                // get all scores
                API.get_friends_scores(friend_ids: idlist, completion_handler: {
                    (response, data) in
                    
                    if response == URLResponse.Error {
                        
                        Cache.createAlert(title: "Unknown Error", message: "Couldn't get friends' scores",
                                          view: viewDelegate)
                        self.stopScoreSpinner()
                        self.friendLoading = false
                        return
                        
                    } else if response == URLResponse.NotConnected {
                        
                        self.stopScoreSpinner()
                        Cache.createAlert(title: "No Internet Connection", message: "Connect to the Internet",
                                          view: viewDelegate)
                        self.friendLoading = false
                        return
                        
                    } else if response == URLResponse.ServerDown {
                        
                        self.stopScoreSpinner()
                        Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down.",
                                          view: viewDelegate)
                        self.friendLoading = false
                        return
                    }
                    
                    self.friendLoading = false
                    let scores_with_name: [(String, Int)] = data!.map({
                        (elem) in
                        
                        let last_name = elem["last_name"] as! String
                        let name = (elem["first_name"] as! String) + " " + String(last_name[last_name.startIndex]) + "."
                        return (name, elem["score"] as! Int)
                    })
                    
                    if self.scoreState == ScoreStates.Friends {
                        self.stopScoreSpinner()
                        self.friendScores = scores_with_name
                        self.DisplayScores(scores: scores_with_name, max: 50)
                    }
                })
            }
        })
    }
    
    // obtains the top 100 global scores for displayal, and displays player rank
    func globalscores() {
        
        if let scores = globalScores {
            self.DisplayScores(scores: scores, max: 100)
            return
        }
        
        startScoreSpinner()
        globalLoading = true
        
        API.get_global_scores(completion_handler: {
            (response, data) in
            
            if response == URLResponse.NotConnected {
                
                self.stopScoreSpinner()
                Cache.createAlert(title: "No Internet Connection", message: "Connect to the Internet",
                                  view: viewDelegate)
                self.globalLoading = false
                return
                
            } else if response == URLResponse.Error {
                
                Cache.createAlert(title: "Unknown Error", message: "Couldn't get global scores",
                                  view: viewDelegate)
                self.stopScoreSpinner()
                self.globalLoading = false
                return
                
            } else if response == URLResponse.ServerDown {
                
                Cache.createAlert(title: "Servers Down", message: "Sorry, our servers are currently down",
                                  view: viewDelegate)
                self.stopScoreSpinner()
                self.globalLoading = false
                return
            }
            
            self.globalLoading = false
            let scores_with_name: [(String, Int)] = data!.map({
                (elem) in
                
                let last_name = elem["last_name"] as! String
                let name = (elem["first_name"] as! String) + " " + String(last_name[last_name.startIndex]) + "."
                return (name, elem["score"] as! Int)
            })
            
            // display scores if still in global state
            if self.scoreState == ScoreStates.Global {
                self.stopScoreSpinner()
                self.globalScores = scores_with_name
                self.DisplayScores(scores: scores_with_name, max: 100)
            }
        })
        
    }
    
    func startRankSpinner() {
        
        rankSpinner.center = CGPoint(x: size.width * 0.95, y: size.height / 20 - rankSpinner.frame.size.height / 2)
        rankSpinner.hidesWhenStopped = true
        rankSpinner.startAnimating()
        viewDelegate.view.addSubview(rankSpinner)
    }
    
    func stopRankSpinner() {
        
        rankSpinner.stopAnimating()
    }
    
    func startScoreSpinner() {
        
        scoreSpinner.startAnimating()
    }
    
    func stopScoreSpinner() {
        
        scoreSpinner.stopAnimating()
    }
}

enum ScoreStates {
    case User
    case Friends
    case Global
}

