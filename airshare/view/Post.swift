//
//  Post.swift
//  petpics
//
//  Created by Maxwell Stone on 1/3/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import Foundation
import Firebase

class Post: NSObject, NSCoding {
    
    
    private var _username: String!
    private var _userImg: UIImage!
    private var _postText: UIImage!
    private var _postKey:  String!
    private var _stars: Int!
    private var _postRef: DatabaseReference!
    private var _date: String!
    private var _keys: Array<String>!
    private var _reportNum: Int!
    private var _frame: Int!
    
    var Username: String!
    var UserImg: UIImage!
    var PostText: UIImage!
    var PostKey:  String!
    var Stars: Int!
    var PostRef: DatabaseReference!
    var Date: String!
    var Keys: Array<String>!
    var ReportNum: Int!
    
    var username: String {
        return _username
    }
    
    var date: String {
        return _date
    }
    
    var stars: Int {
        return _stars
    }
    
    var frame: Int {
        if _frame != nil {
            print("the frame is there")
            return _frame
        } else {
            print("the frame is not there")
            return 0
            
        }
        
    }
    
    var reportNum: Int {
        return _reportNum
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
    
    var keys: Array<String> {
        return _keys
    }
    
    init(postText: UIImage, username: String, userImg: UIImage, stars: Int, date: String, keys: Array<String>, reportNum: Int, postKey: String, frame: Int) {
        _postText = postText
        _username = username
        _userImg = userImg
        _stars = stars
        _date = date
        _keys = keys
        _reportNum = reportNum
        _postKey = postKey
        _frame = frame
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        _postKey = postData["id"] as! String
        
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
        
        if let keys = postData["users"] as? Array<String> {
            _keys = keys
        } else {
            _keys = [""]
        }
        
        if let reportNum = postData["reportedNum"] as? Int{
            _reportNum = reportNum
        } else {
            _reportNum = 0
        }
        
        if let frame = postData["frame"] as? Int {
            print("the frame is there")
            _frame = frame
            
        } else {
            print("the frame is not there")
            _frame = 0
            
        }
        
        _postRef = Database.database().reference().child("posts").child(_postKey)
    }
    /*
    init(postTextD: UIImage) {
        PostText = postTextD
    }
    
    init(userNameD: String) {
        Username = userNameD
    }
    
    init(userImgD: UIImage) {
        UserImg = userImgD
    }
    
    init(starsD: Int) {
        Stars = starsD
    }
    
    init(dateD: String) {
        Date = dateD
    }
    
    init(keysD: Array<String>) {
        Keys = keysD
    }
    
    init(reportNumD: Int) {
        ReportNum = reportNumD
    }*/
    
    required convenience init?(coder aDecoder: NSCoder) {
    
        self.init(postText: (aDecoder.decodeObject(forKey: "postText") as? UIImage)!,
                  username: (aDecoder.decodeObject(forKey: "username") as? String)!,
                  userImg: (aDecoder.decodeObject(forKey: "userImg") as? UIImage)!,
                  stars: (aDecoder.decodeObject(forKey: "stars") as? Int)!,
                  date: (aDecoder.decodeObject(forKey: "date") as? String)!,
                  keys: (aDecoder.decodeObject(forKey: "keys") as? Array<String>)!,
                  reportNum: (aDecoder.decodeObject(forKey: "reportNum") as! Int),
                  postKey: (aDecoder.decodeObject(forKey: "postKey")as! String),
                  frame: /*(aDecoder.decodeObject(forKey: "frame") as? Int)*/1)
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(_postText, forKey: "postText")
        
        aCoder.encode(_username, forKey: "username")
        
        aCoder.encode(_userImg, forKey: "userImg")
        
        aCoder.encode(_stars, forKey: "stars")
        
        aCoder.encode(_date, forKey: "date")
        
        aCoder.encode(_keys, forKey: "keys")
        
        aCoder.encode(_reportNum, forKey: "reportNum")
        
        aCoder.encode(_postKey, forKey: "postKey")
        
        aCoder.encode(_frame, forKey: "frame")
        
    }
}
