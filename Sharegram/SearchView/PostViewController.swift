//
//  PostViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 10..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import ActiveLabel

import Firebase
import SDWebImage

class PostViewController: UIViewController {

    var Posts = [Post]()
    var ref : DatabaseReference?
    var Id : String = ""
    var Profileimage : String = ""
    
    @IBOutlet weak var PostCollection: UICollectionView!
    func fetchPost(){
        ref?.child("WholePosts").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                let post = Post()
                print(item)
                if item["ID"] == self.Id { //전체 포스트에서 검색부분에서 가져온 유저아이디랑 일치하는 게시물을 찾았을 때
                    print("DDDDDDDDDD")
                    if item["latitude"] == nil && item["longitude"] == nil { //위치가 없으면
                        post.caption = item["Description"]
                        post.Id = item["ID"]
                        post.image = item["image"]
                        post.lat = 0
                        post.lon = 0
                        post.numberOfLikes = item["Like"]
                        post.username = item["Author"]
                        post.PostId = item["postID"]
                        post.timeAgo = item["Date"]
                        self.Posts.append(post)
                    } else {
                        post.caption = item["Description"]
                        post.Id = item["ID"]
                        post.image = item["image"]
                        post.lat = Int(item["latitude"]!)
                        post.lon = Int(item["longitude"]!)
                        post.numberOfLikes = item["Like"]
                        post.username = item["Author"]
                        post.PostId = item["postID"]
                        post.timeAgo = item["Date"]
                        self.Posts.append(post)
                        
                    }

                }
            }
        })
        ref?.removeAllObservers()
    }
    func fetchUser(_ id : String) {
        print(Id)
        ref?.child("User").child(Id).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                self.Profileimage = item["ProFileImage"]!
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fetchUser(Id)
        fetchPost()
        PostView.delegate = self
        PostView.dataSource = self
        PostView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.top.equalTo(self.view).offset(50)
            make.centerX.equalTo(self.view)
        }

        //self.navigationController?.isNavigationBarHidden = true
        
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
//postview.ProFileImage.sd_setImage(with: URL(string: Profileimage), completed: nil)
//postview.ProFileImage.layer.cornerRadius = postview.ProFileImage.frame.height / 3.0
//postview.PostImage.sd_setImage(with: URL(string: Posts[index].image!), completed: nil)
//postview.UserName.text = Posts[index].username
//postview.LikeCountLabel.text = Posts[index].numberOfLikes
//postview.UserNameLabel.text = Posts[index].username
////postview.Caption.textAlignment = .
//postview.Caption.numberOfLines = 0
//postview.Caption.enabledTypes = [.hashtag, .mention, .url]
//postview.Caption.text = Posts[index].caption
//postview.Caption.textColor = UIColor.black
//postview.Caption.handleHashtagTap { (hashtag) in
//    print("씨발ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ")
//}
extension PostViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
}
