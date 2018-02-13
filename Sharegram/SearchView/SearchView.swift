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
    let seg = ADVSegmentedControl()
    @IBAction func ActSeg(_ sender: UISegmentedControl) {
        //self.removeFromSuperview()

    }
    //@IBOutlet weak var segment: ADVSegmentedControl!
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
        // Drawing code //경계 없애기
        self.addSubview(seg)
        seg.snp.makeConstraints { (make) in
            make.top.equalTo(SearchBar.snp.bottom).offset(20)
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.frame.height/20)
            make.centerX.equalTo(self)
        }
        seg.items = ["인기", "사람", "태그"]
        seg.borderColor = UIColor(white: 1.0, alpha: 0.3)
        seg.selectedIndex = 0
        
        SearchResultTable.snp.makeConstraints { (make) in
            make.top.equalTo(seg.snp.bottom).offset(20)
            make.width.equalTo(self.frame.width)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        SearchBar.showsCancelButton = true
        SearchBar.delegate = self
        
    }
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
} 