//
//  WriteViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 1. 15..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import Popover

class WriteViewController: UIViewController, GetAccurateLocation {
    func getLocation(_ lat: Double, _ lon: Double) {
        self.object.lat = lat
        self.object.lon = lon
        print(self.object.lat)
        print(self.object.lon)
    }
    
    var writeImage : UIImage!
    var baseString : String! // 이미지 데이터 변환 포맷
    var object = variable()
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    var PostArray : [String : String] = [:]
    var Hash : [AnyToken]!
    var HashTagArray : [String] = []
    var strr : String = ""
    var stringArray : [String] = []
    var result : [String] = []
    var resultString : String = ""
    var HashTagview = UITableView()
    var key : String!
    fileprivate var texts = ["Edit", "Delete", "Report"]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.0))
    ]
    
    @IBOutlet weak var writeimageView: UIImageView!
    @IBOutlet weak var writeDescription: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var label1: UILabel!
    @IBOutlet weak var LocationSwitch: UISwitch!
    @IBOutlet var LocationSet: UIButton!
    @IBOutlet weak var writeBut: UIButton!
    @IBAction func ActBut(_ sender: UIButton) { // 작성 버튼을 눌렀을 때
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_KR")
        let Date = CommonVariable.formatter.string(from: CommonVariable.date)
        let ImagePath = "PostImage/\((Auth.auth().currentUser?.email)!)/\(Date).png"
        
        if LocationSwitch.isOn { //위치 공유 허용 상태이면 즉 On 상태일 때, 카메라로 사진을 찍어서 가져왔을 때
            
            DataSave(Date, identifier: 0)
        } else { //단순히 라이브러리 사진을 게시글로 작성할 때, 아니면 자신의 위치를 공유하지 않을 때
            if writeImage == nil { //그냥 글만 쓸 때
                return
            } else { // 사진이 있는데 라이브러리사진인 경우, 위치를 가져오나 공유하기 싫을 때
                print("??")
                DataSave(Date, identifier: 1)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        stringArray.removeAll()
        PostArray.removeAll()
        writeimageView.image = writeImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        writeDescription.delegate = self
        writeDescription.tintColor = UIColor.lightGray
        print(self.object.lat)
        print(self.object.lon)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        self.view.addGestureRecognizer(Tap)
        ref?.child("HashTagPosts").observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Null")
            } else {
                print(snapshot.key)
                let str = "#" + snapshot.key
                self.stringArray.append(str)
                //print(str)
            }
        })
        if writeImage == nil {
            object.lat = 0
        }
        if object.lat == 0 { //즉 전 단계에서 라이브러리 사진을 갖고왔을 때 위치정보가 없으니까
            LocationSwitch.isEnabled = false
        }
        
        writeimageView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/3)
            make.top.equalTo(self.view).offset(44)
        }
        writeDescription.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/22)
            make.top.equalTo(writeimageView.snp.bottom).offset(10)
        }
        writeDescription.adjustsFontForContentSizeCategory = true
        writeDescription.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        
        label.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width/2)
            make.height.equalTo(self.view.frame.height/30)
            make.left.equalTo(self.view).offset(10)
            make.top.equalTo(writeDescription.snp.bottom).offset(100)
        }
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        LocationSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-10)
            make.top.equalTo(label)
        }
        label1.snp.makeConstraints { (make) in
            make.size.equalTo(label)
            make.left.equalTo(label)
            make.top.equalTo(label.snp.bottom).offset(30)
        }
        label1.adjustsFontSizeToFitWidth = true
        label1.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        LocationSet.snp.makeConstraints { (make) in
            make.size.equalTo(writeBut)
            make.centerX.equalTo(LocationSwitch)
            make.top.equalTo(label1)
        }
        LocationSet.addTarget(self, action: #selector(LocationAdd), for: .touchUpInside)
        writeBut.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width/2)
            make.height.equalTo(self.view.frame.height/30)
            make.centerX.equalTo(self.view)
            make.top.equalTo(label1.snp.bottom).offset(30)
        }
        writeBut.setTitle("작성", for: .normal)
        writeBut.tintColor = UIColor.black
        writeBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 17)!
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! AccurateLocationMapViewController
        destination.object.lat = self.object.lat
        destination.object.lon = self.object.lon
        destination.delegate = self
    }
}
extension WriteViewController {
    @objc func LocationAdd() {
        self.performSegue(withIdentifier: "LocationSet", sender: self)
    }
    func SubFuncDataSave() {
        self.CountUpHasgTag(self.key!)
        self.ref?.child("WholePosts").updateChildValues([self.key! : self.PostArray]) // 전체 게시물 등록
        object.DisplayMessage("게시물이", "등록되었습니다.")
        self.writeimageView.image = nil
        self.writeImage = nil
        self.writeBut.isEnabled = false
        if self.writeimageView.image == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func DataSave(_ date : String, identifier : Int) { // 데이터 저장
        self.PostArray.removeAll()
        let uploadImage = UIImageJPEGRepresentation(writeImage, 0.9)!
        let metadata1 = StorageMetadata()
        
        key = (self.ref?.child("WholePosts").childByAutoId().key)!
        print(key)
        let path = "PostImage/\((Auth.auth().currentUser?.email)!)/\(key).png"
        let storage = Storage.storage().reference(forURL: "gs://sharegram-22845.appspot.com")
        let imageRef = storage.child(path)
        metadata1.contentType = "image/jpeg"
        let uploadTask = imageRef.putData(uploadImage, metadata: metadata1, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else { //이미지 저장이 완벽히 됐을 때
                imageRef.downloadURL(completion: { (url, error) in
                    if let url = url {
                        self.Hash = self.writeDescription.text._tokens(from: HashtagTokenizer())
                        self.NumberOfHasgTag(self.Hash)
                        
                        if identifier == 0 { //위치 공유 할 시
                            let latitude = String(self.object.lat)
                            let LocationPath = latitude.replacingOccurrences(of: ".", with: "_")
                            self.PostArray = ["image" : url.absoluteString,"latitude" : "\(self.object.lat)", "longitude" : "\(self.object.lon)", "Author" : (Auth.auth().currentUser?.displayName)!, "Description" : self.writeDescription.text, "Date" : date, "ID" : (Auth.auth().currentUser?.uid)!, "Like" : "0", "postID" : self.key]
                            
                        } else { // 1
                            self.PostArray = ["image" : url.absoluteString, "Author" : (Auth.auth().currentUser?.displayName)!, "Description" : self.writeDescription.text, "Date" : date, "ID" : (Auth.auth().currentUser?.uid)!, "postID" : self.key]
                        }
                        self.SubFuncDataSave()
                    }
                    
                })
                
            }
        })
        uploadTask.resume()
    }
    func CountUpHasgTag(_ key : String) { // 해쉬태그 카운트 증가 시키기 + 해쉬태그 게시물 등록
        print(self.HashTagArray)
        for i in 0..<self.HashTagArray.count {
            print(self.HashTagArray[i])
            let char = self.HashTagArray[i].replacingOccurrences(of: "#", with: "")
            ref?.child("HashTagPosts").child(char).child("Posts").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("존재하지 않습니다.")
                    //self.ref?.child("HashTagPosts").child(char).child("Count").setValue(["Name" : char, "Count" : "1"])
                    self.ref?.child("HashTagPosts").child(char).child("Posts").setValue([key : self.PostArray])
                } else { //카운트가 1이상일시 즉 하나라도 게시물이 존재한다는 가정
                    self.ref?.child("HashTagPosts").child(char).child("Posts").updateChildValues([key : self.PostArray])
                }
            })
        }
    }
    func NumberOfHasgTag(_ Token : [AnyToken]){ // 해쉬태그 거르기
        for i in 0..<Token.count {
            self.HashTagArray.append(Token[i].text)
        }
    }
    @objc func dismisskeyboard() {//디스미스
        writeDescription.resignFirstResponder()
    }
    func displayMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
            //self.dismiss(animated: true, completion: nil)
            
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func displayErrorMessage(title : String , message : String) { // 메시지 창
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    func CreateAutoCompleteHashTable() { // 해쉬태그 자동완성 팝업 뷰
        self.HashTagview = UITableView(frame: CGRect(x: 0, y: 0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight/3))
        self.HashTagview.delegate = self
        self.HashTagview.dataSource = self
        self.HashTagview.isScrollEnabled = false
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
    func observerData() {
        for key in 0..<result.count {
            let str = result[key].replacingOccurrences(of: "#", with: "")
            ref?.child("HashTagPosts").child(str).child("Count").observeSingleEvent(of: .childAdded, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("No")
                } else {
                    if let item = snapshot.value as? [String : String] {
                        print(item)
                        self.object.dic.append(item)
                    }
                    
                }
            })
        }
    }
}
extension WriteViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        observerData()
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.imageView?.image = UIImage(named: "HashTag.png")
        cell.textLabel?.text = self.result[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.writeDescription.text.components(separatedBy: "#")
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        let selectedText = selectedCell.textLabel?.text as String!
        let selected = selectedText?.replacingOccurrences(of: "#", with: "")
        let trim = self.writeDescription.text.replacingOccurrences(of: item.last!, with: "", options: .caseInsensitive, range: nil)
        self.writeDescription.text = trim + selected! + " "
        self.popover.dismiss()
        self.result.removeAll()
    }
}
extension WriteViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        strr = self.writeDescription.text
        let hashitems = strr.components(separatedBy: "#")
        if hashitems.count > 1 {
            resultString = hashitems.last! + text
            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", hashitems.last!)
            let array = (stringArray as NSArray).filtered(using: searchPredicate)
            result = array as! [String]
            if (result.isEmpty) == false {
                self.popover.show(self.HashTagview, fromView: self.writeDescription)
                self.HashTagview.reloadData()
            }
        }
        if text.hasPrefix("#") {
            CreateAutoCompleteHashTable()
            if result.isEmpty {
                self.popover.dismiss()
            }
            print("HashTag!!!!!")
        }
        if textView.text == "설명 입력" {
            textView.text = ""
            textView.tintColor = UIColor.black
        }
        if (text == "\n") {
            textView.endEditing(true)
            return false
        }
        return true
    }
}

