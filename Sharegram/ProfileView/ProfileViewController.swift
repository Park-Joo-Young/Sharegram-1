//
//  ProfileViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 1. 11..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import ScrollableSegmentedControl
import CDAlertView
import CoreLocation

class ProfileViewController: UIViewController {
    
    var MySettingBut = UIButton()
    var profileview = ProFileView()
    var UserPost = [Post]()
    var profileimage : String = ""
    var ref : DatabaseReference?
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    var Hash : [AnyToken]!
    var captionText : [String] = []
    var LikeCount : Int = 0
    var TagPost = [Post]()
    var FollowerList : [String ] = []
    var FollowingList : [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        
        FetchPost()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        profileview = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(profileview)
        self.view.addSubview(MySettingBut)
        profileview.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(70)
        }
        profileview.ProFileImage.frame.size = CGSize(width: 70, height: 70)
        profileview.ProFileImage.layer.borderWidth = 1.0
        profileview.ProFileImage.layer.masksToBounds = false
        profileview.ProFileImage.layer.cornerRadius = self.profileview.ProFileImage.frame.size.height / 2.0
        profileview.ProFileImage.clipsToBounds = true
        profileview.ProFileImage.contentMode = .scaleToFill
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(clickFollower))
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(clickFollowing))
        
        profileview.FollowerCount.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.ProFileImage.snp.right).offset(70)
        }
        profileview.FollowerCount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.FollowerCount.isUserInteractionEnabled = true
        profileview.FollowerCount.addGestureRecognizer(followerTap)
        profileview.FollowerLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        
        profileview.FollowingCount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        profileview.FollowingCount.isUserInteractionEnabled = true
        profileview.FollowingCount.addGestureRecognizer(followingTap)
        profileview.FollowingLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        

        profileview.ProFileEditBut.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.FollowerCount.snp.left)
            make.width.equalTo(self.view.frame.width/1.5)
            make.top.equalTo(profileview.FollowerCount.snp.bottom).offset(40)
        }
        profileview.ProFileEditBut.addTarget(self, action: #selector(ProfileEdit), for: .touchUpInside)
        profileview.ProFileEditBut.setTitle("프로필 수정", for: .normal)
        profileview.ProFileEditBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        
        profileview.MyFostCollectionView.delegate = self
        profileview.MyFostCollectionView.dataSource = self
        profileview.MyFostCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        profileview.MyFostCollectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Postcell")
        profileview.MyFostCollectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "cell1")
        // Do any additional setup after loading the view.
        profileview.Segment.addTarget(self, action: #selector(ActSegClicked(_:)), for: .valueChanged)
        
        MySettingBut.snp.makeConstraints { (make) in
            make.top.equalTo(profileview.ProFileEditBut)
            make.width.equalTo(UIScreen.main.bounds.width/10)
            make.height.equalTo(profileview.ProFileEditBut)
            make.left.equalTo(profileview.ProFileEditBut.snp.right).offset(10)
        }
        MySettingBut.setImage(UIImage(named: "icon-settings-filled.png"), for: .normal)
        MySettingBut.setTitle("", for: .normal)
        MySettingBut.backgroundColor = UIColor.white
        MySettingBut.layer.cornerRadius = 3.0
        MySettingBut.layer.borderWidth = 1.5
        MySettingBut.layer.borderColor = UIColor.lightGray.cgColor
        MySettingBut.tintColor = UIColor.black
        MySettingBut.addTarget(self, action: #selector(appSetting(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func ProfileEdit() {
        performSegue(withIdentifier: "ProFileEdit", sender: self)
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
extension ProfileViewController {
    @objc func appSetting(_ sender : UIButton) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url as URL, completionHandler: nil)
        }
    }
    @objc func likePressed(_ sender : UIButton) { //좋아요 눌렀을 때
        let key = ref?.child("WholePosts").childByAutoId().key
        let dic = [key! : (Auth.auth().currentUser?.uid)!]

        self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장

                self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").setValue(dic)
                
                self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                if self.Hash.isEmpty {
                    self.FetchPost()
                    sender.setImage(UIImage(named: "like.png"), for: .normal)
                    return
                } else { //해쉬태그까지 있으면
                    self.HashTagPostLike(self.Hash, 0, sender.tag)
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
                            self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople/\(key1)").removeValue() // WholePosts 데이터 삭제
                            self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                            if self.Hash.isEmpty {
                                self.FetchPost()
                                sender.setImage(UIImage(named: "unlike.png"), for: .normal)
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
                    self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).child("LikePeople").updateChildValues(dic)
                    self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                    if self.Hash.isEmpty {
                        self.FetchPost()
                        sender.setImage(UIImage(named: "like.png"), for: .normal)
                        return
                    } else { //해쉬태그까지 있으면
                        self.HashTagPostLike(self.Hash, 0, sender.tag)
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
                            if self.UserPost[tag].PostId! == value["postID"] as? String {
                                let dic = [key! : (Auth.auth().currentUser?.uid)!]
                                print(snapshot.key)
                                self.ref?.child("HashTagPosts").child(str).child("Posts").child((value["postID"] as? String)!).child("LikePeople").setValue(dic)
                            }
                        }
                        
                    }
                    self.FetchPost()
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
                    self.FetchPost()
                })
                ref?.removeAllObservers()
            }
        }
    }
    func HashTagPostRemove(_ tag : Int) { //게시물 삭제의 연동
        self.Hash = self.UserPost[tag].caption!._tokens(from: HashtagTokenizer())
        for i in 0..<self.Hash.count {
            let str = self.Hash[i].text.replacingOccurrences(of: "#", with: "")
            ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let item = snapshot.value as? [String : AnyObject] {
                    for(key, value) in item {
                        if let postID = value["postID"] as? String {
                            if postID == self.UserPost[tag].PostId! { //같은 포스트 아이디를 가진걸 찾았다.
                                self.ref?.child("HashTagPosts").child(str).child("Posts/\(key)").removeValue()
                                self.FetchPost()
                            }
                        }
                    }
                }
            })
        }
    }
    @objc func CommentView(_ sender : UIButton) {
        
        let tag = sender.tag
        print(tag)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleComment") as! SingleCommentViewController
        vc.UserPost = self.UserPost[tag]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    @objc func ExceptionMenu(_ sender : UIButton) { //기타 메뉴
        let alert = UIAlertController(title: "기타 메뉴", message: nil, preferredStyle: .actionSheet)
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 15)!]), forKey: "attributedTitle")
        let remove = UIAlertAction(title: "게시물 삭제", style: .default) { (action) in
            let confirm = CDAlertView(title: "삭제 하시겠습니까", message: nil, type: CDAlertViewType.notification)
            let remove = CDAlertViewAction(title: "삭제", font: UIFont(name: "BM DoHyeon OTF", size : 15)!, textColor: UIColor.red, backgroundColor: UIColor.white, handler: { (action) in
                self.ref?.child("WholePosts").child(self.UserPost[sender.tag].PostId!).removeValue()
                self.HashTagPostRemove(sender.tag)
                return true
            })
            let cancel = CDAlertViewAction(title: "취소", font: UIFont(name: "BM DoHyeon OTF", size : 15)!, textColor: UIColor.black, backgroundColor: UIColor.white, handler: nil)
            confirm.add(action: remove)
            confirm.add(action: cancel)
            confirm.show()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(remove)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
        self.FollowerList.removeAll()
        self.FollowingList.removeAll()
        ref?.child("User").child(self.UserKey).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["ProFileImage"] != nil {
                    self.profileimage = item["ProFileImage"]!
                    self.profileview.ProFileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                } else {
                    self.profileview.ProFileImage.image = UIImage(named: "profile.png")
                }
            }
        })
        ref?.removeAllObservers()
        ref?.child("User").child(self.UserKey).child("Follower").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.profileview.FollowerCount.text = "0"
            } else {
                if let item = snapshot.value as? [String : String] {
                    for(_, value) in item {
                        self.FollowerList.append(value)
                    }
                }
                self.profileview.FollowerCount.text = "\(snapshot.childrenCount)"
            }
        })
        ref?.removeAllObservers()
        ref?.child("User").child(self.UserKey).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.key)
            if snapshot.value is NSNull {
                self.profileview.FollowingCount.text = "0"
            } else {
                if let item = snapshot.value as? [String : String] {
                    for(_, value) in item {
                        self.FollowingList.append(value)
                    }
                }
                self.profileview.FollowingCount.text = "\(snapshot.childrenCount)"
            }
        })
        ref?.removeAllObservers()
    }
    func countLike(_ id : String) {
       print(id)
        self.ref?.child("WholePosts").child(id).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { // 좋아요 미존재
                print("없어")
                self.LikeCount = 0
            } else {
                print("있어")
               self.LikeCount = Int(snapshot.childrenCount)
            }
        })
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
                                //self.countLike(postID)
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
                                
                                if let people = value["LikePeople"] as? [String : AnyObject] { //좋아요 누른 인간까지 같이 따기
                                    for (_, user) in people {
                                        post.PeopleWhoLike.append(user as! String)
                                    }
                                }
                                if Description.contains(Author) { //내이름이 포함된 게시물이 있따! 즉 태그
                                    self.TagPost.append(post)
                                    print("??시발")
                                }
                                self.UserPost.append(post)
                            } else {
                                //self.countLike(postID)
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
                                if let people = value["LikePeople"] as? [String : AnyObject] { //좋아요 누른 인간까지 같이 따기
                                    for (_, user) in people {
                                        post.PeopleWhoLike.append(user as! String)
                                    }
                                }
                                if Description.contains(Author) { //내이름이 포함된 게시물이 있따! 즉 태그
                                    print("??시발")
                                    self.TagPost.append(post)
                                }
                                self.UserPost.append(post)
                            }
                        }
                    }
                }
                
            }
            self.DateFetch()
        })
        ref?.removeAllObservers()
        
    }
    func DateSort() { //날짜 순 정렬 구조체 반환 함수
        for i in (1..<self.UserPost.count).reversed() {
            for j in 0..<i {
                if self.UserPost[j].timeInterval! < self.UserPost[j+1].timeInterval! { //맨 앞값이 작으면 가장 최근 포스트이기에
                    print("제일 작다는디?")
                    continue
                }
                else if self.UserPost[j].timeInterval! > self.UserPost[j+1].timeInterval! { //뒤에 값이 작으면
                    let postTemp = self.UserPost[j]
                    self.UserPost[j] = self.UserPost[j+1]
                    self.UserPost[j+1] = postTemp
                }
            }
        }
        self.profileview.MyFostCollectionView.reloadData()
        return
    }
    func DateFetch() { // 날짜 따오기
        let date = Date()
        let format = DateFormatter()
        TimeZone.ReferenceType.default = TimeZone(abbreviation: "KST")!
        format.dateFormat = "yyyy-MM-dd"
        format.timeZone = TimeZone.ReferenceType.default
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_kr")
        //CommonVariable.formatter.timeZone = TimeZone.init(abbreviation: "KST")
        for i in 0..<self.UserPost.count {
            let Date = format.string(from: date)
            let caption = self.UserPost[i].timeAgo!.components(separatedBy: " ").map{ String($0) }
            let StartDate = format.date(from: Date)!.addingTimeInterval(32400)
            let endDate = format.date(from: caption[0])!.addingTimeInterval(32400) //게시물 작성한 날짜 일자로 계산
            let interval = StartDate.timeIntervalSince(endDate)
            if interval < 1 { // 하루 미만이면
                let start = CommonVariable.formatter.date(from: CommonVariable.formatter.string(from: date))!.addingTimeInterval(32400)
                let end = CommonVariable.formatter.date(from: self.UserPost[i].timeAgo!)!.addingTimeInterval(32400)
                let subinterval = Int(start.timeIntervalSince(end) / 60.0) //분 단위 계산
                self.UserPost[i].timeInterval = Int(subinterval * 60) // 초 차이
                print(subinterval)
                if subinterval > 60 { // 1시간 이상
                    self.UserPost[i].timeAgo = "\(Int(subinterval / 60))시간 전"
                } else if subinterval < 60 {
                    self.UserPost[i].timeAgo = "\(subinterval)분 전"
                } else if subinterval == 0 {
                    self.UserPost[i].timeAgo = "방금 전"
                }
                //print(interval)
                continue
            }
            self.UserPost[i].timeInterval = Int(interval)
        }
        if self.UserPost.count != 0 {
          DateSort()
        }
        return
    }
    @objc func imageTap(_ sender : UITapGestureRecognizer) {
        if self.UserPost[(sender.view?.tag)!].lat == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExtendImage") as! ExtendImageViewController
            vc.image = self.UserPost[(sender.view?.tag)!].image!
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else { //위치 있으면
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DistanceView") as! DistanceViewController
            vc.PostLocation = CLLocation(latitude: self.UserPost[(sender.view?.tag)!].lat!, longitude: self.UserPost[(sender.view?.tag)!].lon!)
            vc.modalPresentationStyle = .overCurrentContext
            vc.distance = 250.0
            present(vc, animated: true, completion: nil)
        }
    }
    @objc func clickFollower() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "List") as! ListViewController
        vc.modalPresentationStyle = .overCurrentContext
        //vc.modalTransitionStyle = .crossDissolve
        vc.List = self.FollowerList
        if self.FollowerList.count == 0 {
            return
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
    @objc func clickFollowing() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "List") as! ListViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.List = self.FollowingList
        if self.FollowingList.count == 0 {
            return
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
    @objc func clickLike(_ sender : UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "List") as! ListViewController
        vc.modalPresentationStyle = .overCurrentContext
        //vc.modalTransitionStyle = .crossDissolve
        vc.List = self.UserPost[(sender.view?.tag)!].PeopleWhoLike
        print(self.UserPost[(sender.view?.tag)!].PeopleWhoLike)
        if self.UserPost[(sender.view?.tag)!].PeopleWhoLike.count == 0 {
            return
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
}
extension ProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.UserPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.countLike(self.UserPost[indexPath.row].PostId!)
        let dic = self.UserPost[indexPath.row]
        if profileview.Segment.selectedSegmentIndex == 0 { //기본
            print("ㅐㅏㅐㅏㅐㅏㅐㅐㅏㅐㅐㅏㅐㅏㅐ")
            let cell = self.profileview.MyFostCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
            return cell
        } else if profileview.Segment.selectedSegmentIndex == 1 { //싱글포스트
            let cell = self.profileview.MyFostCollectionView.dequeueReusableCell(withReuseIdentifier: "Postcell", for: indexPath) as! PostCollectionViewCell
            cell.ProFileImage.frame.size = CGSize(width: 50, height: 50)
            if dic.userprofileimage != "" { //프로필 이미지가 있으면
               cell.ProFileImage.sd_setImage(with: URL(string: dic.userprofileimage!), completed: nil)
            } else {
                cell.ProFileImage.image = UIImage(named: "profile.png")
            }
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
            cell.Caption.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            self.captionText.append(dic.caption!)
            cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
            cell.PostImage.isUserInteractionEnabled = true
            cell.PostImage.tag = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap(_:)))
            cell.PostImage.addGestureRecognizer(tap)
            //cell.LikeCountLabel.text = "좋아요 \(self.LikeCount)개"
            cell.LikeCountLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.TimeLabel.text = dic.timeAgo
            cell.TimeLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.TimeLabel.textColor = UIColor.lightGray
            cell.UserName.text = dic.username!
            cell.UserName.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.ExceptionBut.tag = indexPath.row
            cell.ExceptionBut.addTarget(self, action: #selector(ExceptionMenu), for: .touchUpInside)
            cell.LikeBut.tag = indexPath.row
            cell.LikeBut.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
            cell.CommnetBut.tag = indexPath.row
            cell.CommnetBut.addTarget(self, action: #selector(CommentView(_:)), for: .touchUpInside)
            cell.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
            for people in dic.PeopleWhoLike {
                if people == self.UserKey {
                    cell.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                    break
                }
            }
            cell.LikeCountLabel.text = "좋아요 \(dic.PeopleWhoLike.count)개"
            cell.LikeCountLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.LikeCountLabel.tag = indexPath.row
            cell.LikeCountLabel.isUserInteractionEnabled = true
            let liketap = UITapGestureRecognizer(target: self, action: #selector(clickLike(_:)))
            cell.LikeCountLabel.addGestureRecognizer(liketap)
            
            return cell
        } else { //2 나를 태그한 인간.
            let cell = self.profileview.MyFostCollectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! CollectionViewCell1
            if self.TagPost.count != 0 {
               let tagdic = self.TagPost[indexPath.row]
               cell.PostImage.sd_setImage(with: URL(string: tagdic.image!), completed: nil)
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.profileview.Segment.selectedSegmentIndex == 0 || self.profileview.Segment.selectedSegmentIndex == 2{
            let width = self.profileview.MyFostCollectionView.frame.width / 3-1
            return CGSize(width: width, height: width)
        } else { //1
            return CGSize(width: self.profileview.MyFostCollectionView.frame.width, height: CommonVariable.screenHeight)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if profileview.Segment.selectedSegmentIndex == 1 {
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SinglePost") as! SinglePostViewController
            vc.UserPost = self.UserPost[indexPath.row]
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }
    }
}

