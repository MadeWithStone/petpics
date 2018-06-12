//
//  FeedVC.swift
//  pet pics
//
//  Created by Maxwell Stone on 1/2/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UITableViewController, GADInterstitialDelegate {
    
    //Variables
    var currentUserImageUrl: String!
    var posts = [Post]()
    var selectedPost: Post!
    var child = "time"
    let date = Date()
    let calander = Calendar.current
    var keys = [String]()
    var stars = [Int]()
    var starAmount: Int!
    var userStarAmount: Int!
    var dated: String!
    var key: String!
    var gameTimer: Timer!
    var interstitial: GADInterstitial!
    var tagged = [[String]]()
    var offset: CGFloat = 0
    var dataForPostView: Dictionary<String, AnyObject>!
    var dataArray = [Post]()
    var currentPost: Post!
    var userOfWeak: String!
    var userInfo: Dictionary<String, AnyObject> = [:]
    lazy var refControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    public var userId: User!
    var newPosts: [Post] = []
    var postsToSave: [[String:AnyObject]] = [[:]]
    var updatedPostsToSave: Array<Dictionary<String,AnyObject>> = [[:]]
    var cloudPostsCount = 0
    let postCompletion = DispatchGroup()
    private var d: [Post]!
    private var loadedData: [Post]!
    //IBOutlets
    @IBOutlet weak var sortBtn: UIButton!
    
    //IBFunctions
    
    
    
    
    @IBAction func feed(_ sender: UIButton){
        if sortBtn.title(for: .normal) == "Leaderboard" {
            sortBtn.setTitle("Feed", for: .normal)
            navigationItem.title = "Leaderboard"
            child = "stars"
            dataArray.sort{
                return $0.stars > $1.stars
            }
            tableView.reloadData()
        } else if sortBtn.title(for: .normal) == "Feed" {
            sortBtn.setTitle("Leaderboard", for: .normal)
            navigationItem.title = "Feed"
            child = "time"
            dataArray.sort{
                return $0.date > $1.date
            }
            tableView.reloadData()
        }
        
        //getPosts()
    }
    
    //Initialize View(viewDidLoad())
    override func viewDidLoad() {
        
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: "index")
        
        self.tableView.addSubview(self.refControl)
        
        
        initialize()
        loadPosts()
        updateStars()
        getPosts()
        dataArray.sort{
            return $0.date > $1.date
        }
        self.tableView.reloadData()
        //loadPosts()
        
        
        
    }
    
    func loadPosts(){
        if let data = UserDefaults.standard.data(forKey: "localPosts"),
            let localPosts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Post]{
            
            dataArray = localPosts
            print("the loaded posts are: ", dataArray)
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //initialize()
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.offset ), animated: true)
        //getPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        offset = tableView.contentOffset.y
        /*self.posts.removeAll()
        self.keys.removeAll()
        self.dataArray.removeAll()
        tableView.reloadData()*/
        if navigationItem.title == "Leaderboard" {
            sortBtn.setTitle("Feed", for: .normal)
            child = "stars"
            print("button should be Leaderboard")
        } else if navigationItem.title == "Feed" {
            sortBtn.setTitle("Leaderboard", for: .normal)
            child = "time"
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        //getPosts()
        refreshControl.endRefreshing()
        
    }
    
    func initialize(){
        
        
        
        //getPosts()
        getVars()
        sortBtn.setTitle("Leaderboard", for: .normal)
        interstitial = createAndLoadInterstitial()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Watch Ad", style: .plain, target: self, action: #selector(watchAd))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        if navigationItem.title == "Leaderboard" {
            sortBtn.setTitle("Feed", for: .normal)
            child = "stars"
            print("button should be Leaderboard")
        } else if navigationItem.title == "Feed" {
            sortBtn.setTitle("Leaderboard", for: .normal)
            child = "time"
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.removeObject(forKey: "id")
    }
    
    @objc func signOut (_ sender: AnyObject) {
        UserDefaults.standard.removeObject(forKey: "uid")
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func watchAd (_ sender: AnyObject) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    @objc func toCreatePost (_ sender: AnyObject) {
        performSegue(withIdentifier: "toCreatePost", sender: nil)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        //UserDefaults.standard.removeObject(forKey: "localPosts")
        getPosts()
        dataArray.removeAll()
        newPosts.removeAll()
        self.dismiss(animated: false) {
            self.refreshControl?.endRefreshing()
        }
        //self.tableView.reloadData()
        
    }
    
    //Download Data
    func getVars(){
        print(userStarAmount)
        if let user = Auth.auth().currentUser {
            Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let postDict = snapshot.value as? [String : AnyObject]{
                        UserDefaults.standard.set(postDict, forKey: "userPostDict")
                        UserDefaults.standard.synchronize()
                        self.userStarAmount = postDict["star_amount"] as? Int
                        print(self.userStarAmount)
                        self.dated = postDict["date"] as? String
                        print(self.dated)
                        print("should have compared dates")
                        UserDefaults.standard.set(postDict["username"], forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        self.currentUserImageUrl = postDict["userImg"] as! String
                        print("the img urlis: " + self.currentUserImageUrl)
                        self.userInfo = postDict
                        if self.userStarAmount != nil{
                            print(self.userStarAmount)
                            //v.starsLbl.text = "You Have " + String(self.userStarAmount) + " Stars Left"
                            print("should have updated lable")
                        }else{
                            print("no stars")
                            
                        }
                        if postDict["username"] as? String == "admin" {
                            //self.getPosts()
                        }
                    }
                    
                })
            
            
        }
        
        
        
        Database.database().reference().child("userOfWeek").child("user").observeSingleEvent(of: .value) { (snapshot) in
            self.userOfWeak = snapshot.value as? String
            if self.userOfWeak != nil {
                print("the user is: " + self.userOfWeak)
            }
        }
        self.tableView.reloadData()
    }
    
    func getUserData(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let postDict = snapshot.value as? [String : AnyObject]{
                self.currentUserImageUrl = postDict["userImg"] as! String
                self.tableView.reloadData()
            }
        })
    }
    
    
    func loadIndexPath() {
        if let index = UserDefaults.standard.value(forKey: "index") as? Int {
            print("the index is: ", index)
            let indexPath = NSIndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath as IndexPath, at: .middle, animated: false)
            UserDefaults.standard.removeObject(forKey: "index")  
        }
        
    }
    
    /*func getPosts() {
        Database.database().reference().child("textPosts").queryOrdered(byChild: child).observe(.childChanged) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            //self.posts.removeAll()
            print("posts")
            //self.keys.removeAll()
            
            //self.dataArray.removeAll()
            
            self.offset = self.tableView.contentOffset.y
            //var s = NSIndexPath(row: 0, section: 0)
            //self.tableView.contentOffset.y = 0
              //self.tableView.scrollToRow(at: s as IndexPath, at: UITableViewScrollPosition(rawValue: 0)!, animated: false)
            
            
            var i = 0
            for data in snapshot.reversed() {
                guard let postDict = data.value as? Dictionary<String, AnyObject> else { return }
                self.dataArray[i] = postDict
                print(postDict)
                let currentPost = self.posts[i] as Post
                let reported = postDict["reported"] as? String
                if let d = postDict["stars"] as? Int {
                    if reported != "true" && d != currentPost.stars {
                        let post = Post(postKey: data.key, postData: postDict)
                        self.posts.append(post)
                        self.keys.append(data.key)
                        self.stars.append(postDict["stars"] as! Int)
                        let tg = postDict["userStars"] as! [String]
                        
                        for ii in 0..<tg.count {
                            if tg[ii] == "hello"{
                                //username is at index
                                print(ii)
                                break
                            }else{
                                print("hello is not a stared username")
                            }
                        }
                    }
                }
                
                i = i + 1
                
            }
            
            UserDefaults.standard.set(self.keys, forKey: "keys")
            UserDefaults.standard.set(self.stars, forKey: "stars")
            UserDefaults.standard.set(self.tagged, forKey: "tagged")
            UserDefaults.standard.synchronize()
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.offset ), animated: true)
            //self.tableView.contentOffset.y = 0
            self.offset = 0
        }
        Database.database().reference().child("textPosts").queryOrdered(byChild: child).observe(.value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if self.tableView.contentOffset.y == 0 {
                //self.posts.removeAll()
                print(self.posts)

                //self.keys.removeAll()
                //self.dataArray.removeAll()
                var i = 0
                for data in snapshot.reversed() {
                    guard let postDict = data.value as? Dictionary<String, AnyObject> else { return }
                    
                    print("post dict for post number: ", i, " ", data.value)
                    let reported = postDict["reported"] as? String
                    
                    var reportValue: String!
                    
                    let username = UserDefaults.standard.value(forKey: "username") as? String
                    print("post dict is ", postDict)
                    if username == "admin" {
                        reportValue = "false"
                    } else {
                        reportValue = "true"
                    }
                    if i >= self.posts.count {
                        //let currentPost = self.posts[i] as? Post
                        print("post dict is ", postDict)
                            if reported != reportValue {
                                let post = Post(postKey: data.key, postData: postDict)
                                self.posts.append(post)
                                self.keys.append(data.key)
                                self.stars.append(postDict["stars"] as! Int)
                                self.dataArray.append(postDict)
                                print("post dict is ", postDict)
                            }
                        
                    }
                    
                    
                    
                    i = i + 1
                }
                print(self.keys)
                UserDefaults.standard.set(self.keys, forKey: "keys")
                UserDefaults.standard.synchronize()
                UserDefaults.standard.set(self.stars, forKey: "stars")
                self.tableView.reloadData()
                self.loadIndexPath()
                
            }
        }
        self.tableView.reloadData()
        refControl.endRefreshing()
        
        
    }*/
    //postText: UIImage, username: String, userImg: UIImage, stars: Int, date: String, keys: Array<String>, reportNum: Int, postKey: String
    func updateStars(){
        Database.database().reference().child("textPosts").observe(.childChanged) { (snapshot) in
            
            let child = snapshot.value as? Dictionary<String,AnyObject>
            
            var num = 0
            print("the child is: ", child)
                
                for i in self.dataArray {
                    
                    if i.postKey == child!["id"] as! String {
                        
                        var currentPostToUpdate: Dictionary<String,AnyObject> = [:]
                        
                        currentPostToUpdate["postText"] = i.postText
                        currentPostToUpdate["username"] = i.username as AnyObject
                        currentPostToUpdate["userImg"] = i.userImg
                        currentPostToUpdate["stars"] = child?["stars"]
                        currentPostToUpdate["time"] = i.date as AnyObject
                        currentPostToUpdate["users"] = child?["users"]
                        currentPostToUpdate["reportNum"] = child?["reportNum"]
                        currentPostToUpdate["id"] = i.postKey as AnyObject
                        
                        let currentPostToAdd: Post = Post(postKey: currentPostToUpdate["id"] as! String, postData: currentPostToUpdate)
                        
                        self.self.dataArray[num] = currentPostToAdd
                        
                        
                        
                    }
                    num = num + 1
                }
                
            
                
            
            let dataToStore = NSKeyedArchiver.archivedData(withRootObject: self.dataArray)
            UserDefaults.standard.set(dataToStore, forKey: "localPosts")
            UserDefaults.standard.synchronize()
            self.loadPosts()
            
            
        }
    }
    
    func getPosts(){
        
        /*//Download all cloud posts
        
        Database.database().reference().child("textPosts").observe(.childAdded) { (snapshot) in
            
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
                    print("the snap is ", snap)
                    //append cloud posts to "postsToSave"
                    self.postsToSave.append(postDict!)
                    
                }
                
            //}
            
            //remove empty first value
            self.postsToSave.remove(at: 0)
            
            //download and sub in UIImages
            if let _ = self.postsToSave as? [[String:AnyObject]]{
                self.getImages(p: self.postsToSave)
            } else {
                self.refreshControl?.endRefreshing()
            }
        }*/
        
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
            let dataToSave = NSKeyedArchiver.archivedData(withRootObject: self.newPosts)
            UserDefaults.standard.set(dataToSave, forKey: "localPosts")
            UserDefaults.standard.synchronize()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            print("post download is compelete: ")
            
            
            
            
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
   
    
    
    
    //Other Functions(save, load)
    func save(data: String, forkey: String){
        UserDefaults.standard.set(data, forKey: forkey)
        UserDefaults.standard.synchronize()
    }
    func load(forkey: String) -> String {
        let data = UserDefaults.standard.value(forKey: forkey) as? String
        return data!
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5790083206239403/7231766534")
        let request = GADRequest()
        request.testDevices = ["aed94a1148008c50d6c11a9072fb4679"]
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }

    
    //Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "index")
        UserDefaults.standard.synchronize()
        print(indexPath.row)
        if dataArray.count > 0 && indexPath.row > 0{
            makeDictionary(index: indexPath.row)
        } 
        
    }
    
    func createAndLoadInterstitialTwo() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5790083206239403/8257907742")
        let request = GADRequest()
        request.testDevices = ["aed94a1148008c50d6c11a9072fb4679"]
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    
    func makeDictionary(index: Int){
        print(dataArray.count)
        
        currentPost = dataArray[index-1]
        print(keys)
        print(posts)
        //currentPost.keys = keys[index-1] as AnyObject
        print(currentPost)
        
        performSegue(withIdentifier: "toPostView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostView" {
            let vc = segue.destination as! PostFuncVC
            vc.data = currentPost
            vc.interstitial = createAndLoadInterstitial()
            vc.user = userOfWeak
        } else if segue.identifier == "toProfile" {
            let vc = segue.destination as! ProfileVC
            vc.user = userInfo
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellToReturn: AnyObject!
        print(indexPath.row)
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ShareSomethingCell {
                
                if currentUserImageUrl != nil {
                    print(currentUserImageUrl)
                    cell.configCell(imgUrl: currentUserImageUrl)
                    
                }
                cell.shareBtn.addTarget(self, action: #selector(toCreatePost), for: .touchUpInside)
                cellToReturn = cell
            }
        }
        
        
        if indexPath.row > 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostCell else { return UITableViewCell() }
            print("there are: ", posts.count, " posts")
            print("the current post is: ", indexPath.row-1)
            
            
            print("displaying images")
            print(dataArray)
            let currentPost = dataArray[indexPath.row-1]
                print("configuring cells")
                cell.configCell(post: currentPost)
            
                
                
                
                
                
                
                cell.layoutIfNeeded()
                //cell.configCell(post: posts[indexPath.row-1])
                cellToReturn = cell
            }
        
        return cellToReturn as! UITableViewCell
    }
    
    /*override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offset = tableView.contentOffset.y
    }*/
    
    
    
    
}

