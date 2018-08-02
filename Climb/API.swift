//
//  Authentication.swift
//  Climb
//
//  Created by Collin and Brandon Price on 1/29/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class API {
    
    // ROOT URL
    static let environment = ProcessInfo().environment["ENV"] == nil ? "production" : ProcessInfo().environment["ENV"]!
    static let rootURLString : String = environment != "development" ? "https://climb-backend-" + environment + ".herokuapp.com/app/" : "http://127.0.0.1:8000/app/"
    
    /* Method for creating a new user
     * returns Success, Error
     */
    
    class func create_user (first_name: String, last_name: String, fb_id: String, completion_handler: @escaping (URLResponse, [String : Any]?) -> Void) {
        
        let json = ["fb_id" : fb_id, "first_name" : first_name, "last_name" : last_name]
        
        // Perform request.
        API.perform_request(request_type: "POST", url_path: "create_user", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            let result = data["result"] as! [String : Any]
            completion_handler(URLResponse.Success, result["user"] as? [String : Any])
            
        })
    }
    
    /* Method for getting all of a user's unlock info
     * returns Success, Error
     */
    
    class func get_user_info (fb_id: String, completion_handler: @escaping (URLResponse, [String : Any]?) -> Void) {
        
        let json = ["fb_id" : fb_id]
        
        API.perform_request(request_type: "POST", url_path: "get_user_info", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            let result = data["result"] as! [String : Any]
            completion_handler(URLResponse.Success, result["user"] as? [String : Any])
            
        })
    }
    
    /* Method for updating a user's info
     * returns Success, Error
     */
    class func save_user_info (fb_id: String, coins: Int?, sprites: [String:[Int]]?, ads: Bool?, extra_lives: Int?,
                               completion_handler: @escaping (URLResponse, [String : Any]?) -> Void) {
        
        // create json with only non-optional values
        var json = ["fb_id" : fb_id] as [String : Any]
        
        if coins != nil {
            json["coins"] = coins!
        }
        
        if sprites != nil {
            json["sprites"] = sprites!
        }
        
        if ads != nil {
            json["ads"] = ads!
        }
        
        if extra_lives != nil {
            json["extra_lives"] = extra_lives!
        }
        
        API.perform_request(request_type: "POST", url_path: "save_user_info", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            let result = data["result"] as! [String : Any]
            completion_handler(URLResponse.Success, result["user"] as? [String : Any])
            
        })
        
    }
    
    /* Method for saving a new score to the backend.
     * returns Success, Error
     */
    class func save_score (fb_id: String, score: Int, completion_handler: @escaping (URLResponse) -> Void) {
        
        let json = ["fb_id" : fb_id, "score" : score] as [String : Any]
        
        // Perform request.
        API.perform_request(request_type: "POST", url_path: "save_score", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected)
            }
            
            completion_handler(URLResponse.Success)
            
        })
    }
    
    /* Method for saving a list of cached scores for a user
     * returns Success, Error
     */
    class func save_user_scores (fb_id: String, scores: [Int], completion_handler: @escaping (URLResponse) -> Void) {
        
        let json = ["fb_id" : fb_id, "scores" : scores] as [String : Any]
        
        API.perform_request(request_type: "POST", url_path: "save_user_scores", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected)
            }
            
            completion_handler(URLResponse.Success)
            
        })
    }
    
    /* Method for getting a users highscores from the backend.
     * returns Success, Error
     */
    class func get_users_scores (fb_id: String, completion_handler: @escaping (URLResponse, [Int]?) -> Void) {
        
        let json = ["fb_id" : fb_id]
        
        // Perform request.
        API.perform_request(request_type: "POST", url_path: "get_users_scores", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            completion_handler(URLResponse.Success, (data["result"] as! [String:[Int]])["scores"])
            
        })
    }
    
    /* Method for getting scores given a list of fb_ids.
     * returns Success, Error
     */
    
    class func get_friends_scores (friend_ids: [String], completion_handler: @escaping (URLResponse, [[String:Any]]?) -> Void) {
        
        let json = ["friend_ids" : friend_ids]
        
        API.perform_request(request_type: "POST", url_path: "get_friends_scores", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            let result = data["result"] as! [String: Any]
            completion_handler(URLResponse.Success, result["scores"] as? [[String:Any]])
            
        })
        
    }
    
    /* Method for getting the top 100 global highscores from the backend and your place globally.
     * returns Success, Error
     */
    class func get_global_scores (completion_handler: @escaping (URLResponse, [[String:Any]]?) -> Void) {
        
        API.perform_request(request_type: "GET", url_path: "get_global_scores", json: nil, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                return completion_handler(URLResponse.Error, nil)
            }
            
            let result = data["result"] as! [String: Any]
            
            completion_handler(URLResponse.Success, result["scores"] as? [[String:Any]])
        })
    }
    
    /* Method for getting a player's global rank
     * returns Success, Error
     */
    
    class func get_rank (fb_id: String, completion_handler: @escaping (URLResponse, Int?) -> Void) {
        
        let json = ["fb_id" : fb_id]
        
        API.perform_request(request_type: "POST", url_path: "get_rank", json: json, token: nil, completion_handler: {
            (response, data) in
            
            if let _ = data as? URLResponse {
                return completion_handler(URLResponse.ServerDown, nil)
            }
            
            if response == nil {
                return completion_handler(URLResponse.NotConnected, nil)
            }
            
            let data = data as! [String : Any]
            if data["error"] != nil {
                //print(data["error"] as! String)
                
                // user has no scores
                if data["error"] as! String == "no such item for Cursor instance" {
                    return completion_handler(URLResponse.Success, 0)
                } else {
                    return completion_handler(URLResponse.Error, nil)
                }
            }
            
            let result = data["result"] as! [String: Any]
            
            completion_handler(URLResponse.Success, result["rank"] as? Int)
            
        })
    }
    
    // HELPERS
    class func perform_request(request_type: String, url_path: String, json: [String: Any]?, token: String?,completion_handler: @escaping (HTTPURLResponse?, Any?) -> Void) {
        
        // Make url request.
        var request = URLRequest(url: URL(string: API.rootURLString + url_path)!)
        request.httpMethod = request_type
        if request_type == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // If json is not nil add it to the request.
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json!)
            request.httpBody = jsonData
        }
        
        // If token is not nil, add it to the request.
        if token != nil {
            request.setValue("Token " + token!, forHTTPHeaderField: "Authorization")
        }
        
        // Perform request.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) {
            
            (data, response, error) in
            
            DispatchQueue.main.async {
                
                // Handle errors.
                if (error != nil) {
                    
                    if error!.localizedDescription == "Could not connect to the server." {
                        print("couldnt connect to server")
                        return completion_handler(nil, URLResponse.ServerDown)
                    }
                    
                    return completion_handler(nil, nil)
                }
                
                if let http_response = response as? HTTPURLResponse {
                    
                    var json_response : Any?
                    
                    do {
                        json_response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    } catch {
                        
                        //print("\(error)")
                        json_response = nil
                    }
                    
                    completion_handler(http_response, json_response)
                }
                
            }
        }
        task.resume()
    }
}

class Cache {
    
    // silently tries to save cached data to server
    class func save_cache_silent(completion: (() -> Void)? ){
        
        let cache = defaults.array(forKey: "cachedscores") as! [Int]
        let sprites : [String : [Int]] =
            ["climber" : defaults.array(forKey: "climbers") as! [Int],
             "spikeball" : defaults.array(forKey: "spikeballs") as! [Int]]
        
        // both need to be saved, so save them sequentially
        if !cache.isEmpty && defaults.bool(forKey: "unsaved") {
            
            API.save_user_scores(fb_id: FBSDKAccessToken.current().userID, scores: cache, completion_handler: {
                (response) in
                
                if response != URLResponse.Success { return } else {
                    //print("cached scores saved")
                    defaults.set([], forKey: "cachedscores")
                    
                    // save user's cached info
                    API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: sprites, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extra_lives"), completion_handler: {
                        
                        (response, _) in
                        
                        if response != URLResponse.Success { return } else {
                            //print("cached user info saved")
                            defaults.set(false, forKey: "unsaved")
                            
                            if let completion = completion {
                                completion()
                            }
                        }
                    })
                }
            })
            
            // only need to save cached user scores
        } else if !cache.isEmpty {
            API.save_user_scores(fb_id: FBSDKAccessToken.current().userID, scores: cache, completion_handler: {
                (response) in
                
                if response != URLResponse.Success { return } else {
                    //print("cached scores saved")
                    defaults.set([], forKey: "cachedscores")
                    
                    if let completion = completion {
                        completion()
                    }
                }
            })
            
            // only need to save user info
        } else if defaults.bool(forKey: "unsaved") {
            
            API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: sprites, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extra_lives"), completion_handler: {
                
                (response, _) in
                
                if response != URLResponse.Success { return } else {
                    //print("cached user info saved")
                    defaults.set(false, forKey: "unsaved")
                    
                    if let completion = completion {
                        completion()
                    }
                }
            })
            
            // no need for saving anything
        } else {
            if let completion = completion {
                completion()
            }
        }
    }
    
    // creates UIAlertAction with given info
    class func createAlert(title: String, message: String, view: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
}

enum URLResponse {
    case Success
    case ServerDown
    case Error
    case NotConnected
}

