//
//  SearchViewController.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//  Write SatGatLee

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    
    
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @objc func Action() {
        print("씨발")
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
