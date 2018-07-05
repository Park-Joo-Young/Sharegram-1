//
//  ProFileEditViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 3. 3..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import MobileCoreServices
import SDWebImage

class ProFileEditViewController: UIViewController {

    @IBOutlet weak var ProFileEditTableView: UITableView!
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    let imagePicker = UIImagePickerController()
    var dic : [String : String] = [:]
    var capture : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()  
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(CompleteEdit)), animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        ProFileEditTableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(70)
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight/2)
        }
        ProFileEditTableView.tableFooterView = UIView()
        
        //imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func CompleteEdit() {
        if capture != nil {
            let uploadImage = UIImageJPEGRepresentation(capture, 0.9)!
            let metadata1 = StorageMetadata()
            metadata1.contentType = "image/jpeg"
            storageRef?.child("ProFileImage/\((Auth.auth().currentUser?.displayName)!)").putData(uploadImage, metadata: metadata1, completion: { (metadata, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else { //성공적으로 저장되면
                    let str = metadata?.downloadURL()?.absoluteString
                    self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").updateChildValues(["ProFileImage" : str!])
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        return
    }
    func Fetch() {
        ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                self.dic = item
            }
        })
        ref?.removeAllObservers()
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
extension ProFileEditViewController : UITableViewDelegate, UITableViewDataSource {
    @objc func imagePick() {
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            present(imagePicker, animated: true, completion: nil)
        }
     }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = Bundle.main.loadNibNamed("ProFileEditTableViewCell", owner: self, options: nil)?.first as! ProFileEditTableViewCell
            Fetch()
            if dic["ProFileImage"] == nil {
               cell.ProFileimage.image = UIImage(named: "icon-profile-filled.png")
                cell.ProFileimage.layer.cornerRadius = 2.0
                cell.ProFileimage.clipsToBounds = true
            } else {
                cell.ProFileimage.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
                cell.ProFileimage.layer.cornerRadius = 2.0
                cell.ProFileimage.clipsToBounds = true
            }

            cell.EditBut.addTarget(self, action: #selector(imagePick), for: .touchUpInside)
            cell.EditBut.setTitle("프로필 사진 수정하기", for: .normal)
            cell.EditBut.titleLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 13)!
            cell.EditBut.tintColor = UIColor.black
            return cell
        }
            
        else {
            let cell = Bundle.main.loadNibNamed("ProFileIntrodutionTableViewCell", owner: self, options: nil)?.first as! ProFileIntrodutionTableViewCell
            cell.Label.text = "소개"
            cell.introdutionTextField.placeholder = "자신의 소개를 적으세요"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else {
            return 100
        }
    }
}
extension ProFileEditViewController : UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
            
            capture = info[UIImagePickerControllerOriginalImage] as! UIImage
            let cell = ProFileEditTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProFileEditTableViewCell
            cell.ProFileimage.image = capture
            //cell.ProFileimage.contentMode = .scaleAspectFill
            cell.ProFileimage.layer.cornerRadius = 30
            cell.ProFileimage.layer.borderWidth = 2.0
            cell.ProFileimage.layer.borderColor = UIColor.black.cgColor
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
