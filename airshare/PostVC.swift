//
//  PostVC.swift
//  
//
//  Created by Kasey Schlaudt on 9/9/17.
//


import UIKit
import Firebase

class PostVC: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var lbl: UILabel!
    
    let imgUid = NSUUID().uuidString
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!
    
    let date = Date()
    let calendar = Calendar.current
    
    var interstitial: GADInterstitial!
    
    var downloadURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        postBtn.isHidden = true
        interstitial = createAndLoadInterstitial()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if postImg.image != nil {
            postBtn.isHidden = false
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5790083206239403/3655344643")
        interstitial.delegate = self //as? GADInterstitialDelegate
        let request = GADRequest()
        request.testDevices = ["aed94a1148008c50d6c11a9072fb4679"]
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func storeUserData() {
        
        // Upload the file to the path "images/rivers.jpg"
        
        
        
        if let imgData = UIImageJPEGRepresentation(self.postImg.image!, 0.2){
            let storageRef = Storage.storage().reference()
            let metaData = StorageMetadata()
            
            storageRef.child("postImgs/" + imgUid).putData(imgData, metadata: metaData) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = (metadata.downloadURL()?.absoluteString)!
                
                
                
                Database.database().reference().child("textPosts").child(self.imgUid).child("postText").setValue(downloadURL)
            }
        }
        
        
        
        
    }
    
    @IBAction func getPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func timeOfPost() -> String {
        let year = String(calendar.component(.year, from: date))
        let month = String(calendar.component(.month, from: date))
        let day = String(calendar.component(.day, from: date))
        let hour = String(calendar.component(.hour, from: date))
        let minute = String(calendar.component(.minute, from: date))
        let second = String(calendar.component(.second, from: date))
        let tame = [year, month, day, hour, minute, second]
        let time = tame[0] + "/" + tame[1] + "/" + tame[2] + " " + tame[3] + ":" + tame[4] + ":" + tame[5]
        return time
    }
    
    @IBAction func post(_ sender: AnyObject) {
        storeUserData()
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            let uid:String = userID!
            
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "stars": 0 as AnyObject,
                "time": self.timeOfPost() as AnyObject,
                "userId": uid as AnyObject,
                "id": self.imgUid as AnyObject,
                "reported" : "false" as AnyObject
            ]
            
            let firebasePost = Database.database().reference().child("textPosts").child(self.imgUid)
            firebasePost.setValue(post)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
    }
}
extension PostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImg.image = image
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}












