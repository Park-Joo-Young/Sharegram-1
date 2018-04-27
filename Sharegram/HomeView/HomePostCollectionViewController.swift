//
//  HomePostCollectionViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 17..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


private let reuseIdentifier = "Cell"

class HomePostCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBAction func LogOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch let logoutError{
            print(logoutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
    var ref : DatabaseReference?
    var HomePost = [Post]()
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    var profileimage : String = ""
    var index : Int = 0
    var captionText : [String] = []
    var Hash : [AnyToken]!
    var LikeCount : Int = 0
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        ref = Database.database().reference()
        FetchMyPost()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.black
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 20)!], for: .normal)
        self.tabBarController?.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        //self.tabBarController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 12)!], for: .normal)
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
        cell.Caption.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        self.captionText.append(dic.caption!)
        cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
        cell.PostImage.isUserInteractionEnabled = true
        cell.PostImage.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap(_:)))
        cell.PostImage.addGestureRecognizer(tap)
        cell.LikeCountLabel.text = "0"
        cell.TimeLabel.text = dic.timeAgo
        cell.TimeLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        cell.TimeLabel.tintColor = UIColor.lightGray
        cell.UserName.text = dic.username!
        cell.UserName.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
        cell.CommnetBut.tag = indexPath.row
        cell.CommnetBut.addTarget(self, action: #selector(CommentView(_:)), for: .touchUpInside)
        cell.ExceptionBut.tag = indexPath.row
        cell.ExceptionBut.addTarget(self, action: #selector(ExceptionMenu(_:)), for: .touchUpInside)
        cell.LikeBut.tag = indexPath.row
        cell.LikeBut.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
        //좋아요 체크
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_ ,value) in item {
                        if value["postID"] as? String == self.HomePost[indexPath.row].PostId! {
                            print("씨발아")
                            if value["LikePeople"] as? [String : AnyObject] != nil { //좋아요가 있어!
                                self.ref?.child("WholePosts").child((value["postID"] as? String)!).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                                    print("나중에")
                                    self.LikeCount = Int(snapshot.childrenCount)
                                }) // 각 좋아요
                                self.ref?.removeAllObservers()
                                for (_, value1) in (value["LikePeople"] as? [String : String])! {
                                    if value1 == (Auth.auth().currentUser?.uid)! { //내가 좋아요를 눌러놨으면 라이크 버튼
                                        print("씨발아")
                                        cell.LikeCountLabel.text = "좋아요 \(self.LikeCount)개"
                                        cell.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                                        break
                                    } else {
                                        cell.LikeCountLabel.text = "좋아요 \(self.LikeCount)개"
                                        cell.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                                        break
                                    }
                                }
                            } else { //아무것도 좋아요가 없다
                                cell.LikeCountLabel.text = "좋아요가 없습니다."
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
            if self.HomePost[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.HomePost[index].PostId!).child("Report").updateChildValues([key : "허위 게시물"])
            }
        }
        let unfitness = UIAlertAction(title: "부적절합니다.", style: .default) { (action) in
            if self.HomePost[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.HomePost[index].PostId!).child("Report").updateChildValues([key : "부적절 게시물"])
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

    @objc func imageTap(_ sender : UITapGestureRecognizer) {
        if self.HomePost[(sender.view?.tag)!].lat == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExtendImage") as! ExtendImageViewController
            vc.image = self.HomePost[(sender.view?.tag)!].image!
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else { //위치 있으면
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DistanceView") as! DistanceViewController
            vc.PostLocation = CLLocation(latitude: self.HomePost[(sender.view?.tag)!].lat!, longitude: self.HomePost[(sender.view?.tag)!].lon!)
            vc.modalPresentationStyle = .overCurrentContext
            vc.distance = 250.0
            present(vc, animated: true, completion: nil)
            print((sender.view?.tag)!)
        }
    }
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
                                
                              self.DateFetch()
                            }
                        })
                    }
                }

            }
        })
        ref?.removeAllObservers()
    }
    @objc func likePressed(_ sender : UIButton) { //좋아요 눌렀을 때
        let key = ref?.child("HashTagPosts").childByAutoId().key
        let dic = [key! : (Auth.auth().currentUser?.uid)!]
        ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장
                self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").setValue(dic)
                let cell = self.collectionView?.cellForItem(at: IndexPath(row: sender.tag, section: 0)) //해당 셀 가져와서
                sender.setImage(UIImage(named: "like.png"), for: .normal)
                self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                self.HashTagPostLike(self.Hash, 1, sender.tag)
            } else { //좋아요가 하나라도 존재 할 시
                if let item = snapshot.value as? [String : String] {
                    print("??")
                    for (key, value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //좋아요 취소
                            self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople/\(key)").removeValue() // WholePosts 데이터 삭제
                            sender.setImage(UIImage(named: "unlike.png"), for: .normal)
                            if self.Hash != nil {
                                self.HashTagPostLike(self.Hash, 0, sender.tag)
                            }
                        } else { //버튼을 누른 사용자의 데이터가 없다. 즉, 이 글 좋아요
                            self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").setValue(dic)
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
                        
                        if self.HomePost[tag].PostId! == item["postID"] {
                            let dic = [key! : (Auth.auth().currentUser?.uid)!]
                            print(snapshot.key)
                            self.ref?.child("HashTagPosts").child(str).child("Posts").child(snapshot.key).child("LikePeople").setValue(dic)
                            
                        }
                    }
                })
                ref?.removeAllObservers()
            } else { // 좋아요 삭제
                ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value is NSNull {
                        print("아무것도 없습니다.")
                    } else {
                        if let item = snapshot.value as? [String : AnyObject] {
                            for (key , value) in item {
                                if value["postID"] as? String == self.HomePost[tag].PostId {
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
    func DateSort() { //날짜 순 정렬 구조체 반환 함수
        for i in (1..<self.HomePost.count).reversed() {
            for j in 0..<i {
                if self.HomePost[j].timeInterval! < self.HomePost[j+1].timeInterval! { //맨 앞값이 작으면 가장 최근 포스트이기에
                    print("제일 작다는디?")
                    continue
                }
                else if self.HomePost[j].timeInterval! > self.HomePost[j+1].timeInterval! { //뒤에 값이 작으면
                    let postTemp = self.HomePost[j]
                    self.HomePost[j] = self.HomePost[j+1]
                    self.HomePost[j+1] = postTemp
                }
            }
        }
        collectionView?.reloadData()
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
        for i in 0..<self.HomePost.count {
            let Date = format.string(from: date)
            let caption = self.HomePost[i].timeAgo!.components(separatedBy: " ").map{ String($0) }
            let StartDate = format.date(from: Date)!.addingTimeInterval(32400)
            let endDate = format.date(from: caption[0])!.addingTimeInterval(32400) //게시물 작성한 날짜 일자로 계산
            let interval = StartDate.timeIntervalSince(endDate)
            if interval < 1 { // 하루 미만이면
                let start = CommonVariable.formatter.date(from: CommonVariable.formatter.string(from: date))!.addingTimeInterval(32400)
                let end = CommonVariable.formatter.date(from: self.HomePost[i].timeAgo!)!.addingTimeInterval(32400)
                let subinterval = Int(start.timeIntervalSince(end) / 60.0) //분 단위 계산
                self.HomePost[i].timeInterval = Int(subinterval * 60) // 초 차이
                print(subinterval)
                if subinterval > 60 { // 1시간 이상
                    self.HomePost[i].timeAgo = "\(Int(subinterval / 60))시간 전"
                } else if subinterval < 60 {
                    self.HomePost[i].timeAgo = "\(subinterval)분 전"
                } else if subinterval == 0 {
                    self.HomePost[i].timeAgo = "방금 전"
                }
                continue
            }
            self.HomePost[i].timeInterval = Int(interval)
        }
        DateSort()
        return
    }
}
