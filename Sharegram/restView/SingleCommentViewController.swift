//
//  SingleCommentViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 13..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import ActiveLabel
import CDAlertView

class SingleCommentViewController: UIViewController { //단일 뷰 의 댓글 창
    
    @IBOutlet var navi: UINavigationBar!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var CommentTable: UITableView!
    
    
    var ref : DatabaseReference?
    /////////////User//
    var UserPost = Post()
    //////////////////
    ///////////PostHeaderview//
    var PostCaptionView = UIView() // 작성자 텍스트뷰 헤더뷰
    var PostUserProFileImage = UIImageView()
    var PostUserName = UILabel()
    var PostUserCaption = ActiveLabel()
    ////////////////////////
    var CommentView = UIView() //댓글 뷰 = 테이블 풋
    var CommentBut = UIButton()
    var CommentProfileImage = UIImageView()
    var CommentTextfield = UITextField()
    var Profileimage = ""
    var CommentName = "" //댓글 이름
    var CommentArray : [String : String] = [:]
    var CommentList : [[String : String]] = [[:]]
    var width = CommonVariable.screenWidth
    var height = CommonVariable.screenHeight
    override func viewWillLayoutSubviews() {
        self.PostUserName.sizeToFit()
        self.PostUserCaption.sizeToFit()
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        FetchUser()
        FetchComment()
        
        navi.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(20)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        CommentTable.snp.makeConstraints { (make) in
            make.top.equalTo(navi.snp.bottom).offset(5)
            make.width.equalTo(width)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        CommentTable.estimatedRowHeight = 80
        CommentTable.rowHeight = UITableViewAutomaticDimension
        CommentView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height/8))
        PostCaptionView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height/3.5))
        
        PostCaptionView.addSubview(PostUserProFileImage)
        PostCaptionView.addSubview(PostUserName)
        PostCaptionView.addSubview(PostUserCaption)
        
        PostUserProFileImage.snp.makeConstraints { (make) in
            make.width.equalTo(width/5)
            make.height.equalTo(PostCaptionView.bounds.height/3)
            make.left.equalTo(PostCaptionView.snp.left).offset(10)
            make.top.equalTo(PostCaptionView.snp.top).offset(10)
        }
        PostUserProFileImage.sd_setImage(with: URL(string: self.UserPost.userprofileimage!), completed: nil)
        PostUserProFileImage.layer.borderWidth = 1
        PostUserProFileImage.layer.borderColor = UIColor.lightGray.cgColor
        PostUserProFileImage.contentMode = .scaleToFill
        
        PostUserName.snp.makeConstraints { (make) in
            make.width.equalTo(width/2)
            make.height.equalTo(height/30)
            make.left.equalTo(PostUserProFileImage.snp.right).offset(10)
            make.top.equalTo(PostUserProFileImage)
        }
        PostUserName.text = UserPost.username
        
        PostUserCaption.snp.makeConstraints { (make) in
            make.width.equalTo(width - PostUserProFileImage.bounds.width)
            make.height.lessThanOrEqualTo(PostCaptionView.bounds.height-10-PostUserName.bounds.height)
            make.left.equalTo(PostUserName)
            make.top.equalTo(PostUserName.snp.bottom)
        }
        PostUserCaption.numberOfLines = 0
        PostUserCaption.text = UserPost.caption!
        PostUserCaption.enabledTypes = [.hashtag, .mention, .url]
        
        CommentView.addSubview(CommentProfileImage)
        CommentView.addSubview(CommentBut)
        CommentView.addSubview(CommentTextfield)
        CommentView.layer.borderWidth = 1.0
        CommentView.layer.borderColor = UIColor.lightGray.cgColor
        CommentView.backgroundColor = UIColor.white
        CommentProfileImage.snp.makeConstraints { (make) in
            make.width.equalTo(CommentView.bounds.width/5)
            make.height.equalTo(CommentView.bounds.height/1.3)
            make.centerY.equalTo(CommentView)
        }
        CommentProfileImage.layer.cornerRadius = 30
        CommentProfileImage.sizeToFit()
        CommentProfileImage.clipsToBounds = true
        CommentProfileImage.layer.borderWidth = 1.0
        CommentProfileImage.layer.borderColor = UIColor.white.cgColor
        CommentTextfield.snp.makeConstraints { (make) in
            make.width.equalTo(CommentView.bounds.width/1.6)
            make.height.equalTo(CommentView.bounds.height/2.5)
            make.left.equalTo(CommentProfileImage.snp.right).offset(10)
            make.centerY.equalTo(CommentView)
        }
        CommentTextfield.placeholder = "  댓글을 입력하세요."
        CommentTextfield.borderStyle = .none
        CommentTextfield.layer.cornerRadius = 20.0
        CommentTextfield.layer.borderWidth = 1.0
        CommentTextfield.layer.borderColor = UIColor.lightGray.cgColor
        CommentTextfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        CommentTextfield.leftViewMode = .always
        
        CommentBut.snp.makeConstraints { (make) in
            make.width.equalTo(CommentView.bounds.width/7)
            make.height.equalTo(CommentView.bounds.height/3)
            make.left.equalTo(CommentTextfield.snp.right).offset(5)
            make.centerY.equalTo(CommentView)
        }
        CommentBut.setImage(UIImage(named: "edit.png"), for: .normal)
        CommentBut.addTarget(self, action: #selector(SetComment), for: .touchUpInside)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        PostUserProFileImage.layer.cornerRadius = 30
        PostUserProFileImage.clipsToBounds = true
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
extension SingleCommentViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = self.CommentList[indexPath.row]
        print(indexPath.row)
        if dic["Type"] == "Comment" {
            print(dic)
            let cell = Bundle.main.loadNibNamed("CommentTableViewCell", owner: self, options: nil)?.first as! CommentTableViewCell
            cell.ProFileImage.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
            cell.ProFileImage.layer.cornerRadius = 15.0
            cell.ProFileImage.clipsToBounds = true
            cell.Comment.text = "\(dic["Author"]!) \(dic["Comment"]!)"
            cell.Comment.numberOfLines = 0
            cell.Comment.enabledTypes = [.hashtag, .mention, .url]
            cell.Comment.handleMentionTap { (hashtag) in
                let alertview = CDAlertView(title: "현재 위치는 ", message: "다른 위치를 원하십니까?", type: CDAlertViewType.notification)
                let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                    return
                })
                alertview.add(action: OKAction)
                alertview.show()
                return
            }
            cell.Comment.sizeToFit()
            cell.ReplyBut.tag = indexPath.row
            cell.ReplyBut.setTitle("답글 달기", for: .normal)
            cell.ReplyBut.tintColor = UIColor.lightGray
            cell.ReplyBut.addTarget(self, action: #selector(SetCommentReply), for: .touchUpInside)
            cell.TimeAgo.text = dic["Date"]
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("CommentReplyTableViewCell", owner: self, options: nil)?.first as! CommentReplyTableViewCell
            cell.ProFileImage.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
            cell.ProFileImage.layer.cornerRadius = 15.0
            cell.ProFileImage.clipsToBounds = true
            cell.Comment.text = "\(dic["Author"]!) \(dic["Reply"]!)"
            cell.Comment.numberOfLines = 0
            cell.Comment.enabledTypes = [.hashtag, .mention, .url]
            cell.Comment.handleMentionTap { (hashtag) in
                let alertview = CDAlertView(title: "현재 위치는 ", message: "다른 위치를 원하십니까?", type: CDAlertViewType.notification)
                let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                    return
                })
                alertview.add(action: OKAction)
                alertview.show()
                return
            }
            cell.Comment.sizeToFit()
            cell.TimeAgo.text = dic["Date"]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return CommentView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return height/8
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return PostCaptionView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.view.bounds.height/3.5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension SingleCommentViewController {
    func FetchUser() { //프로필 따오기 댓글창 형성
        ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.CommentProfileImage.image = UIImage(named: "Man.png")
            } else {
                if let item = snapshot.value as? [String : String] {
                    if item["ProFileImage"]! == nil {
                        self.CommentProfileImage.image = UIImage(named: "Man.png")
                    } else {
                        self.CommentProfileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                    }
                    self.Profileimage = item["ProFileImage"]!
                    self.CommentName = item["사용자 명"]!
                }
            }
        })
        ref?.removeAllObservers()
    }
    func FetchComment() { // 댓글 가져오기
        self.CommentList.removeAll()
        ref?.child("Comment").child(UserPost.PostId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
                return
            } else {
                if let item = snapshot.value as? [String : AnyObject] {
                    for (_,value) in item {
                        if let dic = value as? [String : AnyObject] { //기존 댓글 한 번 따고
                            var list = dic
                            list.removeValue(forKey: "Reply")
                            print(list)
                            self.CommentList.append(list as! [String : String])
                            print("들오와")
                        }
                        if value["Reply"] as? [String : AnyObject] != nil { //댓글에 리댓글이 있으면
                            if let dic = value["Reply"] as? [String : AnyObject] {
                                for (_, value) in dic {
                                    if let dic = value as? [String : String] {
                                        self.CommentList.append(dic)
                                    }
                                }
                            }
                        }
                    }
                    self.CommentTable.reloadData()
                }
            }
        })
        ref?.removeAllObservers()
    }
    @objc func SetComment() { //댓글 저장
        print("??????")
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_KR")
        let Date = CommonVariable.formatter.string(from: CommonVariable.date)
        let key = (ref?.child("Comment").child(UserPost.PostId!).childByAutoId().key)!
        if !(self.CommentTextfield.text!.isEmpty) {
            self.CommentArray = ["ProFileImage" : self.Profileimage, "PostKey" : UserPost.PostId!, "Comment" : self.CommentTextfield.text!, "Author" : self.CommentName, "Date" : Date, "Type" : "Comment", "CommentKey" : key]
            ref?.child("Comment").child(UserPost.PostId!).updateChildValues([key : self.CommentArray])
            self.CommentTextfield.text = ""
            FetchComment()
        }
    }
    @objc func SetCommentReply(_ sender : UIButton) { //리댓글 저장
        let tag = sender.tag
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_KR")
        let Date = CommonVariable.formatter.string(from: CommonVariable.date)
        let key = (ref?.child("Comment").child(UserPost.PostId!).child(self.CommentList[tag]["CommentKey"]!).childByAutoId().key)!
        
        let alert = CDAlertView(title: "\(self.CommentList[tag]["Author"]!)님에게 답글", message: nil, type: CDAlertViewType.notification)
        alert.isTextFieldHidden = false
        print(alert.textFieldText!)
        let write = CDAlertViewAction(title: "작성", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white) { (action) in
            let ReplyArray = ["Author" : self.CommentName, "Date" : Date, "ReplyKey" : key, "Type" : "Reply", "ProFileImage" : self.Profileimage, "Reply" : alert.textFieldText!, "PostKey" : self.UserPost.PostId!]
            self.ref?.child("Comment").child(self.UserPost.PostId!).child(self.CommentList[tag]["CommentKey"]!).child("Reply").updateChildValues([key : ReplyArray])
            return
        }
        let cancel = CDAlertViewAction(title: "취소", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white) { (action) in
            return
        }
        alert.add(action: write)
        alert.add(action: cancel)
        alert.show()
        
        return
    }
}
extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.size.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}
