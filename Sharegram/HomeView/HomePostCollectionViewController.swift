//
//  HomePostCollectionViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 17..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class HomePostCollectionViewController: UICollectionViewController {
    var ref : DatabaseReference?
    var HomePost = [Post]()
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    var profileimage : String = ""
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        ref = Database.database().reference()
        FetchMyPost()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView?.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CommonVariable.screenWidth, height: CommonVariable.screenHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.HomePost.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dic = self.HomePost[indexPath.row]
        print(dic.userprofileimage!)
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCollectionViewCell
        cell.ProFileImage.sd_setImage(with: URL(string: dic.userprofileimage!), completed: nil)
        cell.Caption.text = "\(dic.username!) : \(dic.caption!)"
        cell.Caption.enabledTypes = [.hashtag, .mention, .url]
        cell.Caption.numberOfLines = 0
        cell.Caption.sizeToFit()
        cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
        cell.LikeCountLabel.text = "0"
        cell.TimeLabel.text = dic.timeAgo
        cell.UserName.text = dic.username!
        cell.CommnetBut.tag = indexPath.row
        cell.CommnetBut.addTarget(self, action: #selector(CommentView(_:)), for: .touchUpInside)
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_ ,value) in item {
                        if value["postID"] as? String == self.HomePost[indexPath.row].PostId! {
                            print("씨발아")
                            if value["LikePeople"] as? [String : AnyObject] != nil {
                                for (_, value1) in (value["LikePeople"] as? [String : String])! {
                                    if value1 == (Auth.auth().currentUser?.uid)! { //내가 좋아요를 눌러놨으면 라이크 버튼
                                        print("씨발아")
                                        cell.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                                        break
                                    } else {
                                        cell.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                                        break
                                    }
                                }
                            } else { //아무것도 좋아요가 없다
                                cell.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                                break
                            }
                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
extension HomePostCollectionViewController {
    @objc func CommentView(_ sender : UIButton) {

        let tag = sender.tag
        print(tag)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleComment") as! SingleCommentViewController
        vc.UserPost = self.HomePost[tag]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    func FetchMyPost() { //내포스트 따기
        self.HomePost.removeAll()
        self.fetchUser(self.UserKey)
        self.ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(_, value) in item {
                    if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                        let post = Post()
                        if ID == self.UserKey {
                            if value["latitude"] as? String == nil { //위치가 없으면
                                post.caption = Description
                                post.Id = ID
                                post.image = image
                                post.lat = 0
                                post.lon = 0
                                post.username = Author
                                post.PostId = postID
                                post.timeAgo = Date
                                post.timeInterval = 0
                                post.userprofileimage = self.profileimage
                                self.HomePost.append(post)
                            } else {
                                post.caption = Description
                                post.Id = ID
                                post.image = image
                                let lat = value["latitude"] as? String
                                let lon = value["longitude"] as? String
                                post.lat = Double(lat!)
                                post.lon = Double(lon!)
                                post.username = Author
                                post.PostId = postID
                                post.timeAgo = Date
                                post.timeInterval = 0
                                post.userprofileimage = self.profileimage
                                self.HomePost.append(post)
                            }
                        }
                    }
                }
                //self.collectionView?.reloadData()
            }
        })
        ref?.removeAllObservers()
        FetchPost()
    }
    func fetchUser(_ id : String) {
        
        ref?.child("User").child(id).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                self.profileimage = item["ProFileImage"]!
            }
        })
        ref?.removeAllObservers()
    }
    func FetchPost() {
        ref?.child("User").child(self.UserKey).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                //바로 내 포스트만 따러 가 ~
                print("dlfcl hghghgygyghgy")
            } else { // 팔로잉 중인 사람이 있다.
                if let item = snapshot.value as? [String : String] { //팔로잉 한명 당 게시물 따기
                    for(_, value) in item {
                        print(value)
                        self.ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                            if let item = snapshot.value as? [String : AnyObject] {
                                for (_, value1) in item {
                                    if let Description = value1["Description"] as? String, let Author = value1["Author"] as? String, let Date = value1["Date"] as? String, let ID = value1["ID"] as? String, let image = value1["image"] as? String , let postID = value1["postID"] as? String {
                                        let post = Post()
                                        print("불일치 ")
                                        if ID ==  value { // 팔로잉 하는 사람과 일치하면
                                            print("일치")
                                            self.fetchUser(value) //그사람 프로필 따고 게시물 따고
                                            if value1["latitude"] as? String == nil { //위치가 없으면
                                                post.caption = Description
                                                post.Id = ID
                                                post.image = image
                                                post.lat = 0
                                                post.lon = 0
                                                post.username = Author
                                                post.PostId = postID
                                                post.timeAgo = Date
                                                post.timeInterval = 0
                                                post.userprofileimage = self.profileimage
                                                self.HomePost.append(post)
                                            } else {
                                                post.caption = Description
                                                post.Id = ID
                                                post.image = image
                                                let lat = value1["latitude"] as? String
                                                let lon = value1["longitude"] as? String
                                                post.lat = Double(lat!)
                                                post.lon = Double(lon!)
                                                post.username = Author
                                                post.PostId = postID
                                                post.timeAgo = Date
                                                post.timeInterval = 0
                                                post.userprofileimage = self.profileimage
                                                self.HomePost.append(post)
                                            }
                                        }
                                    }
                                }
                              self.collectionView?.reloadData()
                            }
                        })
                    }
                }

            }
        })
        ref?.removeAllObservers()
    }
}
