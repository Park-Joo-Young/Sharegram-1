//
//  HomeViewController.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UIViewController {
    var ref : DatabaseReference?
    var HomePost = [Post]()
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    var profileimage : String = ""
    var index : Int = 0
    var captionText : [String] = []
    var Hash : [AnyToken]!
    var LikeCount : Int = 0
    var imageview = UIImageView()
    var barImage: UIImage!
    var FollowingList : [String] = []
    
 
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch let logoutError{
            print(logoutError)
        }
    }
    @IBOutlet var HomeCollection: UICollectionView!

    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
            self.HomeCollection?.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        if HomePost.count == 0 {
           Feed()
        }
        else {
            feeddd()
        }
        print(UserKey)
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
        HomeCollection.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight)
        }
        tabBarController?.delegate = self
    }
}
extension HomeViewController {
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
        print(self.HomePost[tag])
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleComment") as! SingleCommentViewController
        vc.UserPost = self.HomePost[tag]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    func Feed() {
        self.HomePost.removeAll()
            ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let item = snapshot.value as? [String : AnyObject] {
                    for (key, value) in item {
                        if key == self.UserKey { //내 아뒤 드가서
                            if let user = value["Following"] as? [String : AnyObject] {
                                for(_, user) in user {
                                    self.FollowingList.append(user as! String) //팔로잉 값 추가
                                }
                            }
                            
                            self.FollowingList.append(self.UserKey) //내 값도
                            
                        }
                    }
                }
               self.feeddd()
            })
            ref?.removeAllObservers()
    }
    func feeddd() {
        self.HomePost.removeAll()
        self.ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(_, value) in item  {
                    if let userid = value["ID"] as? String {
                        for each in self.FollowingList {
                            if each == userid { //팔로잉 리스트 안에 값과 똑같은 값을 찾음 페치함
                                let post = Post()
                                if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                                    if value["latitude"] as? String != nil { //위치가 있으
                                        post.caption = Description
                                        post.username = Author
                                        post.timeAgo = Date
                                        post.Id = ID
                                        post.image = image
                                        post.PostId = postID
                                        post.timeInterval = 0
                                        //post.userprofileimage = self.profileimage
                                        let lat = value["latitude"] as? String
                                        let lon = value["longitude"] as? String
                                        post.lat = Double(lat!)
                                        post.lon = Double(lon!)
                                        if let people = value["LikePeople"] as? [String : AnyObject] { //좋아요 누른 인간까지 같이 따기
                                            for (_, user) in people {
                                                post.PeopleWhoLike.append(user as! String)
                                            }
                                        }
                                        self.HomePost.append(post)
                                    } else { // 위치가 없으면
                                        post.caption = Description
                                        post.username = Author
                                        post.timeAgo = Date
                                        post.Id = ID
                                        post.image = image
                                        post.PostId = postID
                                        post.timeInterval = 0
                                        post.lat = 0
                                        post.lon = 0
                                        if let people = value["LikePeople"] as? [String : AnyObject] { //좋아요 누른 인간까지 같이 따기
                                            for (_, user) in people {
                                                print("이게 뭔일?")
                                                post.PeopleWhoLike.append(user as! String)
                                            }
                                        }
                                        self.HomePost.append(post)
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
            }
            self.DateFetch()
            return
        })
        ref?.removeAllObservers()
    }
    
    @objc func likePressed(_ sender : UIButton) { //좋아요 눌렀을 때
        let key = ref?.child("WholePosts").childByAutoId().key
        let dic = [key! : (Auth.auth().currentUser?.uid)!]
        print(self.HomePost[sender.tag].PostId!)
        print(self.HomePost.count)
        self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장
                print(sender.tag)
                print(self.HomePost.count)
                self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").setValue(dic)
                
                self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                if self.Hash.isEmpty {
                    self.feeddd()
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
                            self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople/\(key1)").removeValue() // WholePosts 데이터 삭제
                            self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                            if self.Hash.isEmpty {
                                self.feeddd()
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
                self.ref?.child("WholePosts").child(self.HomePost[sender.tag].PostId!).child("LikePeople").updateChildValues(dic)
                    self.Hash = self.captionText[sender.tag]._tokens(from: HashtagTokenizer())
                    if self.Hash.isEmpty {
                        self.feeddd()
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
        //좋아요 받습니다~
        //self.feeddd()
        for i in 0..<Token.count {
            let str = Token[i].text.replacingOccurrences(of: "#", with: "")
            let key = ref?.child("HashTagPosts").childByAutoId().key
            if index == 1 { // 저장
                ref?.child("HashTagPosts").child(str).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                    if let item = snapshot.value as? [String : AnyObject] {
                        for(_, value) in item {
                            if self.HomePost[tag].PostId! == value["postID"] as? String {
                                let dic = [key! : (Auth.auth().currentUser?.uid)!]
                                print(snapshot.key)
                                self.ref?.child("HashTagPosts").child(str).child("Posts").child((value["postID"] as? String)!).child("LikePeople").setValue(dic)
                            }
                        }
                        
                    }
                    self.feeddd()
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
                    self.feeddd()
                })
                ref?.removeAllObservers()
            }
        }
    }
    func DateSort() { //날짜 순 정렬 구조체 반환 함수
        if self.HomePost.count == 0 {
            return
        }
        for i in (1..<self.HomePost.count).reversed() {
            for j in 0..<i {
                if self.HomePost[j].timeInterval! < self.HomePost[j+1].timeInterval! { //맨 앞값이 작으면 가장 최근 포스트이기에
                    //print("제일 작다는디?")
                    continue
                }
                else if self.HomePost[j].timeInterval! > self.HomePost[j+1].timeInterval! { //뒤에 값이 작으면
                    let postTemp = self.HomePost[j]
                    self.HomePost[j] = self.HomePost[j+1]
                    self.HomePost[j+1] = postTemp
                }
            }
        }
        DispatchQueue.main.async {
            self.HomeCollection?.reloadData()
        }
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
extension UIImage{
    
    var roundMyImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    func resizeMyImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func squareMyImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.size.width, height: self.size.width))
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.HomePost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.HomePost.count != 0 {
            let cell = self.HomeCollection?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCollectionViewCell
            let dic = self.HomePost[indexPath.row]
            ref?.child("User").child(dic.Id!).child("UserProfile").observe(.value, with: { (snapshot) in
                if let item = snapshot.value as? [String : String] {
                    if item["ProFileImage"] != nil {
                        cell.ProFileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                        dic.userprofileimage = item["ProFileImage"]!
                        if cell.ProFileImage.image != nil {
                            if dic.Id! == self.UserKey {
                                self.barImage = cell.ProFileImage.image!.squareMyImage().resizeMyImage(newWidth: 30).roundMyImage.withRenderingMode(.alwaysOriginal)
                                self.tabBarController?.tabBar.items?[4].image = self.barImage
                            }
                        }
                    } else {
                        cell.ProFileImage.image = UIImage(named: "profile.png")
                        if cell.ProFileImage.image != nil {
                            if dic.Id! == self.UserKey {
                                self.barImage = UIImage(named: "profile.png")!.squareMyImage().resizeMyImage(newWidth: 30).roundMyImage.withRenderingMode(.alwaysOriginal)
                                self.tabBarController?.tabBar.items?[4].image = self.barImage
                            }
                        }
                    }
                }
            })
            cell.ProFileImage.frame.size = CGSize(width: 50, height: 50)
            cell.ProFileImage.layer.borderWidth = 1.0
            cell.ProFileImage.layer.masksToBounds = false
            cell.ProFileImage.layer.cornerRadius = cell.ProFileImage.frame.size.height / 2.0
            cell.ProFileImage.clipsToBounds = true
            cell.ProFileImage.contentMode = .scaleToFill
            cell.Caption.text = "\(dic.username!) : \(dic.caption!)"
            cell.Caption.enabledTypes = [.hashtag, .mention, .url]
            cell.Caption.numberOfLines = 0
            cell.Caption.sizeToFit()
            cell.Caption.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.Caption.handleHashtagTap({ (hashtag) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HashTagView") as! HashTagViewController
                vc.HashTagName = hashtag
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            })
            self.captionText.append(dic.caption!)
            cell.PostImage.sd_setImage(with: URL(string: dic.image!), completed: nil)
            cell.PostImage.isUserInteractionEnabled = true
            cell.PostImage.tag = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap(_:)))
            cell.PostImage.addGestureRecognizer(tap)
            cell.TimeLabel.text = dic.timeAgo
            cell.TimeLabel.font = UIFont(name: "BM DoHyeon OTF", size : 10)!
            cell.TimeLabel.textColor = UIColor.lightGray
            cell.UserName.text = dic.username!
            cell.UserName.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.CommnetBut.tag = indexPath.row
            cell.CommnetBut.addTarget(self, action: #selector(CommentView(_:)), for: .touchUpInside)
            cell.ExceptionBut.tag = indexPath.row
            cell.ExceptionBut.addTarget(self, action: #selector(ExceptionMenu(_:)), for: .touchUpInside)
            cell.ExceptionBut.setImage(UIImage(named: "exception.png"), for: .normal)
            cell.LikeBut.tag = indexPath.row
            cell.LikeBut.addTarget(self, action: #selector(likePressed(_:)), for: .touchUpInside)
            
            //좋아요 체크
            cell.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
            for people in dic.PeopleWhoLike {
                if people == self.UserKey {
                    cell.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                    break
                }
            }
            cell.LikeCountLabel.text = "좋아요 \(dic.PeopleWhoLike.count)개"
            cell.LikeCountLabel.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            return cell
        } else {
            let cell = self.HomeCollection?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCollectionViewCell
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CommonVariable.screenWidth, height: CommonVariable.screenHeight-50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

}
extension HomeViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.presentedViewController?.dismiss(animated: false, completion: nil)
    }
}
