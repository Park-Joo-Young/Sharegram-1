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


class SearchViewController: UIViewController{

    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    //검색 뷰
    @IBOutlet weak var naviItem: UINavigationItem!

    var SearchController : UISearchController!
    override func viewWillAppear(_ animated: Bool) {
        SearchController.searchBar.showsCancelButton = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.barTintColor = UIColor.lightGray
        //SearchController.searchBar.showsCancelButton = false
        self.navigationItem.titleView = SearchController.searchBar
        self.definesPresentationContext = true

        // Do any additional setup after loading the view.

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//    }
}

extension SearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Test")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true, completion:  nil)
        //searchController.becomeFirstResponder() = false
    }
}

