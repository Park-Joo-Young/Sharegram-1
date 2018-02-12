//
//  SearchViewController.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    //검색 뷰

    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var Searchbar: UISearchBar!

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //print("시발")
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchBarShouldBeginEditing(Searchbar) {
            print("시발")
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
