//
//  PostFuncVC.swift
//  petpics
//
//  Created by Maxwell Stone on 2/20/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit
import Firebase

class PostFuncVC: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var wagLbl: UILabel!
    @IBOutlet weak var wagBtn: UIButton!
    @IBOutlet weak var dogBtn: UIButton!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    public var data: Post!
    var users: Array<String> = []
    public var interstitial: GADInterstitial!
    public var user: String!
    var myUsername: String!
    
    override func viewDidLoad() {
        let username = data.username
        usernameLbl.text = username
        wagLbl.backgroundColor = hexStringToUIColor(hex: "9B9393")
        loadImgs()
        wagBtn.setTitleColor(hexStringToUIColor(hex: "D10808"), for: .normal)
        dogBtn.setImage(#imageLiteral(resourceName: "dogRed"), for: .normal)
        starInit()
        myUsername = UserDefaults.standard.value(forKey: "username") as! String
        
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5790083206239403/8257907742")
        let request = GADRequest()
        request.testDevices = ["aed94a1148008c50d6c11a9072fb4679"]
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func starInit(){
        let username = UserDefaults.standard.value(forKey: "username") as? String
        print(username ?? "no username")
        print(data.postKey)
        let key = data.postKey
        
        Database.database().reference().child("textPosts").child(key).child("users").observe(.value) { (snapshot) in
            print(snapshot)
            if let myUsers = snapshot.value as? Array<String> {
                var i = 0
                while i < myUsers.count{
                    
                    if myUsers[i] == Auth.auth().currentUser?.uid {
                        print("i is: ", i)
                        self.wagLbl.backgroundColor = self.hexStringToUIColor(hex: "D10808")
                    }
                    i = i + 1
                }
                self.users = myUsers
            }
            
        }
        
        Database.database().reference().child("textPosts").child(key).child("stars").observe(.value) { (snapshot) in
            print(snapshot)
            if let starAmount = snapshot.value as? Int {
                self.wagLbl.text = "Wags: " + String(starAmount)
            }
            
        }
        
        
    }
    
    @IBAction func wagBtn(_ sender: AnyObject){
        print("wagged")
        wagChange()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func wagChange(){
        let username = Auth.auth().currentUser?.uid
        
        let key = data.postKey
        let newStars = (data.stars) + 1
        var theUsers = users
        theUsers.append(username!)
        if wagLbl.backgroundColor == hexStringToUIColor(hex: "9B9393"){
            Database.database().reference().child("textPosts").child(key).updateChildValues(["users" : theUsers])
            Database.database().reference().child("textPosts").child(key).updateChildValues(["stars" : newStars])
        } else {
            if user == myUsername {
                Database.database().reference().child("textPosts").child(key).updateChildValues(["stars" : newStars])
            } else if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
            print("the key is: ", key)
            print("the users are: ", theUsers)
        }
        starInit()
    }
    
    
    func loadImgs(){
        /*if data.postText != nil {
            let reft = Storage.storage().reference(forURL: data["postText"] as! String)
            reft.getData(maxSize: 100000000, completion: { (data, error) in
                if error != nil {
                    print(error!)
                    print("couldnt load img")
                } else {
                    if let imgtData = data {
                        if let imgt = UIImage(data: imgtData){
                            self.postImgView.image = imgt
                        }
                    }
                }
            })
        }
        
        if data["userImg"] != nil {
            let reft = Storage.storage().reference(forURL: data["userImg"] as! String)
            reft.getData(maxSize: 100000000, completion: { (data, error) in
                if error != nil {
                    print(error!)
                    print("couldnt load img")
                } else {
                    if let imgtData = data {
                        if let imgt = UIImage(data: imgtData){
                            self.userImgView.image = imgt
                        }
                    }
                }
            })
        }*/
        self.userImgView.image = data.userImg
        self.postImgView.image = data.postText
    }
    
    @IBAction func reportPost(_ sender: AnyObject){
        rp()
    }
    
    
    
    func rp(){
        let id = self.data.postKey
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Why are you reporting this post?", message: "", preferredStyle: .alert)
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
        
        alert.addAction(UIAlertAction(title: "Inappropriate Content", style: .default, handler: {  (_) in
            Database.database().reference().child("textPosts").child(id).updateChildValues(["reportedNum" : 4])
            Database.database().reference().child("textPosts").child(id).updateChildValues(["reported" : "true"])
            self.dismiss(animated: false, completion: nil)
            
        }))
            alert.addAction(UIAlertAction(title: "Copyright Infringement", style: .default, handler: {  (_) in
                
                
                let alert = UIAlertController(title: "For Copyright Holders", message: "If you are the Copyright holder, please contact Pet Pics at petpics@thecrankfactory.com", preferredStyle: .alert)
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {  (_) in
                    self.report(id: id)
                }))
                
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
                print("present code has run")
                
                
            }))
        
        alert.addAction(UIAlertAction(title: "Violation of Terms of Use", style: .default, handler: {  (_) in
            
            self.report(id: id)
            
            
            
        }))
        
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            print("present code has run")    
    }
    
    func report(id: String){
        print(time)
        let reportNum = data.reportNum
        if reportNum != 0 {
            if reportNum < 3 {
                Database.database().reference().child("textPosts").child(id).updateChildValues(["reportedNum" : reportNum + 1])
                Database.database().reference().child("textPosts").child(id).updateChildValues(["reported" : "false"])
            } else if reportNum >= 3 {
                Database.database().reference().child("textPosts").child(id).updateChildValues(["reportedNum" : reportNum + 1])
                Database.database().reference().child("textPosts").child(id).updateChildValues(["reported" : "true"])
                
            }
            
        } else {
            Database.database().reference().child("textPosts").child(id).updateChildValues(["reportedNum" : 1])
            Database.database().reference().child("textPosts").child(id).updateChildValues(["reported" : "false"])
        }
        dismiss(animated: true, completion: nil)
                
                
                
        
    }
    
}
