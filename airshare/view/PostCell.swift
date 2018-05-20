//
//  PostCell.swift
//  petpics
//
//  Created by Maxwell Stone on 1/3/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//


import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var starsLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var loadingLbl: UILabel!
    
    var post: Post!

    let feed = FeedVC()
    
    
    @IBAction func reportPost(_ sender: UIButton){
        UserDefaults.standard.set(dateLbl.text!, forKey: "id")
        
        
    }
    
    func getKeys() -> [String]{
        let k = UserDefaults.standard.value(forKey: "keys") as? [String]
        return k!
    }
    
    func getStars() -> [Int]{
        let k = UserDefaults.standard.value(forKey: "stars") as? [Int]
        return k!
    }
    
    func getTagged() -> [[String]]{
        let k = UserDefaults.standard.value(forKey: "tagged") as? [[String]]
        return k!
    }
    
    @IBAction func wag(_ sender: AnyObject){
        starsUpdate()
        
        
    }
    
    func starsUpdate(){
        changStarAmount()
        feed.getVars()
        
    }
    
    func changStarAmount(){
        let keys = getKeys()
        let stars = getStars()
        let starChange = stars[(indexPath?.row)!-1] + 1
        UserDefaults.standard.set((indexPath?.row)!-1, forKey: "index")
        UserDefaults.standard.synchronize()
        print((indexPath?.row)!-1)
        //print("indexPath: ", UserDefaults.standard.value(forKey: "index"))
        Database.database().reference().child("textPosts").child(keys[(indexPath?.row)!-1]).updateChildValues(["stars" : starChange])
        //feed.getPosts()
    }
    
    func configCell(post: Post) {
        
        
        
        self.post = post
        self.username.text = post.username
        self.starsLbl.text = String(post.stars)
        self.dateLbl.text = post.date
        
        
            self.postImg.image = post.postText
       
        
        
            self.userImg.image = post.userImg
        
        
        
        
        
        
    }
    
    func load(forkey: String) -> AnyObject {
        
        return UserDefaults.standard.value(forKey: forkey) as AnyObject
        
    }
    
    func configLoadingCell(b: Bool){
        self.loadingLbl.isHidden = b
    }
    
    
    func configStars(starAmount: Int, post: Post){
        
        //Database.database().reference().child("textPosts").child(post).child("stars").setValue(starAmount)
    }
}
