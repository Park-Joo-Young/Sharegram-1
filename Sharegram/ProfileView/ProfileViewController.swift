//
//  ProfileViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 1. 11..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
class ProfileViewController: UIViewController {
    
    var MySettingBut = UIButton()
    override func viewWillAppear(_ animated: Bool) {
        let ProFileView = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(ProFileView)
        ProFileView.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.height)
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(70)
        }
        ProFileView.ProFileImage.image = UIImage(named: "icon-profile-filled.png")
        ProFileView.layer.cornerRadius = 2.0
        ProFileView.ProFileEditBut.addTarget(self, action: #selector(ProfileEdit), for: .touchUpInside)
        ProFileView.addSubview(MySettingBut)
        MySettingBut.snp.makeConstraints { (make) in
            make.top.equalTo(ProFileView.ProFileEditBut)
            make.width.equalTo(UIScreen.main.bounds.width/10)
            make.height.equalTo(ProFileView.ProFileEditBut)
            make.left.equalTo(ProFileView.ProFileEditBut.snp.right).offset(10)
        }
        MySettingBut.setImage(UIImage(named: "icon-settings-filled.png"), for: .normal)
        MySettingBut.setTitle("", for: .normal)
        MySettingBut.backgroundColor = UIColor.white
        MySettingBut.layer.cornerRadius = 3.0
        MySettingBut.layer.borderWidth = 1.5
        MySettingBut.layer.borderColor = UIColor.lightGray.cgColor
        MySettingBut.tintColor = UIColor.black
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func ProfileEdit() {
        performSegue(withIdentifier: "ProFileEdit", sender: self)
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
