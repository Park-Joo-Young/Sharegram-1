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
    var UserList : [[String:String]] = [] //사람
    var TagList : [String] = [] // 태그
    var SearchList : [[String : String]] = [] // 검색 결과
    var ref : DatabaseReference?
    var keyList : [String] = []
    var SearchTagList : [[String : String]] = []
    var UserKeyForPrepare : String = ""
    var index : Int = 0
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.SearchController.isActive = false
        self.SearchController.searchBar.removeFromSuperview()
        self.definesPresentationContext = false
        super.viewWillDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.01) {
            self.SearchController.searchBar.becomeFirstResponder()
        }
     }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationItem.hidesBackButton = true
        ref = Database.database().reference()
        print("여기가 처음")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SearchController = UISearchController(searchResultsController: nil)
        //SearchController.delegate = self
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.barTintColor = UIColor.white
        self.definesPresentationContext = true
        self.navigationItem.title = "검색"
        self.view.addSubview(segment)
        segment.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(70)
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/20)
            make.centerX.equalTo(self.view)
        }
        
        
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
        SearchResultTable.estimatedRowHeight = 100
        SearchResultTable.rowHeight = UITableViewAutomaticDimension
        //self.navigationItem.titleView = SearchController.searchBar
        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "인기", at: 0)
        segment.insertSegment(withTitle: "사람", at: 1)
        segment.insertSegment(withTitle: "태그", at: 2)
        segment.underlineSelected = true
        //segment.addTarget(self, action: #selector(ActSegClicked), for: .valueChanged)
        segment.segmentContentColor = UIColor.black
        segment.selectedSegmentContentColor = UIColor.black
        segment.backgroundColor = UIColor.white
        segment.selectedSegmentIndex = 0
        
        let largerRedTextHighlightAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.blue]
        let largerRedTextSelectAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.orange]
        segment.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
        segment.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
        let attr = NSDictionary(object: UIFont(name: "BM DoHyeon OTF", size : 15)!, forKey: NSAttributedStringKey.font as NSCopying)
        segment.setTitleTextAttributes(attr as? [NSAttributedStringKey : Any], for: .normal)
        //navi.topItem?.titleView = SearchController.searchBar
        
        //self.navigationItem.titleView = SearchController.sea rchBar
        // Do any additional setup after loading the view.
        self.SearchResultTable.tableHeaderView = SearchController.searchBar
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
           if segment.selectedSegmentIndex == 2 {
                print(self.SearchTagList)
                return self.SearchTagList.count
            } else {
                return self.SearchList.count
            }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ddd")
        print(self.SearchList)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if segment.selectedSegmentIndex == 2 { //해쉬태그
            let dic = self.SearchTagList[indexPath.row]
            print(dic)
            cell.textLabel?.text = dic["Tag"]
            cell.textLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.detailTextLabel?.text = "\(dic["Count"]!)게시물"
            cell.detailTextLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 12)!
            cell.imageView?.frame.size = CGSize(width: 50, height: 50)
            cell.imageView?.layer.borderWidth = 1.0
            cell.imageView?.layer.masksToBounds = false
            cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.height)! / 2.0
            cell.imageView?.layer.borderColor = UIColor.black.cgColor
            cell.imageView?.clipsToBounds = true
            cell.imageView?.contentMode = .scaleToFill
            cell.imageView?.image = UIImage(named: "HashTag.png")
            return cell
        } else { //인기 와 사람
            let dic = self.SearchList[indexPath.row]
            cell.textLabel?.text = dic["사용자 명"]
            cell.textLabel?.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            if dic["ProFileImage"] != nil {
                cell.imageView?.layer.borderWidth = 1.0
                cell.imageView?.layer.masksToBounds = false
                cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.height)! / 2.0
                cell.imageView?.layer.borderColor = UIColor.black.cgColor
                cell.imageView?.clipsToBounds = true
                cell.imageView?.contentMode = .scaleToFill
                cell.imageView?.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
            }
            return cell
        }
        //cell.imageView?.image
    }
}
extension SubSearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        if segment.selectedSegmentIndex == 1 { // 사람인 상태에서 검색에서 누를 시
            //self.UserKeyForPrepare(self.SearchList[indexPath.row])
        } else if segment.selectedSegmentIndex == 2 { //태그 검색하고 누르면
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HashTagView") as! HashTagViewController
            vc.HashTagName = self.SearchTagList[self.index]["Tag"]!
            vc.modalPresentationStyle = .popover
            present(vc, animated: true, completion: nil)
        }
    }
}

extension SubSearchViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if !((searchController.searchBar.text?.isEmpty)!){ // 기록 중이면 필터를 검사한다
            print(self.UserList)
            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", searchController.searchBar.text!)
            // 3
            if segment.selectedSegmentIndex == 0 { //인기
                
            } else if segment.selectedSegmentIndex == 1 { //사람
                SearchUser(searchController.searchBar.text!)
            } else { // 2 hashtag
                SearchHashTag(searchController.searchBar.text!)
            }
            // 4
        } else {
            print("Not")
        }
    }
}
extension SubSearchViewController {
    func SearchUserList() {
        for i in 0..<self.keyList.count {
            ref?.child("User").child(self.keyList[i]).child("UserProfile").observe(.value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("null")
                } else {
                    if let item = snapshot.value as? [String : String] {
                        self.UserList.append(["Name" : item["사용자 명"]!])
                        self.SearchResultTable.reloadData()
                    }
                }
            })
        }
    }
    
//    @objc func ActSegClicked(_ sender : ScrollableSegmentedControl) {
//        if segment.selectedSegmentIndex == 1 { // 사람 클릭
//            print("1")
//            self.UserList.removeAll()
//            self.keyList.removeAll()
//            self.SearchList.removeAll()
//            self.SearchUser(<#T##str: String##String#>)
//        } else if segment.selectedSegmentIndex == 2 { // 태그
//            print("1")
//            self.TagList.removeAll()
//            self.UserList.removeAll()
//            self.SearchList.removeAll()
//            self.SearchResultTable.reloadData()
//            ref?.child("HashTagPosts").observe(.childAdded, with: { (snapshot) in
//                if snapshot.value is NSNull {
//                    print("null")
//                } else {
//                    self.TagList.append("#" + snapshot.key)
//                }
//            })
//        } else {
//            self.TagList.removeAll()
//            self.UserList.removeAll()
//            self.SearchResultTable.reloadData()
//            return
//        }
//    }
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
    func CountingTag(_ tag : String) {
        let tag1 = tag.replacingOccurrences(of: "#", with: "")
        print(tag1)
        ref?.child("HashTagPosts").child(tag1).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            self.SearchTagList.append(["Tag" : tag, "Count" : "\(snapshot.childrenCount)"])
            self.SearchResultTable.reloadData()
        })
        ref?.removeAllObservers()
    }
    func SearchUser(_ str : String) {
        SearchList.removeAll()
        ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(_, value) in item {
                    if let item = value["UserProfile"] as? [String : String] {
                        if item["사용자 명"]!.contains(str) { //이름 똑같은 프로필 찾았따.
                            self.SearchList.append(item)
                            self.SearchResultTable.reloadData()
                        }
                    }
                }
            }
        })
    }
    func SearchHashTag(_ str : String) {
        SearchTagList.removeAll()
        let tag = "#" + str
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] {
                    for (_, value) in item {
                        if (value["Description"] as? String)!.contains(tag) {
                            let hashtag = (value["Description"] as? String)!._tokens(from: HashtagTokenizer()) // 해쉬태그 다 짜르기
                            let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", tag)
                            let hashtagarray = self.forloop(hashtag)
                            let predicate = (hashtagarray as NSArray).filtered(using: searchPredicate)
                            self.loop(predicate as! [String])
                            //self.SearchResultTable.reloadData()
                        }
                    }
                }
            }
        })
        ref?.removeAllObservers()
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
            self.CountingTag(array[i])
        }
        print(self.SearchTagList)
        self.SearchResultTable.reloadData()
    }

}
