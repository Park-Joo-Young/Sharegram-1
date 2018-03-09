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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ProFileView = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(ProFileView)
        ProFileView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        ProFileView.ProFileImage.image = UIImage(named: "icon-profile-filled.png")
        ProFileView.layer.cornerRadius = 2.0
        ProFileView.ProFileEditBut.addTarget(self, action: #selector(ProfileEdit), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func ProfileEdit() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProFileEdit") as! ProFileEditViewController
//        vc.modalPresentationStyle = .overCurrentContext
//        present(vc, animated: true, completion: nil)
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
