//
//  GameViewController.swift
//  Climb
//
//  Created by Collin Price on 5/12/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import StoreKit
import SpriteKit
import FBSDKCoreKit
import GoogleMobileAds

let defaults = UserDefaults.standard
let videoSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
var viewDelegate : UIViewController!
var videoActive = false
var storeLoading = true
var isGamePaused = false

class GameViewController: UIViewController, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate {
    
    private var interstitial: GADInterstitial!
    private var skView: SKView!
    
    override func viewDidLoad() {
        
        print("Running Climb in " + API.environment + ".")
        viewDelegate = self
        
        // bool for sound effects toggle
        if !defaults.objectIsForced(forKey: "sound") {
            defaults.register(defaults: ["sound" : true])
        }
        
        if !defaults.objectIsForced(forKey: "music") {
            defaults.register(defaults: ["music" : true])
        }
        
        // string for current climber sprite
        if !defaults.objectIsForced(forKey: "climber") {
            defaults.register(defaults: ["climber" : "white"])
        }
        
        // string for current spikeball sprite
        if !defaults.objectIsForced(forKey: "spikeball") {
            defaults.register(defaults: ["spikeball" : "white"])
        }
        
        // amount of coins
        if !defaults.objectIsForced(forKey: "coins") {
            defaults.register(defaults: ["coins" : 0])
        }
        
        // dictionary for unlocked climber sprites
        if !defaults.objectIsForced(forKey: "climbers") {
            defaults.register(defaults: ["climbers" : [0]])
        }
        
        // dictionary for unlocked spikeball sprites
        if !defaults.objectIsForced(forKey: "spikeballs") {
            defaults.register(defaults: ["spikeballs" : [0]])
        }
        
        // amount of extra lives
        if !defaults.objectIsForced(forKey: "extralives") {
            defaults.register(defaults: ["extralives" : 0])
        }
        
        // ads status
        if !defaults.objectIsForced(forKey: "ads") {
            defaults.register(defaults: ["ads" : true])
        }
        
        if !defaults.objectIsForced(forKey: "scores") {
            defaults.register(defaults: ["scores" : []])
        }
        
        if !defaults.objectIsForced(forKey: "firstname") {
            defaults.register(defaults: ["firstname" : ""])
        }
        
        if !defaults.objectIsForced(forKey: "lastname") {
            defaults.register(defaults: ["lastname" : ""])
        }
        
        // cached scores list
        if !defaults.objectIsForced(forKey: "cachedscores") {
            defaults.register(defaults: ["cachedscores" : []])
        }
        
        // unsaved data status
        if !defaults.objectIsForced(forKey: "unsaved") {
            defaults.register(defaults: ["unsaved" : false])
        }
        
        if !defaults.objectIsForced(forKey: "guest") {
            defaults.register(defaults: ["guest" : false])
        }
        
        // load products
        ClimbProducts.store.requestProducts{success, products in
            if success {
                ClimbProducts.store.products = products!
            }
            storeLoading = false
        }
        
        super.viewDidLoad()
        
        if defaults.bool(forKey: "ads") {
            refreshInterstitial()
        }
        
        skView = view as! SKView
        let openingScene = OpeningScene(size: view.bounds.size)
        skView.presentScene(openingScene)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startVideoAd), name: NSNotification.Name(rawValue: "showVideoRewardAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayInterstitial), name: NSNotification.Name(rawValue: "displayInterstitialAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshInterstitial), name: NSNotification.Name(rawValue: "refreshInterstitialAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadShop), name: NSNotification.Name(rawValue: "reloadShop"), object: nil)
        
    }
    
    @objc func reloadShop() {
        for view in view.subviews {
            view.isUserInteractionEnabled = false
            view.removeFromSuperview()
        }
        let shop = ShopScene(size: view.bounds.size)
        skView.presentScene(shop)
    }
    
    // Interstitial Ad Helpers
    
    func createAndLoadInterstitial() -> GADInterstitial {
        //        // testing
        //        let Interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        // official
        let Interstitial = GADInterstitial(adUnitID: "ca-app-pub-3178880973767766/9418624334")
        Interstitial.delegate = self
        Interstitial.load(GADRequest())
        return Interstitial
    }
    
    @objc func displayInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            refreshInterstitial()
        }
    }
    
    @objc func refreshInterstitial() {
        interstitial = createAndLoadInterstitial()
    }
    
    // Video ad helpers
    
    @objc func startVideoAd() {
        
        startVideoSpinner()
        videoActive = true
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        //        // testing
        //        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
        //                                                    withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        // official
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-3178880973767766/3511691536")
    }
    
    func startVideoSpinner() {
        videoSpinner.center = CGPoint(x: self.view.frame.width / 2, y: view.frame.height * 0.05)
        videoSpinner.hidesWhenStopped = true
        videoSpinner.startAnimating()
        view.addSubview(videoSpinner)
    }
    
    func stopVideoSpinner() {
        videoSpinner.stopAnimating()
    }
    
    // MARK: GADInterstitialDelegate implementation
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
        // start loading another interstitial
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    // MARK: GADRewardBasedVideoAdDelegate implementation
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: \(error.localizedDescription)")
        stopVideoSpinner()
        videoActive = false
        Cache.createAlert(title: "Video Failed to Load", message: "Check your internet connection", view: self)
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        stopVideoSpinner()
        rewardBasedVideoAd.present(fromRootViewController: self)
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened r/Users/collinprice/Documents/Projects/Climb/Climb/ExtraLifeMenu.swifteward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        stopVideoSpinner()
        videoActive = false
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        videoActive = false
        defaults.set(defaults.integer(forKey: "coins") + 10, forKey: "coins")
        
        if FBSDKAccessToken.current() != nil {
            API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: nil, ads: nil, extra_lives: nil, completion_handler: {
                
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
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
}

