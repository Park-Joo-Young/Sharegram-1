//
//  SearchView.swift
//  Sharegram
//
//  Created by apple on 2018. 2. 12..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class SearchView: UIView {
    let seg = ADVSegmentedControl()
    var SearchController : UISearchController!
    var UserList : [[String : String]] = []
    var SearchList : [[String : String]] = []
    var ref : DatabaseReference?
    var keyList : [String] = []

    //@IBOutlet weak var segment: ADVSegmentedControl!
    @IBOutlet weak var SearchResultTable: UITableView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SearchView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code //경계 없애기
        ref = Database.database().reference()
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        
        self.addSubview(seg)
        seg.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.frame.height/20)
            make.centerX.equalTo(self)
        }
        seg.items = ["인기", "사람", "태그"]
        seg.borderColor = UIColor(white: 1.0, alpha: 0.3)
        seg.selectedIndex = 0
        seg.addTarget(self, action: #selector(ActSegClicked), for: .valueChanged)
        SearchResultTable.snp.makeConstraints { (make) in
            make.top.equalTo(seg.snp.bottom).offset(20)
            make.width.equalTo(self.frame.width)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        SearchResultTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        SearchResultTable.delegate = self
        SearchResultTable.dataSource = self
        self.SearchResultTable.tableHeaderView = SearchController.searchBar
        SearchController.searchBar.delegate = self

    }
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    func SearchUserList() {
        for i in 0..<self.keyList.count {
            ref?.child("User").child(self.keyList[i]).child("UserProfile").observe(.value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("null")
                } else {
                    if let item = snapshot.value as? [String : String] {
                        self.UserList.append(item)
                        self.SearchResultTable.reloadData()
                    }
                }
            })
        }
    }
//    func sss() {
//        ref?.child("User").queryOrdered(byChild: "사용자 명").queryStarting(atValue: "군상").queryEnding(atValue: "군상" + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            print(snapshot)
//
//        })
//    }
    @objc func ActSegClicked(_ sender : ADVSegmentedControl) {
        if seg.selectedIndex == 1 { // 사람
            print("1")
            ref?.child("User").observe(.value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("Nothing")
                } else {
                    for child in snapshot.children {
                        let user = child as! DataSnapshot
                        self.keyList.append(user.key)
                    }
                    if self.keyList.count == Int(snapshot.childrenCount) {
                        print("??")
                        print(self.keyList.count)
                        self.SearchUserList()
                    }
                }
            })
        } else if seg.selectedIndex == 2 { // 태그
            print("1")
        }
    }
}
extension SearchView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SearchController.isActive {
            print(self.SearchList.count)
            return self.SearchList.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myidentifier = "cell"
        var cell = SearchResultTable.dequeueReusableCell(withIdentifier: myidentifier, for: indexPath)
        print("ddd")
        print(self.SearchList)
        cell = UITableViewCell(style: .value1, reuseIdentifier: myidentifier)
        cell.textLabel?.text = self.SearchList[indexPath.row]["사용자 명"]
        
        return cell
    }
}
extension SearchView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
extension SearchView : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.removeFromSuperview()
    }
}
extension SearchView : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !((searchController.searchBar.text?.isEmpty)!){ // 기록 중이면 필터를 검사한다
            print(self.UserList)
            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
            // 3
            let array = (self.UserList as NSArray).filtered(using: searchPredicate)

            self.SearchList = array as! [[String:String]]
            if !(array.isEmpty) {
                print(self.SearchList)
                self.SearchResultTable.reloadData()
            }
            
            // 4
        } else {
            print("Not")
        }
    }
}
