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
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    var item : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    
        let view = Bundle.main.loadNibNamed("ProFileView", owner: self, options: nil)?.first as! ProFileView
        self.view.addSubview(view)
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        navi.topItem?.title = item
        UINavigationBar.appearance().barTintColor = UIColor.white
        view.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.centerX.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(navi.snp.bottom).offset(10)
        }
        view.FollowerCount.snp.makeConstraints { (make) in
            make.left.equalTo(view.ProFileImage.snp.right).offset(70)
        }
        
        view.ProFileEditBut.setTitle("팔로잉", for: .normal)
        view.ProFileImage.image = UIImage(named: "icon-profile-filled.png")
        view.ProFileEditBut.snp.makeConstraints { (make) in
            make.left.equalTo(view.FollowerCount.snp.left)
            make.width.equalTo(self.view.frame.width/1.5)
        }
        
        
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
