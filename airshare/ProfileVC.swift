//
//  ProfileVC.swift
//  pet pics
//
//  Created by Maxwell Stone on 3/8/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var usernameField: UITextView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    public var user: Dictionary<String, AnyObject>!
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        resetBtn.isHidden = true
        if Auth.auth().currentUser?.uid == "GSq5sthvknafOuMRw8cWLMUotBf1" || Auth.auth().currentUser?.uid == "ID5AjRZzAZXJubEhQ1BoN2W08bh1" {
            resetBtn.isHidden = false
        }
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        
        
        if let userin = UserDefaults.standard.value(forKey: "userPostDict") as? Dictionary<String, AnyObject> {
            let userInfo = userin
            user = userin
            usernameField.text = userInfo["username"] as! String
            getImage()
        } else {
            print("error in profile")
            let alert = UIAlertController(title: "User Error", message: "Could not get data for current user.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                self.dismiss(animated: true, completion: nil)
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            print("present code has run")
        }
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetBtnClicked(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string : "https://us-central1-airshare-3f340.cloudfunctions.net/chooseWinner")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func changeProfilePhoto(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func storeUserData(){
        
        // Upload the file to the path "images/rivers.jpg"
        
        if let imgData = UIImageJPEGRepresentation(self.image.image!, 0.2){
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
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["userImg":downloadURL!], withCompletionBlock: { (err, ref) in
                    if error != nil {
                        let alert = UIAlertController(title: "Update Error", message: "An error occcured whil trying to update profile image.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        print("present code has run")
                    } else {
                        let alert = UIAlertController(title: "Update Successful", message: "Your profile image was updated successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        print("present code has run")
                    }
                })
            }
        }
        
        
    }
    
    @IBAction func setUsername(_ sender: AnyObject) {
        let userInfo = user
        if usernameField.text != userInfo!["username"] as? String && usernameField.text != nil {
            Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["username":usernameField.text], withCompletionBlock: { (error, ref) in
                if error != nil {
                    let alert = UIAlertController(title: "Update Error", message: "An error occcured whil trying to update username.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    print("present code has run")
                } else {
                    let alert = UIAlertController(title: "Update Successful", message: "Your username was updated successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {  (_) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    print("present code has run")
                }
            })
        }
    }
    
    @IBAction func resetPassword(_ sender: AnyObject) {
        if let userCredits = UserDefaults.standard.value(forKey: "userId") as? Array<String> {
            Auth.auth().sendPasswordReset(withEmail: userCredits[0], completion: { (error) in
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
        }
    }
    
    func getImage(){
        let userInfo = user
        let ref = Storage.storage().reference(forURL: userInfo!["userImg"] as! String)
        ref.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                print(error ?? "no error")
                print("couldnt load img")
            } else {
                if let imgData = data {
                    if let img = UIImage(data: imgData){
                        self.image.image = img
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let images = info[UIImagePickerControllerEditedImage] as? UIImage {
            image.image = images
            storeUserData()
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
