//
//  PostTableViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 14..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SnapKit
import CDAlertView
import CoreLocation

class PostTableViewController: UITableViewController { //댓글창과 지도를 보이기 위함.
    var Posts = Post()
    var PostImageView = UIImageView()
    var button = UIButton()
    var item = [MTMapPOIItem]() // 마커
    var MapImage : UIImage! // 맵 이미지
    var MapView = UIView() // 맵 뷰
    var Map = MTMapView() // 맵
    var CommentView = UIView()
    var CommentBut = UIButton()
    var CommentProfileImage = UIImageView()
    var CommentTextfield = UITextField()
    var Profileimage = ""
    var CommentName = "" //댓글 이름
    var CommentArray : [String : String] = [:]
    var CommentList : [[String : String]] = [[:]]
    var ref : DatabaseReference?
    var DistanceArray : [[String : String]] = []
    var PostLocation = CLLocation()
    
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        FetchUser()
        FetchComment()
        PostLocation = CLLocation(latitude: Posts.lat!, longitude: Posts.lon!)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension

        
        PostImageView.sd_setImage(with:URL(string: Posts.image!), completed: nil)
        MapImage = PostImageView.image
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        MapImage.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        MapImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        CommentView = UIView(frame: CGRect(x: 0, y: 0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight/8))
        MapView = UIView(frame: CGRect(x: 0, y: 0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight/3.5))
        MapView.addSubview(Map)
        Map.snp.makeConstraints { (make) in
            make.size.equalTo(MapView)
            make.left.equalTo(MapView)
            make.right.equalTo(MapView)
            make.top.equalTo(MapView)
            make.bottom.equalTo(MapView)
        }
        if Posts.lat != nil { //위치 정보가 존재하면 맵을 불러옮
            print(Posts.lat)
            Map.delegate = self
            Map.baseMapType = .standard
            Map.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: Posts.lat!, longitude: Posts.lon!)), zoomLevel: 0, animated: false)
            if self.MapImage != nil {
                item.append(poiItem(latitude: Posts.lat!, longitude: Posts.lon!))
            } else {
                Map.baseMapType = .hybrid
            }
            
            Map.addPOIItems(item)
            print(Map.mapCenterPoint.mapPointGeo())
        } else {
            print("tlqkf")
            Map.baseMapType = .hybrid
        }
        
        
        
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
        CommentProfileImage.layer.cornerRadius = 20
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
        //self.navigationController?.isNavigationBarHidden = true
        //self.navigationItem.title = Posts.username!
        UINavigationBar.appearance().barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black

        
        //tableView.addSubview(CommentView)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //FetchComment()
        return CommentList.count
    }

    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return CommentView
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CommonVariable.screenHeight/8
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return MapView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.view.bounds.height/3.5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        // Configure the cell...
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! DistanceViewController
        destination.PostLocation = self.PostLocation
    }
 

}
extension PostTableViewController : MTMapViewDelegate, UINavigationControllerDelegate {
    func poiItem(latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()

        item.markerType = .customImage
        item.customImage = MapImage
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)    // 마커 위치 조정
        return item
    }
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        print("시발 여길 왜 누르세요!!!!@!!")
    }
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DistanceView") as! DistanceViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.PostLocation = self.PostLocation
        present(vc, animated: true, completion: nil)
        return true
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.viewWillAppear(true)
    }
}
extension PostTableViewController {
    func FetchComment() { // 댓글 가져오기
        self.CommentList.removeAll()
        ref?.child("Comment").child(self.Posts.PostId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
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
                    self.tableView.reloadData()
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
        let key = (ref?.child("Comment").child(self.Posts.PostId!).childByAutoId().key)!
        if !(self.CommentTextfield.text!.isEmpty) {
            self.CommentArray = ["ProFileImage" : self.Profileimage, "PostKey" : self.Posts.PostId!, "Comment" : self.CommentTextfield.text!, "Author" : self.CommentName, "Date" : Date, "Type" : "Comment", "CommentKey" : key]
            ref?.child("Comment").child(self.Posts.PostId!).updateChildValues([key : self.CommentArray])
            self.CommentTextfield.text = ""
            FetchComment()
        }
    }
    @objc func SetCommentReply(_ sender : UIButton) { //리댓글 저장
        let tag = sender.tag
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_KR")
        let Date = CommonVariable.formatter.string(from: CommonVariable.date)
        let key = (ref?.child("Comment").child(self.Posts.PostId!).child(self.CommentList[tag]["CommentKey"]!).childByAutoId().key)!

        let alert = CDAlertView(title: "\(self.CommentList[tag]["Author"]!)님에게 답글", message: nil, type: CDAlertViewType.notification)
        alert.isTextFieldHidden = false
        print(alert.textFieldText!)
        let write = CDAlertViewAction(title: "작성", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white) { (action) in
            let ReplyArray = ["Author" : self.CommentName, "Date" : Date, "ReplyKey" : key, "Type" : "Reply", "ProFileImage" : self.Profileimage, "Reply" : alert.textFieldText!, "PostKey" : self.Posts.PostId!]
            self.ref?.child("Comment").child(self.Posts.PostId!).child(self.CommentList[tag]["CommentKey"]!).child("Reply").updateChildValues([key : ReplyArray])
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
    func FetchUser() { //프로필 따오기 댓글창
        ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                self.CommentProfileImage.image = UIImage(named: "Man.png")
            } else {
                if let item = snapshot.value as? [String : String] {
                    self.CommentProfileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                    self.Profileimage = item["ProFileImage"]!
                    self.CommentName = item["사용자 명"]!
                }
            }
        })
        ref?.removeAllObservers()
    }
    
}

