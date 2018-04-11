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
    @IBOutlet weak var NextBut: UIButton!
    @IBOutlet weak var PreviousBut: UIButton!
    @IBOutlet weak var LikeCountLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
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
        let color = UIColor(red: 75/255, green: 76/255, blue: 76/255, alpha: 1)
        self.view.backgroundColor = color
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth/10)
            make.height.equalTo(CommonVariable.screenHeight/20)
            make.centerX.equalTo(self.view)
            make.top.equalTo(NextBut)
        }
        LikeBut.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        fetchUser(Id)
        fetchPost()

    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
            //destination.MapImage = self.postview.PostImage.image!
            //print(self.Posts[Kolodaview.currentCardIndex].caption!)
        }
    }
 

}
extension PostViewController: KolodaViewDelegate, KolodaViewDataSource {
//    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//        return
//    }
    
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
        self.index = index
        if index == 0 {
            LikeCheck()
        }
        let postview = Bundle.main.loadNibNamed("PostView", owner: self, options: nil)?.first as! PostView
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserNameTap))
        postview.layer.borderWidth = 1.0
        postview.layer.borderColor = UIColor.black.cgColor
        postview.layer.cornerRadius = postview.frame.height / 25.0
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
            let alertview = CDAlertView(title: "현재 위치는 ", message: "다른 위치를 원하십니까?", type: CDAlertViewType.notification)
            let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                return
            })
            alertview.add(action: OKAction)
            alertview.show()
            return
        }
        if Posts[index].numberOfLikes == "0" {
            LikeCountLabel.text = "마음에 드신다면 하트를 눌러주세요"
        } else {
            LikeCountLabel.text = "좋아요" + Posts[index].numberOfLikes! + "개"
        }
        postview.UserName.isUserInteractionEnabled = true
        if postview.UserName.isUserInteractionEnabled == true {
            postview.UserName.text = Posts[index].username!
            postview.UserName.addGestureRecognizer(tap)
        }
        postview.TimeLabel.text = "1시간 전"
        postview.TimeLabel.textColor = UIColor.lightGray
        //버튼 제대로 표시
        postview.CommentBut.addTarget(self, action: #selector(DetailViewPresent), for: .touchUpInside)
        return postview
    }
    
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
//    }
}
extension PostViewController {
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
                            print("좋아요가 아무것도 없습니다.")
                        } else {
                            if let item = snapshot.value as? [String : AnyObject] {
                                for (key , value) in item {
                                    if value["postID"] as? String == self.Posts[self.Kolodaview.currentCardIndex].PostId {
                                        for (key1 , value1) in (value["LikePeople"] as? [String : String])! {
                                            if (Auth.auth().currentUser?.uid)! == value1 { // 사용자가 눌렀을 때 값이 안에 있다면 삭제를 시킨다.
                                                self.ref?.child("HashTagPosts").child(str).child("Posts").child(key).child("LikePeople/\(key1)").removeValue()
                                            }
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
                if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let Like = value["Like"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String , let latitude = value["latitude"] as? String, let longitude = value["longitude"] as? String {
                    let post = Post()
                    
                    if ID == self.Id { // 그 당사자의 아이디와 일치하는 게시물들만 포스트에 넣기
                        if value["latitude"] == nil && value["longitude"] == nil { //위치가 없으면
                            post.caption = Description
                            post.Id = ID
                            post.image = image
                            post.lat = 0
                            post.lon = 0
                            post.numberOfLikes = Like
                            post.username = Author
                            post.PostId = postID
                            post.timeAgo = Date
                            self.Posts.append(post)
                        } else {
                            post.caption = Description
                            post.Id = ID
                            post.image = image
                            post.lat = Double(latitude)
                            post.lon = Double(longitude)
                            post.numberOfLikes = Like
                            post.username = Author
                            post.PostId = postID
                            post.timeAgo = Date
                            self.Posts.append(post)
                        }
                    }
                    if self.Posts.count == Int(snapshot.childrenCount) {// 게시물 다 땃어 이제 날짜순 정렬해서 리로드
                        self.DateSort(self.Posts)
                        //self.Kolodaview.reloadData()
                    }
                }
            }
            
        })
        ref?.removeAllObservers()

    }
    func fetchUser(_ id : String) {
        
        ref?.child("User").child(id).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                self.ProFileUrl = item["ProFileImage"]!
                //self.Ko.reloadData()
            }
        })
        ref?.removeAllObservers()
    }
    
    @IBAction func Previous(_ sender: UIButton) {
        Kolodaview.revertAction()
        LikeCheck()
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
    func DateSort(_ post : [Post]) {
        let date = Date()
        let format = DateFormatter()

        TimeZone.ReferenceType.default = TimeZone(abbreviation: "KST")!
        format.dateFormat = "yyyy-MM-dd"
        format.timeZone = TimeZone.ReferenceType.default
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        //CommonVariable.formatter.locale = Locale(identifier: "ko_kr")
        //CommonVariable.formatter.timeZone = TimeZone.init(abbreviation: "KST")
        for i in 0..<post.count {
            let Date = format.string(from: date)
            //print(Date)
            let caption = post[i].timeAgo!.components(separatedBy: " ").map{ String($0) }
            let StartDate = format.date(from: Date)!.addingTimeInterval(32400)
            let endDate = format.date(from: caption[0])!.addingTimeInterval(32400) //게시물 작성한 날짜
            let interval = StartDate.timeIntervalSince(endDate) / 86400
            print(interval)
        }
    }
}
