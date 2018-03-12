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
import VegaScrollFlowLayout

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
                        self.PostCollection.reloadData()
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
                        self.PostCollection.reloadData()
                    }
                }
                
            }
        })
        ref?.removeAllObservers()
    }
    func fetchUser(_ id : String) {
        
        ref?.child("User").child(id).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                self.Profileimage = item["ProFileImage"]!
                self.PostCollection.reloadData()
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        Posts.removeAll()
        fetchUser(Id)
        fetchPost()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        PostCollection.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.top.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
        PostCollection.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")

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
extension PostViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PostCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCollectionViewCell
        cell.ProFileImage.sd_setImage(with: URL(string: Profileimage), completed: nil)
        cell.ProFileImage.layer.cornerRadius = cell.ProFileImage.frame.height / 3.0
        cell.ProFileImage.clipsToBounds = true
        cell.PostImage.sd_setImage(with: URL(string: Posts[indexPath.row].image!), completed: nil)
        cell.UserName.text = Posts[indexPath.row].username
        //cell.LikeCountLabel.text = "좋아요" + Posts[indexPath.row].numberOfLikes
        if Posts[indexPath.row].numberOfLikes == "0" {
            cell.LikeCountLabel.text = "마음에 드신다면 좋아요를 눌러주세요"
        } else {
            cell.LikeCountLabel.text = "좋아요" + (Posts[indexPath.row].numberOfLikes)! + "개"
        }
        //postview.Caption.textAlignment = .
        cell.Caption.numberOfLines = 0
        cell.Caption.enabledTypes = [.hashtag, .mention, .url]
        cell.Caption.text = (Posts[indexPath.row].username)! + "   " + (Posts[indexPath.row].caption)!
        cell.Caption.textColor = UIColor.black
        cell.Caption.handleHashtagTap { (hashtag) in
            print("씨발ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ")
        }
        return cell
    }
    
    
}

