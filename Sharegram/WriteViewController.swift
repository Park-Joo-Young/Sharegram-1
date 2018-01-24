//
//  WriteViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 1. 15..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class WriteViewController: UIViewController, UITextViewDelegate,UIPopoverPresentationControllerDelegate, dataDelegate {
    
    func TransferData(_ array : String) {
        print("array")
        self.writeDescription.text = array
    }
    
    var writeImage : UIImage!
    var baseString : String! // 이미지 데이터 변환 포맷
    var object = variable()
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    var PostArray : [[String : String]] = []
    var Hash : [AnyToken]!
    var HashTagArray : [String] = []
    var str : String = ""

    @IBOutlet weak var writeimageView: UIImageView!
    @IBOutlet weak var writeDescription: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var LocationSwitch: UISwitch!
    @IBOutlet weak var writeBut: UIButton!
    @IBAction func ActBut(_ sender: UIButton) { // 작성 버튼을 눌렀을 때
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let year =  components.year!
        let month = components.month!
        let day = components.day!
        let hour = components.hour!
        let min = components.minute!
        let dateString = "\(year)년\(month)월\(day)일\(hour)시\(min)분"
        let ss = "PostImage/\((Auth.auth().currentUser?.email)!)/\(dateString).png"
        
        if LocationSwitch.isOn { //위치 공유 허용 상태이면 즉 On 상태일 때, 카메라로 사진을 찍어서 가져왔을 때
            DataSave(ss, dateString, identifier: 0)
        } else { //단순히 라이브러리 사진을 게시글로 작성할 때, 아니면 자신의 위치를 공유하지 않을 때
            if writeImage == nil { //그냥 글만 쓸 때
                print("nil")
                self.Hash = self.writeDescription.text._tokens(from: HashtagTokenizer())
                self.NumberOfHasgTag(self.Hash)
                self.PostArray.append(["Author" : (Auth.auth().currentUser?.displayName)!, "Description" : self.writeDescription.text, "Date" : dateString])
                self.CountUpHasgTag()
                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Posts").setValue(self.PostArray)
                self.displayErrorMessage(title: "게시물이", message: "등록되었습니다!")
            } else { // 사진이 있는데 라이브러리사진인 경우
                print("??")
                DataSave(ss, dateString, identifier: 1)
            }
        }
    }
    func DataSave(_ Path : String, _ date : String, identifier : Int) {
        let uploadImage = UIImageJPEGRepresentation(writeImage, 0.9)!
        let metadata1 = StorageMetadata()
        metadata1.contentType = "image/jpeg"
        storageRef?.child(Path).putData(uploadImage, metadata: metadata1, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else { //이미지 저장이 완벽히 됐을 때
                
                self.Hash = self.writeDescription.text._tokens(from: HashtagTokenizer())
                self.NumberOfHasgTag(self.Hash)
                
                if identifier == 0 {
                    self.PostArray.append(["image" : Path,"latitude" : "\(self.object.lat)", "longitude" : "\(self.object.lon)", "Author" : (Auth.auth().currentUser?.displayName)!, "Description" : self.writeDescription.text, "Date" : date])
                } else {
                    
                    self.PostArray.append(["image" : Path, "Author" : (Auth.auth().currentUser?.displayName)!, "Description" : self.writeDescription.text, "Date" : date])
                }
                self.CountUpHasgTag()
                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Posts").setValue(self.PostArray)
                self.displayErrorMessage(title: "게시물이", message: "등록되었습니다!")
            }
        })
    }
    func CountUpHasgTag() {
        print(self.HashTagArray)
        for i in 0..<self.HashTagArray.count {
            print(self.HashTagArray[i])
            let char = self.HashTagArray[i].replacingOccurrences(of: "#", with: "")
            ref?.child("HashTagPosts").child(char).child("Count").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("존재하지 않습니다.")
                    self.ref?.child("HashTagPosts").child(char).child("Count").setValue(["Count" : "1"])
                    self.ref?.child("HashTagPosts").child(char).child("Count").setValue(["Name" : char])
                    self.ref?.child("HashTagPosts").child(char).child("Posts").setValue(self.PostArray)
                } else { //카운트가 1이상일시 즉 하나라도 게시물이 존재한다는 가정
                    if let item = snapshot.value as? [String : String] {
                        var count = Int(item["Count"]!)!
                        count += 1
                        self.ref?.child("HashTagPosts").child(char).child("Count").setValue(["Count" : "\(count)"])
                        self.ref?.child("HashTagPosts").child(char).child("Count").setValue(["Name" : char])
                        self.ref?.child("HashTagPosts").child(char).child("Posts").setValue(self.PostArray)
                    }
                }
            })
        }
    }
    func NumberOfHasgTag(_ Token : [AnyToken]){
        for i in 0..<Token.count {
            self.HashTagArray.append(Token[i].text)
        }
    }
    func popOver(_ send : UITextView) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transfer = storyboard.instantiateViewController(withIdentifier: "HashTag") as! HashTagTableViewController
        transfer.delegate = self
        transfer.saveText = self.writeDescription.text
        let vc = storyboard.instantiateViewController(withIdentifier: "HashTag")
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 200, height: 200)

        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        popover.sourceView = send as UIView
        popover.sourceRect = send.bounds
        
        self.present(vc, animated: true, completion: nil)
    }
//    func AutoCollection() {
//        self.writeDescription.text.mat
//    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "#" { //텍스트 뷰에 #이 적힐 때 마다
            print("HashTag!!!!!")
            popOver(textView)
            //AutoCollection()
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
    @objc func dismisskeyboard() {
        writeDescription.resignFirstResponder()
    }
    @objc func dismissText() {
        writeDescription.text = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        PostArray.removeAll()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        writeDescription.delegate = self
        writeimageView.image = writeImage
        writeDescription.tintColor = UIColor.lightGray

        let Tap = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        self.view.addGestureRecognizer(Tap)
        
        ref?.child("HashTagPosts").observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Null")
            } else {
                
                print(snapshot.key)
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
            make.height.equalTo(self.view.frame.height/30)
            make.top.equalTo(writeimageView.snp.bottom).offset(10)
        }
        label.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width/2)
            make.height.equalTo(self.view.frame.height/30)
            make.left.equalTo(self.view).offset(10)
            make.top.equalTo(writeDescription.snp.bottom).offset(100)
        }
        label.adjustsFontSizeToFitWidth = true
        LocationSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-10)
            make.top.equalTo(label)
        }
        writeBut.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width/2)
            make.height.equalTo(self.view.frame.height/30)
            make.centerX.equalTo(self.view)
            make.top.equalTo(label.snp.bottom).offset(50)
        }
        writeBut.setTitle("작성", for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func displayErrorMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ii" {
            let destination = segue.destination as! ViewController
            destination.image = str
        }
    }
    

}
