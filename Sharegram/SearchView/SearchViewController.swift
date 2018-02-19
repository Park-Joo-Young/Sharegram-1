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


    //검색 뷰
    @IBOutlet weak var naviItem: UINavigationItem!

    var SearchController : UISearchController!
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.barTintColor = UIColor.lightGray
        self.navigationItem.titleView = SearchController.searchBar
        self.definesPresentationContext = true

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//    }
}

extension SearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //self.performSegue(withIdentifier: "SubSearch", sender: self)
        print("시발")
        
        if searchController.isActive {
            searchController.searchBar.text = ""
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Test") as! SubSearchViewController
            self.navigationController?.pushViewController(vc, animated: true)
            //self.performSegue(withIdentifier: "SubSearch", sender: self)
        }
        //self.present(SubSearchViewController(), animated: true, completion: nil)
        
        
    }
}
