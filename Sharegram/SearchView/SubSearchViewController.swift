//
//  SubSearchViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 2. 19..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import ScrollableSegmentedControl

class SubSearchViewController: UIViewController {

    @IBOutlet weak var SearchResultTable: UITableView!
    
    @IBOutlet weak var navi: UINavigationBar!
    let segment = ScrollableSegmentedControl()
    //let seg = ADVSegmentedControl()
    var SearchController : UISearchController!
    var UserList : [String] = [] //사람
    var TagList : [String] = [] // 태그
    var SearchList : [String] = [] // 검색 결과
    var ref : DatabaseReference?
    var keyList : [String] = []
    var SearchTagList : [String] = []
    var UserKeyForPrepare : String = ""
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    override func viewDidAppear(_ animated: Bool) {
        delay(0.001) {
            self.SearchController.searchBar.becomeFirstResponder()
            print("됐는데")
        }
    }
    func SearchHashTag(_ str : String ) {
        let tag = "#" + str
        ref?.child("WholePosts").observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : String] {
                    if item["Description"]!.contains(tag) { //검색한 태그가 있는 포스트를 찾았을 경우
                        let hashtag = item["Description"]?._tokens(from: HashtagTokenizer()) // 해쉬태그 다 짜르기
                        let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", tag)
                        let hashtagarray = self.forloop(hashtag!)
                        let predicate = (hashtagarray as NSArray).filtered(using: searchPredicate)
                        self.loop(predicate as! [String])
                        self.SearchResultTable.reloadData()
                    }
                }
            }
        })
    }
    func forloop(_ Token : [AnyToken]) -> [String]{
        var array = [String]()
        for i in 0..<Token.count {
            array.append(Token[i].text)
        }
        return array
    }
    func loop(_ array : [String]) {
        for i in 0..<array.count {
            self.SearchTagList.append(array[i])
        }
        self.SearchResultTable.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        ref = Database.database().reference()
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.height.equalTo(self.view.frame.height/10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        self.view.addSubview(segment)
        segment.snp.makeConstraints { (make) in
            make.top.equalTo(navi.snp.bottom)
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/20)
            make.centerX.equalTo(self.view)
        }
        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "인기", at: 0)
        segment.insertSegment(withTitle: "사람", at: 1)
        segment.insertSegment(withTitle: "태그", at: 2)
        segment.underlineSelected = true
        segment.addTarget(self, action: #selector(ActSegClicked), for: .valueChanged)
        segment.segmentContentColor = UIColor.black
        segment.selectedSegmentContentColor = UIColor.black
        segment.backgroundColor = UIColor.white
        segment.selectedSegmentIndex = 0
        
        let largerRedTextHighlightAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.blue]
        let largerRedTextSelectAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.orange]
        segment.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
        segment.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
        
        //        seg.items = ["인기", "사람", "태그"]
        //        seg.borderColor = UIColor(white: 1.0, alpha: 0.3)
        //        seg.selectedIndex = 0
        //        seg.addTarget(self, action: #selector(ActSegClicked), for: .valueChanged)
        
        SearchResultTable.snp.makeConstraints { (make) in
            make.top.equalTo(segment.snp.bottom)
            make.width.equalTo(self.view.frame.width)
            make.bottom.equalTo(self.view.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        let SwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SwipeLeftAction))
        SwipeLeft.direction = .left
        //SearchResultTable.addGestureRecognizer(SwipeLeft)
        let SwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SwipeRightAction))
        SwipeRight.direction = .right
        //SearchResultTable.addGestureRecognizer(SwipeRight)
        SearchResultTable.separatorStyle = .none
        SearchResultTable.rowHeight = UITableViewAutomaticDimension
        SearchResultTable.estimatedRowHeight = 100
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.hidesBackButton = true
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.delegate = self
        SearchController.definesPresentationContext = true
        self.definesPresentationContext = true


        navi.topItem?.titleView = SearchController.searchBar
        
        //self.navigationItem.titleView = SearchController.sea rchBar
        // Do any additional setup after loading the view.
    }
//    func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .lightContent
//    }
    @objc func SwipeLeftAction() {
        segment.selectedSegmentIndex += 1
    }
    @objc func SwipeRightAction() {
        segment.selectedSegmentIndex -= 1
    }
    func SearchUserList() {
        for i in 0..<self.keyList.count {
            ref?.child("User").child(self.keyList[i]).child("UserProfile").observe(.value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("null")
                } else {
                    if let item = snapshot.value as? [String : String] {
                        self.UserList.append(item["사용자 명"]!)
                        self.SearchResultTable.reloadData()
                    }
                }
            })
        }
    }

    @objc func ActSegClicked(_ sender : ScrollableSegmentedControl) {
        if segment.selectedSegmentIndex == 1 { // 사람 클릭
            print("1")
            self.UserList.removeAll()
            self.keyList.removeAll()
            self.SearchList.removeAll()
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
        } else if segment.selectedSegmentIndex == 2 { // 태그
            print("1")
            self.TagList.removeAll()
            self.UserList.removeAll()
            self.SearchList.removeAll()
            self.SearchResultTable.reloadData()
            ref?.child("HashTagPosts").observe(.childAdded, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("null")
                } else {
                    self.TagList.append("#" + snapshot.key)
                }
            })
        } else {
            self.TagList.removeAll()
            self.UserList.removeAll()
            self.SearchResultTable.reloadData()
            return
            //self.dismiss(animated: true, completion: nil)
        }
    }
    func UserKeyForPrepare(_ key1 : String) {
        ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(key,value) in item {
                    if let dic = value["UserProfile"] as? [String : String]{
                        if dic["사용자 명"] == key1 {
                            self.UserKeyForPrepare = key
                            self.performSegue(withIdentifier: "SearchToUser", sender: self)
                            break
                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segment.selectedSegmentIndex == 1 { // 사람 검색 후 세그가 일어날 때
            if segue.identifier == "SearchToUser" {
                let destination = segue.destination as! UserProFileViewController
                destination.UserKey = self.UserKeyForPrepare
            }
        }

    }
 

}
extension SubSearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SearchController.isActive {
            print(self.SearchList.count)
            if segment.selectedSegmentIndex == 2 {
                return self.SearchTagList.count
            } else {
                return self.SearchList.count
            }
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ddd")
        print(self.SearchList)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        if segment.selectedSegmentIndex == 2 { //해쉬태그
            cell.textLabel?.text = self.SearchTagList[indexPath.row]
            cell.imageView?.image = UIImage(named: "HashTag.png")
            cell.imageView?.layer.borderWidth = 1.5
            //self.SearchList[indexPath.row].replacingOccurrences(of: "#", with: "")
//           let tag = self.SearchList[indexPath.row].replacingOccurrences(of: "#", with: "")
//            ref?.child("HashTagPosts").child(tag).child("Count").observe(.value, with: { (snapshot) in
//                if let item = snapshot.value as? [String : String] {
//                    cell.detailTextLabel?.text = "게시물 \(item["Count"]!)개 "
//                    cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
//                    cell.detailTextLabel?.tintColor = UIColor.lightGray
//                }
//            })
//            ref?.removeAllObservers()
        } else { //인기 와 사람
            cell.textLabel?.text = self.SearchList[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        }
        //cell.imageView?.image
        return cell
    }
}
extension SubSearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segment.selectedSegmentIndex == 1 { // 사람인 상태에서 검색에서 누를 시
            self.UserKeyForPrepare(self.SearchList[indexPath.row])
        }
    }
}
extension SubSearchViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "segue", sender: self)
    }
}
extension SubSearchViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if !((searchController.searchBar.text?.isEmpty)!){ // 기록 중이면 필터를 검사한다
            print(self.UserList)
            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
            // 3
            if segment.selectedSegmentIndex == 0 {
                
            } else if segment.selectedSegmentIndex == 1 {
                let array = (self.UserList as NSArray).filtered(using: searchPredicate)
                
                self.SearchList = array as! [String]
                if !(array.isEmpty) {
                    print("?")
                    print(self.SearchList)
                    self.SearchResultTable.reloadData()
                }
            } else { // 2 hashtag
//                let array = (self.TagList as NSArray).filtered(using: searchPredicate)
//
//                self.SearchList = array as! [String]
//                if !(array.isEmpty) {
//                    print(self.SearchList)
//                    self.SearchResultTable.reloadData()
//                }
                SearchHashTag(searchController.searchBar.text!)
            }
            // 4
        } else {
            print("Not")
        }
    }
}
