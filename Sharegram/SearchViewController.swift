//
//  SearchViewController.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//  Write SatGatLee

import UIKit
import Firebase
import SnapKit


class SearchViewController: UIViewController {
    //검색 뷰
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var searchBut: UIButton!
    
    func presentView() {
        let subview = SearchView.instanceFromNib()
        self.view.addSubview(subview)
        subview.snp.makeConstraints { (make) in
            make.top.equalTo(searchBut.snp.bottom)
            make.size.equalTo(self.view)
        }
    }
    @IBAction func SearchAct(_ sender: UIButton) {
        presentView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBut.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width/2)
            make.height.equalTo(self.view.frame.height/30)
            make.top.equalTo(self.view).offset(77)
            make.centerX.equalTo(self.view)
        }
        searchBut.setImage(UIImage(named: "searchBar.png"), for: .normal)
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
