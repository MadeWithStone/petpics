//
//  ViewController.swift
//  petpics
//
//  Created by Maxwell Stone on 11/23/17.
//  Copyright © 2017 Maxwell Stone. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var plusphoto: UIButton!
    @IBOutlet weak var signUpLbl: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var checkBoxLbl: UILabel!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var loadingBTN: UIButton!
    
    
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!
    var uid = ""
    var userId: User!
    var newPosts: [Post] = []
    var postsToSave: [[String:AnyObject]] = [[:]]
    var updatedPostsToSave: Array<Dictionary<String,AnyObject>> = [[:]]
    var cloudPostsCount = 0
    let postCompletion = DispatchGroup()
    private var d: [Post]!
    private var loadedData: [Post]!
    
    
    
    // MARK: NSCoding
    
    
    
    
    
    func savet(data: [String], forkey: String){
        
        UserDefaults.standard.set(data, forKey: forkey)
        
        UserDefaults.standard.synchronize()
        
    }
    
    func loadt(forkey: String) {
        
        if let data = UserDefaults.standard.value(forKey: forkey) as? [String] {
            
            Auth.auth().signIn(withEmail: data[0], password: data[1], completion: { (user, err) in
                
                if err != nil {
                    
                    let alert = UIAlertController(title: "Error Signing In", message: "Please try again", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                        UserDefaults.standard.removeObject(forKey: "uid")
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else if user?.isEmailVerified == true {
                    
                    self.getPosts()
                    
                    Messaging.messaging().subscribe(toTopic: "newPost")
                    
                    print("Subscribed to newPost")
                    
                    self.userId = user
                    
                } else {
                    
                    let alert = UIAlertController(title: "Verification Error", message: "You must first verify your email.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Resend Verification Email", style: .default, handler: {  (_) in
                        user?.sendEmailVerification(completion: { (error) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    print("present code has run")
                    
                }
                
            })
            
        }
        
    }
    
    @IBAction func checkBoxChecked (_ sender: AnyObject){
        
        if checkBox.backgroundImage(for: .normal) == #imageLiteral(resourceName: "white"){
            
            checkBox.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
            
        }else if checkBox.backgroundImage(for: .normal) == #imageLiteral(resourceName: "check"){
            
            checkBox.setBackgroundImage(#imageLiteral(resourceName: "white"), for: .normal)
            
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UserDefaults.standard.removeObject(forKey: "localPosts")
        
        imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self
        
        checkBox.setBackgroundImage(#imageLiteral(resourceName: "white"), for: .normal)
        
        userImage.center.x = self.view.center.x
        
        checkBox.center.x = self.view.center.x
        
        lbl.center.x = self.view.center.x
        
        plusphoto.center.x = self.view.center.x
        
        signUpLbl.center.x = self.view.center.x
        
        userImage.center.x = self.view.center.x
        
        checkView.center.x = self.view.center.x
        loadingBTN.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postsToSave.removeAll()
        postsToSave = [[:]]
        updatedPostsToSave.removeAll()
        updatedPostsToSave = [[:]]
        newPosts.removeAll()
        UserDefaults.standard.removeObject(forKey: "localPosts")
        loadingBTN.isHidden = true
    }
    
    @IBAction func PPBtn(_ sender: AnyObject){
        
        UIApplication.shared.open(URL(string : "http://kidcrews.com/PetPics/Legal/Document665/PetPicsPrivacyPolicy.pdf")!, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func TOUBtn(_ sender: AnyObject){
        
        UIApplication.shared.open(URL(string : "http://kidcrews.com/PetPics/Legal/Document665/PetPicsTermsOfUse.pdf")!, options: [:], completionHandler: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadt(forkey: "uid")
        
    }
    
    func storeUserData(){
        
        // Upload the file to the path "images/rivers.jpg"
        
        if let imgData = UIImageJPEGRepresentation(self.userImage.image!, 0.2){
            
            let storageRef = Storage.storage().reference()
            
            let metaData = StorageMetadata()
            
            let imgUid = NSUUID().uuidString
            
            storageRef.child("userImgs/" + imgUid).putData(imgData, metadata: metaData) { (metadata, error) in
                
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
            
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL()?.absoluteString
                
                let userData = ["username": self.username.text!,
                                "userImg": downloadURL!,
                                "email": self.email.text!] as [String : Any]
                
                Database.database().reference().child("users").child(self.uid).setValue(userData)
                
            }
            
        }
        
        
    }

    @IBAction func getPhoto(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func signInBtn(_ sender: Any) {
        
        if let e = email.text, let pass = password.text{
            
            Auth.auth().signIn(withEmail: e, password: pass) { (user, error) in
                
                if error != nil && !(self.username.text?.isEmpty)! && self.userImage.image != nil && self.checkBox.backgroundImage(for: .normal) == #imageLiteral(resourceName: "check") {
                    
                    //Create New Account
                    
                    Auth.auth().createUser(withEmail: e, password: pass) { (user, error) in
                        
                        if error != nil {
                            
                            let alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: {  (_) in
                                
                                alert.dismiss(animated: true, completion: nil)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.uid = (user?.uid)!
                            
                            self.storeUserData()
                            
                            let userInfo = [e, pass]
                            
                            self.savet(data: userInfo, forkey: "uid")
                            
                            //KeychainWrapper.standard.set((user?.uid)!, forKey: "KEY_UID")
                            
                            print("This is the key: "  + (user?.uid)!)
                            
                        }
                        
                        self.uid = (user?.uid)!
                        
                        self.storeUserData()
                        
                        let userInfo = [e, pass]
                        
                        self.savet(data: userInfo, forkey: "uid")
                        
                        //KeychainWrapper.standard.set((user?.uid)!, forKey: "KEY_UID")
                        
                        print("This is the key: "  + (user?.uid)!)
                        
                    }
                } else if user?.isEmailVerified == true{
                    
                    if (user?.uid) != nil {
                        
                        Messaging.messaging().subscribe(toTopic: "newPost")
                        
                        print("Subscribed to newPost")
                        
                        //Save User and Perform segue
                        
                        self.savet(data: ([e, pass]), forkey: "uid")
                        
                        //KeychainWrapper.standard.set((userUID), forKey: "KEY_UID")
                        
                        self.performSegue(withIdentifier: "toFeed", sender: nil)
                        
                    }
                
                } else if user?.isEmailVerified == false{
                    
                    let alert = UIAlertController(title: "Verification Error", message: "You must first verify your email.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Send Verification Email", style: .default, handler: {  (_) in
                        user?.sendEmailVerification(completion: { (error) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    print("present code has run")
                    
                } else {
                    
                    let alert = UIAlertController(title: "Error Signing In", message: "Either the email or password you entered is not correct", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: {  (_) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Forgot Password", style: .default, handler: {  (_) in
                        
                        Auth.auth().sendPasswordReset(withEmail: e, completion: { (error) in
                            
                            if error != nil {
                                
                                let alert = UIAlertController(title: "There Was An Error", message: "There was an error sending the password reset email.", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                                    alert.dismiss(animated: true, completion: nil)
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                print("present code has run")
                                
                            } else {
                                
                                let alert = UIAlertController(title: "Email Was Sent", message: "Your password reset email was sent.", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                print("present code has run")
                                
                            }
                            
                        })
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    print("present code has run")
                    
                }
                
            }
            
        }
        
    }
    
    
    func getPosts(){
        
        //Download all cloud posts
        loadingBTN.isHidden = false
        Database.database().reference().child("textPosts").observeSingleEvent(of: .value) { (snapshot) in
            
            //create variable with all contents of data snapshot
            guard let snap = snapshot.children.allObjects as? [DataSnapshot] else { return }
            self.cloudPostsCount = snap.count
            //get local data
            /*if let loadedData = UserDefaults.standard.value(forKey: "localPosts") as? NSData {
                
                //un archive local data
                let localData = NSKeyedUnarchiver.unarchiveObject(with: loadedData as Data) as! [Post]
                
                
                //print("loaded posts count", localData.count)
                
                var i = 0
                
                //loop through cloud data
                for data in snap {
                    
                    //make variable with current cloud post
                    let postDict = data.value as? Dictionary<String,AnyObject>
                    
                    //define id of current local post
                    let idLocal = localData[i].postKey
                    
                    //define id of current cloud post
                    let idCloud = postDict!["id"] as? String
                    
                    //check if ids are the same
                    if idLocal != idCloud {
                        
                        //append only new posts to "postsToSave"
                        self.postsToSave.append(postDict!)
                        
                    } else {
                        //what to do if the ids do not match
                        
                    }
                    
                    i = i + 1
                    
                }
                
            } else {*/
                
                //if there are no local posts this code runs
                for data in snap {
                    
                    //make variable with current cloud post
                    let postDict = data.value as? Dictionary<String,AnyObject>
                    if postDict!["reported"] as! String != "true" {
                        //append cloud posts to "postsToSave"
                        self.postsToSave.append(postDict!)
                    }
                    
                   
                }
                print("count ", self.postsToSave.count)
            //}
            
            //remove empty first value
            self.postsToSave.remove(at: 0)
            
            //download and sub in UIImages
            if let _ = self.postsToSave as? [[String:AnyObject]]{
                self.getImages(p: self.postsToSave)
            } else {
                self.performSegue(withIdentifier: "toFeed", sender: nil)            }
         
        }
        
    }
    
    
    func getImages(p: Array<Dictionary<String,AnyObject>>) {
        
        //define array to sub images into
        var newData: Dictionary<String,AnyObject>
        var i: Int = 0
        //loop through posts and download images
        for data in p {
            
            newData = data
            
            
            //define userImg variable that contains UIImage
            downloadImages(url: data["userImg"] as! String, arrayNum: i) {(img, next, arrayNum) -> Void in newData["userImg"] = img; self.updatedPostsToSave[arrayNum]["userImg"] = img; print("got userImg"); self.postCompletion.leave()}
            
            
            
            //define postImg variable that contains UIImage
            downloadImages(url: data["postText"] as! String, arrayNum: i) {(img, next, arrayNum) -> Void in newData["postText"] = img; self.updatedPostsToSave[arrayNum]["postText"] = img; print("got postImg");self.postCompletion.leave()}
            
        
            
            //add posts to array
            updatedPostsToSave.append(newData)
            i = i + 1
        }
        
        //remove initial value
        updatedPostsToSave.remove(at: 0)
        
        print("downloaded posts count: ", updatedPostsToSave.count)
        
        //when all requests are done
        postCompletion.notify(queue: .main){
            
            for i in self.updatedPostsToSave {
                let currentPostToSave = Post(postKey: i["id"] as! String, postData: i)
                self.newPosts.append(currentPostToSave)
            }
            
            
            //self.d = self.newPosts
            print("newPosts: ", self.newPosts)
            
            let dataToSave = NSKeyedArchiver.archivedData(withRootObject: self.newPosts)
            print("dataToSave: ", dataToSave)
            UserDefaults.standard.set(dataToSave, forKey: "localPosts")
            UserDefaults.standard.synchronize()
            
            print("post download is compelete: ")
            
            
            
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
        
        /*//archive data to save
        let dataToSave = NSKeyedArchiver.archivedData(withRootObject: updatedPostsToSave)
        
        //save data
        UserDefaults.standard.set(dataToSave, forKey: "localPosts")
        
        //synchronize data
        UserDefaults.standard.synchronize()
        
        print("posts have been saved")
        
        //transition to feed vc
        self.performSegue(withIdentifier: "toFeed", sender: nil)*/
        
    }
    
    func downloadImages(url: String , arrayNum: Int , completion:@escaping (_ img:UIImage, _ next: Bool, _ arrayNum: Int) -> Void) {
        
        //enter dispatch group
        postCompletion.enter()
        
        //define variable to hold downloaded image
        var postImg: UIImage!
        
        //define Firebase Storage reference
        let ref = Storage.storage().reference(forURL: url)
        
        //download images
        ref.getData(maxSize: 100000000, completion: { (data, error) in
            
            if error != nil {
                
                print(error ?? "no error")
                
                print("couldnt load img")
                
                postImg = #imageLiteral(resourceName: "dog-sillouete")
                
            } else {
                
                //if there is an image
                if let imgData = data {
                    
                    //get the UIImage of the download
                    if let img = UIImage(data: imgData){
                        
                        //put image in variable "img"
                        postImg = img
                        
                        print("the current image is: ", postImg)
                        
                        
                    }
                    
                } else {
                    
                    //if there is now image to download sub in this image
                    postImg = #imageLiteral(resourceName: "dog-sillouete")
                    
                }
                
            }
            completion(postImg, true, arrayNum)
            
        })
        
        //return image to put in view controller
        
        
    }
    
    
    //functions to save and load data
    func save(val: Array<Dictionary<String,AnyObject>>, forkey: String, arrayNum: Int){
        
        
        if arrayNum + 1 == cloudPostsCount {
            
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: val), forKey: forkey)
            
            print("post download is compelete: ", val)
            
            
            
            self.performSegue(withIdentifier: "toFeed", sender: nil)
            
        } else {
            
        }
        
        
        
    }
    
    func load(forkey: String) -> Array<Dictionary<String,AnyObject>> {
        
        if let local = UserDefaults.standard.value(forKey: forkey) as? NSData {
            
            let localPosts = NSKeyedUnarchiver.unarchiveObject(with: local as Data) as! Array<Dictionary<String,AnyObject>>
            
            return localPosts
            
        } else {
            
            return [[:]]
            
        }
        
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFeed" {
            
            let wvc = segue.destination as! UITabBarController
            
            let lvc = wvc.viewControllers?.first as! UINavigationController
            
            let vc = lvc.viewControllers.first as! FeedVC
            
            vc.userId = userId
            
        }
    }
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userImage.image = image
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
}


