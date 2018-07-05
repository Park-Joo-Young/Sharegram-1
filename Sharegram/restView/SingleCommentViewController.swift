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
import Popover

protocol GetUserName {
    func getName(_ name : String)
}
class SingleCommentViewController: UIViewController, GetUserName { //단일 뷰 의 댓글 창
    
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
    var Mentionview = UITableView()
    var strr : String = ""
    var result : [[String : String]] = []
    var resultString : String = ""
    var username : [String] = []
    fileprivate var texts = ["Edit", "Delete", "Report"]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.0))
    ]
    override func viewWillLayoutSubviews() {
        self.PostUserName.sizeToFit()
        self.PostUserCaption.sizeToFit()
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        FetchUser()
        FetchComment()
        //observerUser()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CommentTable.tag = 0
        
        self.Mentionview.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "usercell")
        self.Mentionview.tag = 1
        navi.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(20)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        navi.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        navi.tintColor = UIColor.black
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
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.equalTo(PostCaptionView.snp.left).offset(10)
            make.top.equalTo(PostCaptionView.snp.top).offset(10)
        }
        
        if self.UserPost.userprofileimage != nil {
           PostUserProFileImage.sd_setImage(with: URL(string: self.UserPost.userprofileimage!), completed: nil)
        } else {
            PostUserProFileImage.image = UIImage(named: "profile.png")
        }
        PostUserProFileImage.frame.size = CGSize(width: 50, height: 50)
        PostUserProFileImage.layer.masksToBounds = false
        PostUserProFileImage.layer.cornerRadius = self.PostUserProFileImage.frame.size.height / 2.0
        PostUserProFileImage.clipsToBounds = true
        PostUserProFileImage.contentMode = .scaleToFill
        
        PostUserName.snp.makeConstraints { (make) in
            make.width.equalTo(width/2)
            make.height.equalTo(height/30)
            make.left.equalTo(PostUserProFileImage.snp.right).offset(10)
            make.top.equalTo(PostUserProFileImage)
        }
        PostUserName.text = UserPost.username
        PostUserName.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        PostUserCaption.snp.makeConstraints { (make) in
            make.width.equalTo(width - PostUserProFileImage.bounds.width)
            make.height.lessThanOrEqualTo(PostCaptionView.bounds.height-10-PostUserName.bounds.height)
            make.left.equalTo(PostUserName)
            make.top.equalTo(PostUserName.snp.bottom)
        }
        PostUserCaption.numberOfLines = 0
        PostUserCaption.text = UserPost.caption!
        PostUserCaption.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        PostUserCaption.enabledTypes = [.hashtag, .mention, .url]
        
        CommentView.addSubview(CommentProfileImage)
        CommentView.addSubview(CommentBut)
        CommentView.addSubview(CommentTextfield)
        CommentView.layer.borderWidth = 1.0
        CommentView.layer.borderColor = UIColor.lightGray.cgColor
        CommentView.backgroundColor = UIColor.white
        CommentProfileImage.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerY.equalTo(CommentView)
        }
        CommentProfileImage.frame.size = CGSize(width: 50, height: 50)
        CommentProfileImage.layer.cornerRadius = CommentProfileImage.frame.size.height / 2.0
        CommentProfileImage.layer.masksToBounds = false
        CommentProfileImage.clipsToBounds = true
        CommentProfileImage.contentMode = .scaleToFill
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
        CommentTextfield.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        CommentTextfield.delegate = self
        CommentTextfield.tag = 0
        CommentBut.snp.makeConstraints { (make) in
            make.width.equalTo(CommentView.bounds.width/7)
            make.height.equalTo(CommentView.bounds.height/3)
            make.left.equalTo(CommentTextfield.snp.right).offset(5)
            make.centerY.equalTo(CommentView)
        }
        CommentBut.setImage(UIImage(named: "edit.png"), for: .normal)
        CommentBut.addTarget(self, action: #selector(SetComment), for: .touchUpInside)
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
        if dic["Type"] == "Comment" {
                print(dic)
                let cell = Bundle.main.loadNibNamed("CommentTableViewCell", owner: self, options: nil)?.first as! CommentTableViewCell
                cell.ProFileImage.frame.size = CGSize(width: 50, height: 50)
                if dic["ProFileImage"] != nil {
                    cell.ProFileImage.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
                } else {
                    cell.ProFileImage.image = UIImage(named: "profile.png")
                }
                cell.ProFileImage.layer.masksToBounds = false
                cell.ProFileImage.layer.cornerRadius = cell.ProFileImage.frame.size.height / 2.0
                cell.ProFileImage.clipsToBounds = true
                cell.ProFileImage.contentMode = .scaleToFill
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
                cell.Comment.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
                cell.ReplyBut.tag = indexPath.row
                cell.ReplyBut.setTitle("답글 달기", for: .normal)
                cell.ReplyBut.tintColor = UIColor.lightGray
                cell.ReplyBut.addTarget(self, action: #selector(SetCommentReply), for: .touchUpInside)
                cell.ReplyBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 12)!
                cell.TimeAgo.text = dic["Date"]
                cell.TimeAgo.font = UIFont(name: "BM DoHyeon OTF", size : 10)!
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("CommentReplyTableViewCell", owner: self, options: nil)?.first as! CommentReplyTableViewCell
                cell.ProFileImage.frame.size = CGSize(width: 50, height: 50)
                if dic["ProFileImage"] != nil {
                    cell.ProFileImage.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
                } else {
                    cell.ProFileImage.image = UIImage(named: "profile.png")
                }
                cell.ProFileImage.layer.masksToBounds = false
                cell.ProFileImage.layer.cornerRadius = cell.ProFileImage.frame.size.height / 2.0
                cell.ProFileImage.clipsToBounds = true
                cell.ProFileImage.contentMode = .scaleToFill
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
                cell.Comment.font = UIFont(name: "BM DoHyeon OTF", size : 15)
                cell.TimeAgo.text = dic["Date"]
                cell.TimeAgo.font = UIFont(name: "BM DoHyeon OTF", size : 10)
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { //삭제~
            let dic = self.CommentList[indexPath.row]
        
            ref?.child("Comment").child(dic["PostKey"]!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let item = snapshot.value as? [String : AnyObject] {
                    for (key, _) in item {
                        if key == dic["CommentKey"] { //똑같은 댓글을 찾았다. 삭제
                            print("삭제 됐는데[?")
                            self.ref?.child("Comment/\(dic["PostKey"]!)/\(key)").removeValue()
                            self.CommentList.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            print("삭제 됐는데[?")
                        }
                    }
                }
                
                self.FetchComment()
            })
            ref?.removeAllObservers()
        }
    }
}
extension SingleCommentViewController : UIPopoverPresentationControllerDelegate {
    func getName(_ name: String) {
        let item = self.CommentTextfield.text!.components(separatedBy: "@")
        let trim = self.CommentTextfield.text!.replacingOccurrences(of: item.last!, with: "", options: .caseInsensitive, range: nil)
        self.CommentTextfield.text = trim + name + " "
    }
    func MentionTable() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserList") as! UserListViewController
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: CommonVariable.screenWidth, height: 200)
        vc.delegate = self
        vc.List = self.result
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .down
        popover.sourceView = CommentView
        popover.sourceRect = CommentView.bounds
        self.present(vc, animated: true, completion: nil)
    }
    func FetchUser() { //프로필 따오기 댓글창 형성
        ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.CommentProfileImage.image = UIImage(named: "Man.png")
            } else {
                if let item = snapshot.value as? [String : String] {
                    if item["ProFileImage"] != nil {
                        self.CommentProfileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                        
                    } else {
                        self.CommentProfileImage.image = UIImage(named: "profile.png")
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
        alert.textFieldText = "@" + self.CommentList[tag]["Author"]!
        print(alert.textFieldText!)
        let write = CDAlertViewAction(title: "작성", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white) { (action) in
            let ReplyArray = ["Author" : self.CommentName, "Date" : Date, "ReplyKey" : key, "Type" : "Reply", "ProFileImage" : self.Profileimage, "Reply" : alert.textFieldText!, "PostKey" : self.UserPost.PostId!]
            self.ref?.child("Comment").child(self.UserPost.PostId!).child(self.CommentList[tag]["CommentKey"]!).child("Reply").updateChildValues([key : ReplyArray])
            self.FetchComment()
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
    func CreateAutoCompleteMentionTable() { // 해쉬태그 자동완성 팝업 뷰
        self.Mentionview = UITableView(frame: CGRect(x: 0, y: 0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight/3))
        self.Mentionview.delegate = self
        self.Mentionview.dataSource = self
        self.Mentionview.isScrollEnabled = false
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
            print("willShowHandler")
        }
        self.popover.didShowHandler = {
            print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            self.result.removeAll()
            print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            self.result.removeAll()
            print("didDismissHandler")
        }
    }
    func observerUser(_ str : String) {
        self.result.removeAll()
        ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(_, value) in item {
                    if let user = value["UserProfile"] as? [String : String] {
                        if user["사용자 명"]!.contains(str) {
                            self.result.append(user)
                            continue
                        }
                    }
                }
            }
            if self.result.count != 0 {
               self.MentionTable()
            }
            
        })
        ref?.removeAllObservers()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
//extension SingleCommentViewController : UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.result.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        observerData()
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
//        cell.imageView?.image = UIImage(named: "HashTag.png")
//        cell.textLabel?.text = self.result[indexPath.row]
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = self.writeDescription.text.components(separatedBy: "@")
//        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
//        let selectedText = selectedCell.textLabel?.text as String!
//        let selected = selectedText?.replacingOccurrences(of: "@", with: "")
//        let trim = self.writeDescription.text.replacingOccurrences(of: item.last!, with: "", options: .caseInsensitive, range: nil)
//        self.writeDescription.text = trim + selected! + " "
//        self.popover.dismiss()
//        self.result.removeAll()
//    }
//}
extension SingleCommentViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            print("들어옴")
            strr = self.CommentTextfield.text! //현재 쓰는 댓글의 텍스트 바당와서
            let mentionitems = strr.components(separatedBy: "@")
            if mentionitems.count > 1 {
                self.observerUser(mentionitems.last!)
                print(mentionitems.last!)
            }
        }
        if (string == "\n") {
            textField.endEditing(true)
            return false
        }
        return true
    }
}
extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.size.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}
