//
//  Post.swift
//  petpics
//
//  Created by Maxwell Stone on 1/3/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _username: String!
    private var _userImg: UIImage!
    private var _postText: UIImage!
    private var _postKey:  String!
    private var _stars: Int!
    private var _postRef: DatabaseReference!
    private var _date: String!
    
    var username: String {
        return _username
    }
    
    var date: String {
        return _date
    }
    
    var stars: Int {
        return _stars
    }
    
    var userImg: UIImage {
        return _userImg
    }
    
    var postText: UIImage {
        if _postText != nil {
            return _postText
        }else {
            return #imageLiteral(resourceName: "dog-sillouete")
        }
        
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postText: UIImage, username: String, userImg: UIImage, stars: Int, date: String) {
        _postText = postText
        _username = username
        _userImg = userImg
        _stars = stars
        _date = date
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        _postKey = postKey
        
        if let username = postData["username"] as? String {
            _username = username
        }
        
        if let userImg = postData["userImg"] as? UIImage {
            _userImg = userImg
        }
        
        if let postText = postData["postText"] as? UIImage {
            _postText = postText
        }
        
        if let stars = postData["stars"] as? Int{
            _stars = stars
        }
        
        if let date = postData["time"] as? String{
            _date = date
        }
        
        _postRef = Database.database().reference().child("posts").child(_postKey)
    }
}
