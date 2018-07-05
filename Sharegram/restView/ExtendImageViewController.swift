//
//  ExtendImageViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 17..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit

class ExtendImageViewController: UIViewController {

    @IBOutlet var imageview: UIImageView!
    var image : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight)
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        imageview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissview))
        imageview.addGestureRecognizer(tap)
        imageview.sd_setImage(with: URL(string: image), completed: nil)
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
extension ExtendImageViewController {
    @objc func dismissview() {
        self.dismiss(animated: true, completion: nil)
    }
}
