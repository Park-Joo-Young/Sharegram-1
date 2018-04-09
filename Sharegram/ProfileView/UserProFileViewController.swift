//
//  UserProFileViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 19..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SnapKit


class UserProFileViewController: UIViewController { //다른 사람이 사람을 검색하거나 눌러서 들어올 때

    @IBOutlet var navi: UINavigationBar!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    var ref : DatabaseReference?
    var item : String = ""
    var UserKey : String = "" // 다른 사람의 uid
    var profileview = ProFileView()
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.isNavigationBarHidden = true

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        profileview = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(profileview)
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        //navi.topItem?.title = item
        UINavigationBar.appearance().barTintColor = UIColor.white
        profileview.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.centerX.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(navi.snp.bottom).offset(10)
        }
        profileview.FollowerCount.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.ProFileImage.snp.right).offset(70)
        }
        
        profileview.ProFileEditBut.setTitle("팔로잉", for: .normal)
        profileview.ProFileImage.image = UIImage(named: "icon-profile-filled.png")
        profileview.ProFileEditBut.snp.makeConstraints { (make) in
            make.left.equalTo(profileview.FollowerCount.snp.left)
            make.width.equalTo(self.view.frame.width/1.5)
        }
        print("Posts[0].username!")
        print(UserKey)
        ref?.child("User").child(UserKey).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["ProFileImage"] != nil {
                    self.profileview.ProFileImage.sd_setImage(with: URL(string: item["ProFileImage"]!), completed: nil)
                } else {
                    return
                }
            }
        })
        if (Auth.auth().currentUser?.uid)! == UserKey {
            profileview.ProFileEditBut.setTitle("자신입니다.", for: .normal)
            profileview.ProFileEditBut.isEnabled = false
        }
        FollowCheck()
        profileview.ProFileEditBut.addTarget(self, action: #selector(Following), for: .touchUpInside)
        
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
extension UserProFileViewController {
    @objc func Following() { //팔로잉 합시다.
        let AutoKey = ref?.child("User").childByAutoId().key
        ref?.child("User").child(UserKey).child("Follower").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value is NSNull { //내가 다른 사람에 팔로워에 없을 시 즉 첫 사람일경우
                print("Nothing")
                let Following = [AutoKey! : self.UserKey]
                let Follower = [AutoKey! : (Auth.auth().currentUser?.uid)!]
                self.ref?.child("User").child(self.UserKey).child("Follower").setValue(Follower)
                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following").setValue(Following)
                return
            } else {
                if let item = snapshot.value as? [String : String] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (key,value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //있다면 지운다.
                            
                            let alert = UIAlertController(title: "팔로우 중입니다.", message: "취소하시겠습니까?", preferredStyle: .actionSheet)
                            let confirm = UIAlertAction(title: "팔로우 취소", style: .default) { //지우기
                                (action : UIAlertAction) -> Void in
                                //self.dismiss(animated: true, completion: nil)
                                self.ref?.child("User").child(self.UserKey).child("Follower/\(key)").removeValue()
                                self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following/\(key)").removeValue()
                                self.profileview.ProFileEditBut.setTitle("팔로우", for: .normal)
                            }
                            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                            alert.addAction(confirm)
                            alert.addAction(cancel)
                            self.present(alert, animated: true, completion: nil)
                            return
                        } else {
                            let Following = [AutoKey! : self.UserKey]
                            let Follower = [AutoKey! : (Auth.auth().currentUser?.uid)!]
                            self.ref?.child("User").child(self.UserKey).child("Follower").setValue(Follower)
                            self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Following").setValue(Following)
                            return
                        }
                    }
                }

            }
        })
        ref?.removeAllObservers()
    }
    func FollowCheck(){ //내가 그기 있는지 없는지 확인하자
        //let AutoKey = ref?.child("User").childByAutoId().key
        ref?.child("User").child(UserKey).child("Follower").queryOrderedByKey().observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull { //내가 다른 사람에 팔로워에 없을 시
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : String] { //있으면 중복 체크를 위해 데이터 가져옴
                    for (_,value) in item {
                        if value == (Auth.auth().currentUser?.uid)! { //있다면 팔로우 중이라는 표시
                            self.profileview.ProFileEditBut.setTitle("팔로우 중 입니다.", for: .normal)
                        } else {
                            return
                        }
                    }
                }
            }
        })
    }
}

