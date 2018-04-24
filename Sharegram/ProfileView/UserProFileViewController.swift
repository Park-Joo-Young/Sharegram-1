//
//  UserProFileViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 19..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import ScrollableSegmentedControl

class UserProFileViewController: UIViewController { //다른 사람이 사람을 검색하거나 눌러서 들어올 때

    @IBOutlet var navi: UINavigationBar!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    var ref : DatabaseReference?
    var item : String = ""
    var UserKey : String = "" // 다른 사람의 uid
    var profileview = ProFileView()
    var UserPost = [Post]()
    var profileimage : String = ""
    var Hash : [AnyToken]!
    var captionText : [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        //self.navigationController?.isNavigationBarHidden = true

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        FetchPost()
        profileview = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(profileview)
        profileview.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.centerX.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(70)
        }
        profileview.ProFileImage.frame.size = CGSize(width: 100, height: 100)
        profileview.ProFileImage.layer.borderWidth = 1.0
        profileview.ProFileImage.layer.masksToBounds = false
        profileview.ProFileImage.layer.cornerRadius = self.profileview.ProFileImage.frame.size.height / 2.0
        profileview.ProFileImage.clipsToBounds = true
        profileview.ProFileImage.contentMode = .scaleToFill
        profileview.FollowerCount.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.ProFileImage.snp.right).offset(70)
        }
        profileview.FollowerCount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.FollowerLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.FollowingCount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.FollowingLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        
        profileview.ProFileEditBut.setTitle("팔로잉", for: .normal)
        profileview.ProFileEditBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.ProFileEditBut.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.FollowerCount.snp.left)
            make.width.equalTo(self.view.frame.width/1.5)
        }
        print("Posts[0].username!")
        print(UserKey)
        if (Auth.auth().currentUser?.uid)! == UserKey {
            profileview.ProFileEditBut.setTitle("자신입니다.", for: .normal)
            profileview.ProFileEditBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            profileview.ProFileEditBut.isEnabled = false
        }
        FollowCheck()
        profileview.ProFileEditBut.addTarget(self, action: #selector(Following), for: .touchUpInside)
        profileview.MyFostCollectionView.delegate = self
        profileview.MyFostCollectionView.dataSource = self
        profileview.MyFostCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        profileview.MyFostCollectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Postcell")
        // Do any additional setup after loading the view.
        profileview.Segment.addTarget(self, action: #selector(ActSegClicked(_:)), for: .valueChanged)
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
extension UserProFileViewController {
    @objc func CommentView(_ sender : UIButton) {
        
        let tag = sender.tag
        print(tag)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleComment") as! SingleCommentViewController
        vc.UserPost = self.UserPost[tag]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    @objc func ExceptionMenu(_ sender : UIButton) {
        print(sender.tag)
        let alert = UIAlertController(title: "기타 메뉴", message: nil, preferredStyle: .actionSheet)
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 15)!]), forKey: "attributedTitle")
        let report = UIAlertAction(title: "신고", style: .default) { (action) in
            self.PostReport(sender.tag)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func PostReport(_ index : Int) { //게시물 신고
        let bool : Bool = false
        let key = (ref?.child("WholePosts").childByAutoId().key)!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 15)!]), forKey: "attributedTitle")
        let broadcast = UIAlertAction(title: "허위 게시물입니다.", style: .default) { (action) in
            if self.UserPost[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.UserPost[index].PostId!).child("Report").updateChildValues([key : "허위 게시물"])
            }
        }
        let unfitness = UIAlertAction(title: "부적절합니다.", style: .default) { (action) in
            if self.UserPost[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.UserPost[index].PostId!).child("Report").updateChildValues([key : "부적절 게시물"])
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (action) in
            return
        }
        alert.addAction(broadcast)
        alert.addAction(unfitness)
        alert.addAction(cancel)
        alert.view.tintColor = UIColor.red
        present(alert, animated: true, completion: nil)
    }

    @objc func likePressed(_ sender : UIButton) { //좋아요 눌렀을 때
        let key = ref?.child("HashTagPosts").childByAutoId().key
        let dic = [key! : (Auth.auth().currentUser?.uid)!]
        ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장
                self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").setValue(dic)
                sender.setImage(UIImage(named: "like.png"), for: .normal)
                self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                self.HashTagPostLike(self.Hash, 1, sender.tag)
            } else { //좋아요가 하나라도 존재 할 시
                if let item = snapshot.value as? [String : String] {
                    for (key, value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //좋아요 취소
                            self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople/\(key)").removeValue() // WholePosts 데이터 삭제
                            sender.setImage(UIImage(named: "unlike.png"), for: .normal)
                            if self.Hash != nil {
                                self.HashTagPostLike(self.Hash, 0, sender.tag)
                            }
                        } else { //버튼을 누른 사용자의 데이터가 없다. 즉, 이 글 좋아요
                            self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").setValue(dic)
                            sender.setImage(UIImage(named: "like.png"), for: .normal)
                            self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                            if self.Hash != nil {
                                self.HashTagPostLike(self.Hash, 1, sender.tag)
                            }
                            
                        }
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
                ref?.child("HashTagPosts").child(str).child("Posts").observe(.childAdded, with: { (snapshot) in
                    if let item = snapshot.value as? [String : String] {
                        
                        if self.UserPost[tag].PostId! == item["postID"] {
                            let dic = [key! : (Auth.auth().currentUser?.uid)!]
                            print(snapshot.key)
                            self.ref?.child("HashTagPosts").child(str).child("Posts").child(snapshot.key).child("LikePeople").setValue(dic)
                            
                        }
                    }
                })
                ref?.removeAllObservers()
            } else { // 데이터 삭제
                ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value is NSNull {
                        print("아무것도 없습니다.")
                    } else {
                        if let item = snapshot.value as? [String : AnyObject] {
                            for (key , value) in item {
                                if value["postID"] as? String == self.UserPost[tag].PostId {
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
                })
                ref?.removeAllObservers()
            }
        }
    }
    @objc func ActSegClicked(_ sender : ScrollableSegmentedControl) {
        if self.profileview.Segment.selectedSegmentIndex == 0 {
            FetchPost()
        } else if self.profileview.Segment.selectedSegmentIndex == 1 {
            FetchPost()
        } else {
            FetchPost()
        }
    }
    func fetchUser() {
        ref?.child("User").child(self.UserKey).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["ProFileImage"] != nil {
                    self.profileimage = item["ProFileImage"]!
                    self.profileview.ProFileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                } else {
                    self.profileview.ProFileImage.image = UIImage(named: "Man.png")
                }
            }
        })
        ref?.removeAllObservers()
        ref?.child("User").child(self.UserKey).child("Follower").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.profileview.FollowerCount.text = "0"
            } else {
                self.profileview.FollowerCount.text = "\(snapshot.childrenCount)"
            }
        })
        ref?.removeAllObservers()
        ref?.child("User").child(self.UserKey).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.key)
            if snapshot.value is NSNull {
                self.profileview.FollowingCount.text = "0"
            } else {
                self.profileview.FollowingCount.text = "\(snapshot.childrenCount)"
            }
        })
        ref?.removeAllObservers()
    }
    func FetchPost() {
        fetchUser()
        self.UserPost.removeAll()
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(key, value) in item {
                    if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                        let post = Post()
                        
                        if ID == self.UserKey { // 그 당사자의 아이디와 일치하는 게시물들만 포스트에 넣기
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
                                self.UserPost.append(post)
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
                                self.UserPost.append(post)
                            }
                        }
                    }
                }
                self.profileview.MyFostCollectionView.reloadData()
            }
        })
     }
    @objc func Following() { //팔로잉 합시다.
        let AutoKey = ref?.child("User").childByAutoId().key
        ref?.child("User").child(UserKey).child("Follower").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull { //내가 다른 사람에 팔로워에 없을 시 즉 첫 사람일경우
                print("Nothing")
                let Following = [AutoKey! : self.UserKey]
                let Follower = [AutoKey! : (Auth.auth().currentUser?.uid)!]
                self.ref?.child("User").child(self.UserKey).child("Follower").setValue(Follower)
                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following").setValue(Following)
                return
            } else {
                if let item = snapshot.value as? [String : String] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (key,value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //있다면 지운다.
                            
                            let alert = UIAlertController(title: "팔로우 중입니다.", message: "취소하시겠습니까?", preferredStyle: .actionSheet)
                            let confirm = UIAlertAction(title: "팔로우 취소", style: .default) { //지우기
                                (action : UIAlertAction) -> Void in
                                //self.dismiss(animated: true, completion: nil)
                                self.ref?.child("User").child(self.UserKey).child("Follower/\(key)").removeValue()
                                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following/\(key)").removeValue()
                                self.profileview.ProFileEditBut.setTitle("팔로우", for: .normal)
                            }
                            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                            alert.addAction(confirm)
                            alert.addAction(cancel)
                            self.present(alert, animated: true, completion: nil)
                            return
                        } else {
                            let Following = [AutoKey! : self.UserKey]
                            let Follower = [AutoKey! : (Auth.auth().currentUser?.uid)!]
                            self.ref?.child("User").child(self.UserKey).child("Follower").setValue(Follower)
                            self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following").setValue(Following)
                            return
                        }
                    }
                }

            }
        })
        ref?.removeAllObservers()
    }
    func FollowCheck(){ //내가 그기 있는지 없는지 확인하자
        //let AutoKey = ref?.child("User").childByAutoId().key
        ref?.child("User").child(UserKey).child("Follower").queryOrderedByKey().observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull { //내가 다른 사람에 팔로워에 없을 시
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : String] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_,value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //있다면 팔로우 중이라는 표시
                            self.profileview.ProFileEditBut.setTitle("팔로우 중 입니다.", for: .normal)
                        } else {
                            return
                        }
                    }
                }
            }
        })
    }
}
extension UserProFileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.UserPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dic = self.UserPost[indexPath.row]
        if profileview.Segment.selectedSegmentIndex == 0 { //기본
            print("ㅐㅏㅐㅏㅐㅏㅐㅐㅏㅐㅐㅏㅐㅏㅐ")
            let cell = self.profileview.MyFostCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
            return cell
        } else if profileview.Segment.selectedSegmentIndex == 1 { //싱글포스트
            let cell = self.profileview.MyFostCollectionView.dequeueReusableCell(withReuseIdentifier: "Postcell", for: indexPath) as! PostCollectionViewCell
            cell.ProFileImage.frame.size = CGSize(width: 50, height: 50)
            cell.ProFileImage.layer.borderWidth = 1.0
            cell.ProFileImage.layer.masksToBounds = false
            cell.ProFileImage.layer.cornerRadius = cell.ProFileImage.frame.size.height / 2.0
            cell.ProFileImage.clipsToBounds = true
            cell.ProFileImage.contentMode = .scaleToFill
            cell.ProFileImage.sd_setImage(with: URL(string: dic.userprofileimage!), completed: nil)
            cell.Caption.text = "\(dic.username!) : \(dic.caption!)"
            cell.Caption.enabledTypes = [.hashtag, .mention, .url]
            cell.Caption.numberOfLines = 0
            cell.Caption.sizeToFit()
            cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
            cell.LikeCountLabel.text = "0"
            cell.TimeLabel.text = dic.timeAgo
            cell.UserName.text = dic.username!
            cell.LikeBut.tag = indexPath.row
            cell.LikeBut.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
            cell.CommnetBut.tag = indexPath.row
            cell.CommnetBut.addTarget(self, action: #selector(CommentView(_:)), for: .touchUpInside)
            cell.ExceptionBut.tag = indexPath.row
            cell.ExceptionBut.addTarget(self, action: #selector(ExceptionMenu(_:)), for: .touchUpInside)
            return cell
        } else { //2
            let cell = Bundle.main.loadNibNamed("CollectionViewCell", owner: self, options: nil)?.first as! CollectionViewCell
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.profileview.Segment.selectedSegmentIndex == 0{
            let width = self.profileview.MyFostCollectionView.frame.width / 3-1
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: self.profileview.MyFostCollectionView.frame.width, height: self.profileview.MyFostCollectionView.frame.height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}
