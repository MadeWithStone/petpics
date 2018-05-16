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
    private var _userImg: String!
    private var _postText: String!
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
    
    var userImg: String {
        return _userImg
    }
    
    var postText: String {
        if _postText != nil {
            return _postText
        } else {
            return "https://firebasestorage.googleapis.com/v0/b/airshare-3f340.appspot.com/o/staticImgs%2Fdog-sillouete.png?alt=media&token=49b81e03-8bef-4db4-9b31-27cdc2b1571d"
        }
        
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postText: String, username: String, userImg: String, stars: Int, date: String) {
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
        
        if let userImg = postData["userImg"] as? String {
            _userImg = userImg
        }
        
        if let postText = postData["postText"] as? String {
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
