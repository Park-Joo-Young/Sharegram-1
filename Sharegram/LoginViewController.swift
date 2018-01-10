//
//  LoginViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 1. 10..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {
    var Object = variable()
    override func viewDidLoad() {
        super.viewDidLoad()
        Object.ref = Database.database().reference()
        
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
