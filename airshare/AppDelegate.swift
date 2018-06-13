//
//  AppDelegate.swift
//  petpics
//
//  Created by Maxwell Stone on 11/23/17.
//  Copyright © 2017 Maxwell Stone. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    //var newPosts: [Post] = []
    
    //var postsToSave: [[String:AnyObject]] = [[:]]
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //hello
    }
    

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
      // getPosts()
        
        UIApplication.shared.statusBarStyle = .lightContent
        if #available(iOS 11.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-5790083206239403~2306480249")
        
        return true
    }
    
    /*//get data
    func getPosts(){
        
        //get all posts
        
        Database.database().reference().child("textPosts").observeSingleEvent(of: .value) { (snapshot) in
            
            //put data in variable snapshot
            
            guard let cloudPosts = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            
            //get local posts
            
            if let localPosts = self.load(forkey: "localPosts") as? [[String:AnyObject]] {
                
                if localPosts.count == cloudPosts.count {
                    
                    //break code
                    
                } else if localPosts.count < cloudPosts.count {
                    
                    var i = 0
                    while i >= localPosts.count {
                        
                        
                        for j in cloudPosts {
                            
                            guard let currentCloudPost = j.value as? [String:AnyObject] else {return}
                            
                            //let currentLocalPost = localPosts[i]
                            
                            //let currentLocalPostId = currentLocalPost["id"] as? String
                            
                            //let currentCloudPostId = currentCloudPost["id"] as? String
                            
                            if i > localPosts.count {
                                /*if currentLocalPostId == currentCloudPostId {
                                 
                                 }*/
                                
                                //let currentPost = Post(postKey: currentCloudPostId!, postData: currentCloudPost)
                                
                                
                                
                                self.postsToSave.append(currentCloudPost)
                                
                                print("the posts are: ", self.postsToSave)
                                
                                self.getImages(p: self.postsToSave)
                                
                            }
                            
                            
                            
                            
                        }
                        
                        i = i+1
                        
                    }
                    
                }
                
            }
        }
    }
        
        
        func getImages(p: Array<Dictionary<String,AnyObject>>){
            
            //var i = 0
            
            var currentData = p
            
            for i in 0 ... currentData.count {
                
                var data = currentData[i]
                
                let userImg = downloadImages(url: data["userImg"] as! String)
                
                let postImg = downloadImages(url: data["postText"] as! String)
                
                data["userImg"] = userImg
                
                data["postText"] = postImg
                
                currentData[i] = data
                
            }
            
            save(val: currentData as AnyObject, forkey: "localPosts")
            
        }
    
        func downloadImages(url: String) -> UIImage {
            
            var returnImg: UIImage!
            
            let ref = Storage.storage().reference(forURL: url)
            ref.getData(maxSize: 100000000, completion: { (data, error) in
                if error != nil {
                    print(error ?? "no error")
                    print("couldnt load img")
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
                            returnImg = img
                        }
                    } else {
                        returnImg = #imageLiteral(resourceName: "dog-sillouete")
                    }
                }
            })
            
            return returnImg
        
        }
        
    
        
        func save(val: AnyObject, forkey: String){
            
            UserDefaults.standard.set(val, forKey: forkey)
            
            print("post download is compelete: ", val)
            
        }
        
        func load(forkey: String) -> AnyObject {
            
            return UserDefaults.standard.value(forKey: forkey) as AnyObject
            
        }
        
        */
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

