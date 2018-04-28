//
//  PostView11Controller.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 12..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Koloda
import Firebase
import CDAlertView

class PostViewController: UIViewController {
    
    var Kolodaview = KolodaView()
    var Posts = [Post]()
    var Id : String = ""
    var ProFileUrl : String = ""
    var ref : DatabaseReference?
    //var image = [UIImage]()
    //var imageset = Set<UIImage>()
    var Customindex = 1
    var Hash : [AnyToken]!
    var LikeBut = UIButton()
    var index = 0
    var postview = PostView()
    var UserKey : String = (Auth.auth().currentUser?.uid)!
    
    @IBOutlet weak var NextBut: UIButton!
    @IBOutlet weak var PreviousBut: UIButton!
    @IBOutlet weak var LikeCountLabel: UILabel!
    override func viewWillLayoutSubviews() {
        postview.Caption.sizeToFit()
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        
        fetchUser(Id)
        fetchPost()
        LikeCheck()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(Kolodaview)
        self.view.addSubview(LikeBut)
        
        Kolodaview.dataSource = self
        Kolodaview.delegate = self
        Kolodaview.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth / 1.3)
            make.height.equalTo(CommonVariable.screenHeight/1.6)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(100)
        }
        NextBut.snp.makeConstraints { (make) in
            make.left.equalTo(LikeBut.snp.right).offset(30)
            make.top.equalTo(Kolodaview.snp.bottom).offset(20)
        }
        PreviousBut.snp.makeConstraints { (make) in
            make.right.equalTo(LikeBut.snp.left).offset(-30)
            make.top.equalTo(NextBut)
        }
        LikeCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(70)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        LikeCountLabel.adjustsFontSizeToFitWidth = true
        LikeCountLabel.textColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth/10)
            make.height.equalTo(CommonVariable.screenHeight/20)
            make.centerX.equalTo(self.view)
            make.top.equalTo(NextBut)
        }
        LikeBut.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        LikeBut.tintColor = UIColor.white
        //Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PostTable" {
            
            let destination = segue.destination as! PostTableViewController
            destination.Posts = self.Posts[Kolodaview.currentCardIndex]
            self.Kolodaview.resetCurrentCardIndex()
            //destination.MapImage = self.postview.PostImage.image!
            //print(self.Posts[Kolodaview.currentCardIndex].caption!)
        }
    }
 

}
extension PostViewController: KolodaViewDelegate, KolodaViewDataSource {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        return
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //performSegue(withIdentifier: "PostTable", sender: self)
    }
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return Posts.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        postview = Bundle.main.loadNibNamed("PostView", owner: self, options: nil)?.first as! PostView
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserNameTap))
        postview.layer.borderWidth = 1.0
        postview.layer.borderColor = UIColor.black.cgColor
        postview.clipsToBounds = true
        postview.PostImage.sd_setImage(with: URL(string: Posts[index].image!), completed: nil)
        postview.ProFileImage.isUserInteractionEnabled = true
        postview.ProFileImage.sd_setImage(with: URL(string: ProFileUrl), completed: nil)
        postview.ProFileImage.addGestureRecognizer(tap)
        postview.Caption.text = Posts[index].caption!
        postview.Caption.numberOfLines = 0
        postview.Caption.enabledTypes = [.hashtag, .mention, .url]
        postview.Caption.isUserInteractionEnabled = true
        postview.Caption.handleHashtagTap { (hashtag) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HashTagView") as! HashTagViewController
            vc.HashTagName = hashtag
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            }
        postview.Caption.font = UIFont(name: "BM DoHyeon OTF", size : 13)!
        LikeCountLabel.text = "마음에 드신다면 하트를 눌러주세요"

        postview.UserName.isUserInteractionEnabled = true
        if postview.UserName.isUserInteractionEnabled == true {
            postview.UserName.text = Posts[index].username!
            postview.UserName.font = UIFont(name: "BM DoHyeon OTF", size : 13)!
            postview.UserName.addGestureRecognizer(tap)
        }
        postview.TimeLabel.text = Posts[index].timeAgo
        postview.TimeLabel.font = UIFont(name: "BM DoHyeon OTF", size : 13)!
        postview.TimeLabel.textColor = UIColor.lightGray
        postview.TimeLabel.adjustsFontSizeToFitWidth = true
        //버튼 제대로 표시
        postview.CommentBut.addTarget(self, action: #selector(DetailViewPresent), for: .touchUpInside)
        postview.ExceptionBut.tag = index
        postview.ExceptionBut.addTarget(self, action: #selector(ExceptionMenu(_:)), for: .touchUpInside)
        postview.ExceptionBut.tintColor = UIColor.black
        return postview
    }
    
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
//    }
}
extension PostViewController {
    @objc func ExceptionMenu(_ sender : UIButton) {
        let alert = UIAlertController(title: "기타 메뉴", message: nil, preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "신고", style: .default) { (action) in
            self.PostReport(sender.tag)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func PostReport(_ index : Int) { //게시물 신고
        let key = (ref?.child("WholePosts").childByAutoId().key)!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let broadcast = UIAlertAction(title: "허위 게시물입니다.", style: .default) { (action) in
            if self.Posts[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.Posts[index].PostId!).child("Report").updateChildValues([key : "허위 게시물"])
            }
        }
        let unfitness = UIAlertAction(title: "부적절합니다.", style: .default) { (action) in
            if self.Posts[index].Id == self.UserKey { //내가 내 게시물 신고
                print("내꺼같다.")
                return
            } else { //다른 사람 게시물이다.
                print("다른 사람꺼다")
                self.ref?.child("WholePosts").child(self.Posts[index].PostId!).child("Report").updateChildValues([key : "부적절 게시물"])
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
    func LikeCheck() {
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_ ,value) in item {
                        if value["postID"] as? String == self.Posts[self.Kolodaview.currentCardIndex].PostId {
                            print("씨발아")
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
    func HashTagPostLike(_ Token : [AnyToken], _ index : Int) {
            for i in 0..<Token.count {
                let str = Token[i].text.replacingOccurrences(of: "#", with: "")
                let key = ref?.child("HashTagPosts").childByAutoId().key
                if index == 1 { // 저장
                    ref?.child("HashTagPosts").child(str).child("Posts").observe(.childAdded, with: { (snapshot) in
                        if let item = snapshot.value as? [String : String] {
                            
                            if self.Posts[self.Kolodaview.currentCardIndex].PostId == item["postID"] {
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
                                    if value["postID"] as? String == self.Posts[self.Kolodaview.currentCardIndex].PostId {
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
    @objc func likePressed() { //좋아요 눌렀을 때
       let key = ref?.child("HashTagPosts").childByAutoId().key
       let dic = [key! : (Auth.auth().currentUser?.uid)!]
        ref?.child("WholePosts").child(Posts[Kolodaview.currentCardIndex].PostId!).child("LikePeople").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull { //첫 좋아요면 무조건 저장
                self.ref?.child("WholePosts").child(self.Posts[self.Kolodaview.currentCardIndex].PostId!).child("LikePeople").setValue(dic)
                self.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                self.Hash = self.Posts[self.Kolodaview.currentCardIndex].caption!._tokens(from: HashtagTokenizer())
                self.HashTagPostLike(self.Hash, 1)
            } else { //좋아요가 하나라도 존재 할 시
                if let item = snapshot.value as? [String : String] {
                    for (key, value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //좋아요 취소
                            self.ref?.child("WholePosts").child(self.Posts[self.Kolodaview.currentCardIndex].PostId!).child("LikePeople/\(key)").removeValue() // WholePosts 데이터 삭제
                            self.LikeBut.setImage(UIImage(named: "unlike.png"), for: .normal)
                            if self.Hash != nil {
                               self.HashTagPostLike(self.Hash, 0)
                            }
                        } else { //버튼을 누른 사용자의 데이터가 없다. 즉, 이 글 좋아요
                            self.ref?.child("WholePosts").child(self.Posts[self.Kolodaview.currentCardIndex].PostId!).child("LikePeople").setValue(dic)
                            self.LikeBut.setImage(UIImage(named: "like.png"), for: .normal)
                            self.Hash = self.Posts[self.Kolodaview.currentCardIndex].caption!._tokens(from: HashtagTokenizer())
                            if self.Hash != nil {
                               self.HashTagPostLike(self.Hash, 1)
                            }

                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
    }
    func fetchPost(){
        self.Posts.removeAll()
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let item = snapshot.value as! [String : AnyObject]
            
            for (_, value) in item {
                if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                    let post = Post()
                    
                    if ID == self.Id { // 그 당사자의 아이디와 일치하는 게시물들만 포스트에 넣기
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
                            self.Posts.append(post)
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
                            self.Posts.append(post)
                        }
                    }
                    if self.Posts.count == Int(snapshot.childrenCount) {// 게시물 다 땃어 이제 날짜순 정렬해서 리로드
                        self.DateFetch()
                    }
                }
            }
            
        })
        ref?.removeAllObservers()

    }
    func fetchUser(_ id : String) {
        
        ref?.child("User").child(id).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["ProFileImage"] != nil {
                   self.ProFileUrl = item["ProFileImage"]!
                }
            }
        })
        ref?.removeAllObservers()
    }
    
    @IBAction func Previous(_ sender: UIButton) {
        Kolodaview.revertAction()
        if self.Kolodaview.currentCardIndex == 0 {
            return
        } else {
            LikeCheck()
        }
    }
    @IBAction func Next(_ sender: UIButton) {
        Kolodaview.swipe(.right, force: false)
        if self.Kolodaview.currentCardIndex == self.Posts.count {
            return
        } else {
            LikeCheck()
        }
    }
    @objc func UserNameTap() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProFile") as! UserProFileViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.UserKey = self.Id
        present(vc, animated: true, completion: nil)
    }
    @objc func DetailViewPresent() { // 댓글 창으로
        performSegue(withIdentifier: "PostTable", sender: self)
    }
    func DateSort() { //날짜 순 정렬 구조체 반환 함수
        for i in (1..<self.Posts.count).reversed() {
            for j in 0..<i {
                if self.Posts[j].timeInterval! < self.Posts[j+1].timeInterval! { //맨 앞값이 작으면 가장 최근 포스트이기에
                    print("제일 작다는디?")
                    continue
                }
                else if self.Posts[j].timeInterval! > self.Posts[j+1].timeInterval! { //뒤에 값이 작으면
                    let postTemp = self.Posts[j]
                    self.Posts[j] = self.Posts[j+1]
                    self.Posts[j+1] = postTemp
                }
            }
        }
        self.Kolodaview.reloadData()
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
        for i in 0..<self.Posts.count {
            let Date = format.string(from: date)
            let caption = self.Posts[i].timeAgo!.components(separatedBy: " ").map{ String($0) }
            let StartDate = format.date(from: Date)!.addingTimeInterval(32400)
            let endDate = format.date(from: caption[0])!.addingTimeInterval(32400) //게시물 작성한 날짜 일자로 계산
            let interval = StartDate.timeIntervalSince(endDate)
            if interval < 1 { // 하루 미만이면
                let start = CommonVariable.formatter.date(from: CommonVariable.formatter.string(from: date))!.addingTimeInterval(32400)
                let end = CommonVariable.formatter.date(from: self.Posts[i].timeAgo!)!.addingTimeInterval(32400)
                let subinterval = Int(start.timeIntervalSince(end) / 60.0) //분 단위 계산
                self.Posts[i].timeInterval = Int(subinterval * 60) // 초 차이
                print(subinterval)
                if subinterval > 60 { // 1시간 이상
                   self.Posts[i].timeAgo = "\(Int(subinterval / 60))시간 전"
                } else if subinterval < 60 {
                    self.Posts[i].timeAgo = "\(subinterval)분 전"
                } else if subinterval == 0 {
                    self.Posts[i].timeAgo = "방금 전"
                }
                //print(interval)
                self.Posts[i].timeAgo = "\(subinterval)분 전"
                continue
            }
            self.Posts[i].timeInterval = Int(interval)
        }
        DateSort()
        return
    }
}
