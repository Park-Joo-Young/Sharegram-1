//
//  SinglePostViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 13..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import ActiveLabel

class SinglePostViewController: UIViewController { //PostId 만 받으면 다 가능
    var postID : String = ""
    var UserID : String = ""
    var UserPost = Post()
    var ProFileImage = UIImageView()
    var UserName = UILabel()
    var ExceptionBut = UIButton()
    var PostImage = UIImageView()
    var LikeBut = UIButton()
    var CommentBut = UIButton()
    var Caption = ActiveLabel()
    var TimeLabel = UILabel()
    var Likecount = UILabel()
    var width = CommonVariable.screenWidth
    var height = CommonVariable.screenHeight
    var ref : DatabaseReference?
    var Hash : [AnyToken]!
    var User = Userinfo()
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var navi: UINavigationBar!
    override func viewWillLayoutSubviews() {
        Caption.sizeToFit()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        ref = Database.database().reference()
        
        fetchUser()
        fetchpost()
        //LikeCheck()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        navi.topItem?.title = "게시글"
        navi.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        navi.tintColor = UIColor.black
        
        self.view.addSubview(ProFileImage)
        self.view.addSubview(UserName)
        self.view.addSubview(ExceptionBut)
        self.view.addSubview(PostImage)
        self.view.addSubview(LikeBut)
        self.view.addSubview(CommentBut)
        self.view.addSubview(Caption)
        self.view.addSubview(TimeLabel)
        self.view.addSubview(Likecount)
        
        ProFileImage.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.top.equalTo(navi.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(5)
        }
        ProFileImage.frame.size = CGSize(width: 50, height: 50)
        ProFileImage.layer.masksToBounds = false
        ProFileImage.layer.cornerRadius = self.ProFileImage.frame.size.height / 2.0
        ProFileImage.clipsToBounds = true
        ProFileImage.contentMode = .scaleToFill
        
        UserName.snp.makeConstraints { (make) in
            make.width.equalTo(width/2)
            make.height.equalTo(height/30)
            make.left.equalTo(ProFileImage.snp.right).offset(10)
            make.centerY.equalTo(ProFileImage)
        }
        UserName.adjustsFontSizeToFitWidth = true
        UserName.text = UserPost.username!
        UserName.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        ExceptionBut.snp.makeConstraints { (make) in
            make.width.equalTo(width/10)
            make.height.equalTo(height/20)
            make.right.equalTo(self.view).offset(-10)
            make.centerY.equalTo(UserName)
        }
        ExceptionBut.setImage(UIImage(named: "exception.png"), for: .normal)
        PostImage.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(height/2)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(ProFileImage.snp.bottom).offset(10)
        }
        PostImage.sd_setImage(with: URL(string: UserPost.image!), completed: nil)
        PostImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        PostImage.addGestureRecognizer(tap)
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(width/10)
            make.height.equalTo(height/20)
            make.left.equalTo(self.view).offset(10)
            make.top.equalTo(PostImage.snp.bottom).offset(10)
        }
        LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
        LikeBut.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        
        CommentBut.snp.makeConstraints { (make) in
            make.size.equalTo(LikeBut)
            make.left.equalTo(LikeBut.snp.right).offset(20)
            make.top.equalTo(LikeBut)
        }
        CommentBut.setImage(UIImage(named: "comment.png"), for: .normal)
        CommentBut.addTarget(self, action: #selector(PresentCommentView), for: .touchUpInside)
        Likecount.snp.makeConstraints { (make) in
            make.width.equalTo(width/2)
            make.height.equalTo(height/33)
            make.top.equalTo(LikeBut.snp.bottom).offset(2)
            make.left.equalTo(LikeBut)
        }
        Likecount.text = "좋아요 \(self.UserPost.PeopleWhoLike.count)개"
        Likecount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        
        Caption.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.lessThanOrEqualTo(height/10)
            make.top.equalTo(Likecount.snp.bottom).offset(5)
            make.left.equalTo(LikeBut)
            make.right.equalTo(self.view)
        }
        Caption.enabledTypes = [.hashtag, .mention, .url]
        Caption.numberOfLines = 0
        Caption.textAlignment = .left
        Caption.adjustsFontSizeToFitWidth = true
        Caption.text = UserPost.caption!
        Caption.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        TimeLabel.snp.makeConstraints { (make) in
            make.size.equalTo(UserName)
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
            make.left.equalTo(Caption)
        }
        TimeLabel.textColor = UIColor.lightGray
        TimeLabel.text = UserPost.timeAgo!
        TimeLabel.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
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
extension SinglePostViewController {
    func LikeCount() {
        ref?.child("WholePosts").child(self.UserPost.PostId!).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //좋아요 음다
                self.Likecount.text = "좋아요 0개"
            } else { //있따.
                self.Likecount.text = "좋아요 \(snapshot.childrenCount)개"
                print(snapshot.childrenCount)
            }
        })
    }
    @objc func imageTap() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExtendImage") as! ExtendImageViewController
            vc.image = self.UserPost.image!
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
    }
    @objc func PresentCommentView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleComment") as! SingleCommentViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.UserPost = self.UserPost
        present(vc, animated: true, completion: nil)
    }
    func LikeCheck() {
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_ ,value) in item {
                        if value["postID"] as? String == self.UserPost.PostId! {
                            if value["LikePeople"] as? [String : AnyObject] != nil {
                                for (_, value1) in (value["LikePeople"] as? [String : String])! {
                                    if value1 == (Auth.auth().currentUser?.uid)! { //내가 좋아요를 눌러놨으면 라이크 버튼
                                        print("씨발아")
                                        self.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                                        break
                                    } else {
                                        self.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                                        break
                                    }
                                }
                            } else { //아무것도 좋아요가 없다
                                self.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                                break
                            }
                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
    }
    func fetchUser() {
        
        ref?.child("User").child(self.UserPost.Id!).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["ProFileImage"] != nil {
                    self.ProFileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                    self.UserPost.userprofileimage = item["ProFileImage"]!
                } else {
                    self.ProFileImage.image = UIImage(named: "profile.png")
                }
            }
        })
        ref?.removeAllObservers()
    }
    func fetchpost() {
        self.UserPost.PeopleWhoLike.removeAll()
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(_, value) in item {
                    if value["postID"] as? String == self.UserPost.PostId! {
                        if value["LikePeople"] as? [String : String] != nil {
                            for (_, value1) in (value["LikePeople"] as? [String : String])! {
                                if value1 == self.UserKey {
                                    self.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                                }
                                self.UserPost.PeopleWhoLike.append(value1)
                            }
                            self.Likecount.text = "좋아요 \(self.UserPost.PeopleWhoLike.count)개"
                            print(self.UserPost.PeopleWhoLike.count)
                        } else {
                            self.Likecount.text = "좋아요 \(self.UserPost.PeopleWhoLike.count)개"
                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
    }
    @objc func likePressed(_ sender : UIButton) { //좋아요 눌렀을 때
        let key = ref?.child("WholePosts").childByAutoId().key
        let dic = [key! : (Auth.auth().currentUser?.uid)!]
        
        self.ref?.child("WholePosts").child(self.UserPost.PostId!).child("LikePeople").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장
                
                self.ref?.child("WholePosts").child(self.UserPost.PostId!).child("LikePeople").setValue(dic)
                
                self.Hash = self.UserPost.caption!._tokens(from: HashtagTokenizer())
                if self.Hash.isEmpty {
                    //self.FetchPost()
                    self.fetchpost()
                    sender.setImage(UIImage(named: "like.png"), for: .normal)
                    
                    return
                } else { //해쉬태그까지 있으면
                    self.HashTagPostLike(self.Hash, 1, sender.tag)
                    sender.setImage(UIImage(named: "like.png"), for: .normal)
                    return
                }
            } else { //좋아요가 하나라도 존재 할 시
                
                if let item = snapshot.value as? [String : String] {
                    print(item)
                    for (key1, value) in item {
                        print(value)
                        print(self.UserKey)
                        if value == self.UserKey { //좋아요 취소
                            print(key1)
                            self.ref?.child("WholePosts").child(self.UserPost.PostId!).child("LikePeople/\(key1)").removeValue() // WholePosts 데이터 삭제
                            self.Hash = self.UserPost.caption!._tokens(from: HashtagTokenizer())
                            if self.Hash.isEmpty {
                                sender.setImage(UIImage(named: "unlike.png"), for: .normal)
                                self.fetchpost()
                                return
                            } else { //해쉬태그까지 있으면
                                self.HashTagPostLike(self.Hash, 0, sender.tag)
                                sender.setImage(UIImage(named: "unlike.png"), for: .normal)
                                return
                            }
                        } else { //버튼을 누른 사용자의 데이터가 없다. 즉, 이 글 좋아요
                            continue
                        }
                    } //다 검사하고 나왔는데도 안에 값이 없으면 ! 좋아요
                    self.ref?.child("WholePosts").child(self.UserPost.PostId!).child("LikePeople").updateChildValues(dic)
                    self.Hash = self.UserPost.caption!._tokens(from: HashtagTokenizer())
                    if self.Hash.isEmpty {
                        self.fetchpost()
                        sender.setImage(UIImage(named: "like.png"), for: .normal)
                        return
                    } else { //해쉬태그까지 있으면
                        self.HashTagPostLike(self.Hash, 1, sender.tag)
                        sender.setImage(UIImage(named: "like.png"), for: .normal)
                        return
                    }
                }
            }
        })
        ref?.removeAllObservers()
        
    }
    func HashTagPostLike(_ Token : [AnyToken], _ index : Int, _ tag : Int) {
        
        for i in 0..<Token.count {
            let str = Token[i].text.replacingOccurrences(of: "#", with: "")
            let key = ref?.child("HashTagPosts").childByAutoId().key
            if index == 1 { // 저장
                ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if let item = snapshot.value as? [String : AnyObject] {
                        for(_, value) in item {
                            if self.UserPost.PostId! == value["postID"] as? String {
                                let dic = [key! : (Auth.auth().currentUser?.uid)!]
                                print(snapshot.key)
                                self.ref?.child("HashTagPosts").child(str).child("Posts").child((value["postID"] as? String)!).child("LikePeople").setValue(dic)
                            }
                        }
                        
                    }
                    self.fetchpost()
                })
                
                ref?.removeAllObservers()
            } else { // 데이터 삭제
                ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value is NSNull {
                        print("아무것도 없습니다.")
                    } else {
                        if let item = snapshot.value as? [String : AnyObject] {
                            for (key , value) in item {
                                if value["postID"] as? String == self.UserPost.PostId {
                                    if value["LikePeople"] as? [String : AnyObject] != nil { //좋아요가 존재한다.
                                        self.ref?.child("HashTagPosts").child(str).child("Posts").child(key).child("LikePeople").observe(.value, with: { (snapshot) in
                                            if let item = snapshot.value as? [String : String] {
                                                for (key1, value1) in item {
                                                    if value1 == self.UserKey {
                                                        self.ref?.child("HashTagPosts").child(str).child("Posts").child(key).child("LikePeople/\(key1)").removeValue()
                                                    }
                                                }
                                            }
                                        })
                                    }
                                }
                                
                            }
                        }
                    }
                    self.fetchpost()
                })
                ref?.removeAllObservers()
            }
        }
    }
}
