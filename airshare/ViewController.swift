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
    
    
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!
    var uid = ""
    var userId: User!
    
    func save(data: [String], forkey: String){
        UserDefaults.standard.set(data, forKey: forkey)
        UserDefaults.standard.synchronize()
    }
    func load(forkey: String) {
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
                    Messaging.messaging().subscribe(toTopic: "newPost")
                    print("Subscribed to newPost")
                    self.userId = user
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
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
        
    }
    
    @IBAction func PPBtn(_ sender: AnyObject){
        UIApplication.shared.open(URL(string : "http://thecrankfactory.com/PetPics/Legal/Document665/PetPicsPrivacyPolicy.pdf")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func TOUBtn(_ sender: AnyObject){
        UIApplication.shared.open(URL(string : "http://thecrankfactory.com/PetPics/Legal/Document665/PetPicsTermsOfUse.pdf")!, options: [:], completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        load(forkey: "uid")
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
            
            Auth.auth().signIn(withEmail: e, password: pass) {
                (user, error) in
                if error != nil && !(self.username.text?.isEmpty)! && self.userImage.image != nil && self.checkBox.backgroundImage(for: .normal) == #imageLiteral(resourceName: "check") {
                    //Create New Account
                    Auth.auth().createUser(withEmail: e, password: pass) {
                        (user, error) in
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
                            self.save(data: userInfo, forkey: "uid")
                            //KeychainWrapper.standard.set((user?.uid)!, forKey: "KEY_UID")
                            print("This is the key: "  + (user?.uid)!)
                        }
                        self.uid = (user?.uid)!
                        self.storeUserData()
                        let userInfo = [e, pass]
                        self.save(data: userInfo, forkey: "uid")
                        //KeychainWrapper.standard.set((user?.uid)!, forKey: "KEY_UID")
                        print("This is the key: "  + (user?.uid)!)
                        
                        
                    }
                } else if user?.isEmailVerified == true{
                    if (user?.uid) != nil {
                        Messaging.messaging().subscribe(toTopic: "newPost")
                        print("Subscribed to newPost")
                        //Save User and Perform segue
                        self.save(data: ([e, pass]), forkey: "uid")
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

