//
//  SearchView.swift
//  Sharegram
//
//  Created by apple on 2018. 2. 12..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit

class SearchView: UIView, UISearchBarDelegate {

    @IBAction func ActSeg(_ sender: UISegmentedControl) {
        //self.removeFromSuperview()
    }
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var SearchResultTable: UITableView!
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SearchView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.removeFromSuperview()
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { //검색 시
        
        return true
    }
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        SearchBar.showsCancelButton = true
        SearchBar.delegate = self
        
    }
    

}
