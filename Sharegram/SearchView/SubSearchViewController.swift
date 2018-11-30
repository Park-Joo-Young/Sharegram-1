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
    var popularList : [[String : String]] = []
    var ref : DatabaseReference?
    var keyList : [String] = []
    var SearchTagList : [[String : String]] = []
    var UserKeyForPrepare : String = ""
    var index : Int = 0
    var followerList : [String] = []
    var UserName : String = ""
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
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
        if segment.selectedSegmentIndex == 0 {
            self.PopularList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.SearchResultTable.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "usercell")
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
        SearchResultTable.rowHeight = 70
        SearchResultTable.estimatedRowHeight = UITableViewAutomaticDimension
        
        //self.navigationItem.titleView = SearchController.searchBar
        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "인기", at: 0)
        segment.insertSegment(withTitle: "사람", at: 1)
        segment.insertSegment(withTitle: "태그", at: 2)
        segment.underlineSelected = true
        segment.addTarget(self, action: #selector(ActSegmentClick), for: .valueChanged)
        segment.segmentContentColor = UIColor.black
        segment.selectedSegmentContentColor = UIColor.black
        segment.backgroundColor = UIColor.white
        segment.selectedSegmentIndex = 0
        
        let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.blue]
        let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.orange]
        segment.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
        segment.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
        let attr = NSDictionary(object: UIFont(name: "BM DoHyeon OTF", size : 15)!, forKey: NSAttributedString.Key.font as NSCopying)
        segment.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any], for: .normal)
        //navi.topItem?.titleView = SearchController.searchBar
        
        //self.navigationItem.titleView = SearchController.sea rchBar
        // Do any additional setup after loading the view.
        self.SearchResultTable.tableHeaderView = SearchController.searchBar
    }

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
                destination.UserName = self.UserName
            }
        }

    }
 

}
extension SubSearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           if segment.selectedSegmentIndex == 2 {
                print(self.SearchTagList)
                return self.SearchTagList.count
            } else if segment.selectedSegmentIndex == 1{
                return self.SearchList.count
           } else {
            if self.SearchList.count != 0 {
                return 3
            } else {
                return 0
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ddd")
        print(self.SearchList)
        
        let cell = self.SearchResultTable.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserTableViewCell
        if segment.selectedSegmentIndex == 2 { //해쉬태그
            let dic = self.SearchTagList[indexPath.row]
            cell.name.text = dic["Tag"]
            cell.name.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            cell.followercount.text = "\(dic["Count"]!)게시물"
            cell.followercount.font = UIFont(name: "BM DoHyeon OTF", size : 12)!
            //cell.profile.frame.size = CGSize(width: 100, height: 100)
            cell.profile.image = UIImage(named: "HashTag.png")
            cell.profile.layer.borderWidth = 1.0
            cell.profile.layer.masksToBounds = false
            cell.profile.layer.cornerRadius = (cell.profile.frame.size.height) / 2.0
            cell.profile.layer.borderColor = UIColor.black.cgColor
            cell.profile.clipsToBounds = true
            cell.profile.contentMode = .scaleToFill
           
            return cell
        } else if segment.selectedSegmentIndex == 1{ // 사람
            self.followerList.removeAll()
            let dic = self.SearchList[indexPath.row]
            ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let item = snapshot.value as? [String : AnyObject] {
                    for(_, value) in item {
                        if let user = value["UserProfile"] as? [String : String] {
                            if user["사용자 명"] == dic["사용자 명"] {
                                if let follower = value["Follower"] as? [String : String] {
                                    for (_, value) in follower {
                                        self.followerList.append(value)
                                    }
                                 }
                                cell.followercount.text = "팔로워 \(self.followerList.count)명"
                                cell.followercount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
                                self.followerList.removeAll()
                            }
                        }
                    }
                }
            })
            cell.name.text = dic["사용자 명"]
            cell.name.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            if dic["ProFileImage"] != nil {
                cell.profile.frame.size = CGSize(width: 50, height: 50)
                cell.profile.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
                cell.profile.layer.borderWidth = 1.0
                cell.profile.layer.masksToBounds = false
                cell.profile.layer.cornerRadius = (cell.profile.frame.size.width) / 2.0
                cell.profile.layer.borderColor = UIColor.black.cgColor
                cell.profile.clipsToBounds = true
                cell.profile.contentMode = .scaleToFill
                
            } else { //이미지가 없다ㅋ
                cell.profile.frame.size = CGSize(width: 50, height: 50)
                cell.profile.image = UIImage(named: "profile.png")
                cell.profile.layer.borderWidth = 1.0
                cell.profile.layer.masksToBounds = false
                cell.profile.layer.cornerRadius = (cell.profile.frame.size.width) / 2.0
                cell.profile.layer.borderColor = UIColor.black.cgColor
                cell.profile.clipsToBounds = true
                cell.profile.contentMode = .scaleToFill
            }
            return cell
        } else {
            let dic = self.SearchList[indexPath.row]
            cell.name.text = dic["사용자 명"]
            cell.name.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            if dic["ProFileImage"] != nil {
                cell.profile.frame.size = CGSize(width: 50, height: 50)
                cell.profile.sd_setImage(with: URL(string: dic["ProFileImage"]!), completed: nil)
                cell.profile.layer.borderWidth = 1.0
                cell.profile.layer.masksToBounds = false
                cell.profile.layer.cornerRadius = (cell.profile.frame.size.width) / 2.0
                cell.profile.layer.borderColor = UIColor.black.cgColor
                cell.profile.clipsToBounds = true
                cell.profile.contentMode = .scaleToFill
                
            } else { //이미지가 없다ㅋ
                cell.profile.frame.size = CGSize(width: 50, height: 50)
                cell.profile.image = UIImage(named: "profile.png")
                cell.profile.layer.borderWidth = 1.0
                cell.profile.layer.masksToBounds = false
                cell.profile.layer.cornerRadius = (cell.profile.frame.size.width) / 2.0
                cell.profile.layer.borderColor = UIColor.black.cgColor
                cell.profile.clipsToBounds = true
                cell.profile.contentMode = .scaleToFill
            }
            cell.followercount.text = "팔로워 \(self.popularList[indexPath.row]["count"]!)명"
            cell.followercount.font = UIFont(name: "BM DoHyeon OTF", size : 15)!
            return cell
        }
        //cell.imageView?.image
    }
}
extension SubSearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        if segment.selectedSegmentIndex == 1 { // 사람인 상태에서 검색에서 누를 시
            self.UserKeyForPrepare(self.SearchList[indexPath.row]["사용자 명"]!)
        } else if segment.selectedSegmentIndex == 2 { //태그 검색하고 누르면
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HashTagView") as! HashTagViewController
            vc.HashTagName = self.SearchTagList[self.index]["Tag"]!
            vc.modalPresentationStyle = .popover
            present(vc, animated: true, completion: nil)
        } else {
            self.UserKeyForPrepare(self.SearchList[indexPath.row]["사용자 명"]!)
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
                return
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
    @objc func ActSegmentClick() {
        if segment.selectedSegmentIndex == 0 {
            self.SearchController.searchBar.text = ""
            self.PopularList()
        } else if segment.selectedSegmentIndex == 1 {
            self.SearchController.searchBar.text = ""
            self.SearchList.removeAll()
            self.SearchResultTable.reloadData()
        } else {
            self.SearchController.searchBar.text = ""
            self.SearchTagList.removeAll()
            self.SearchResultTable.reloadData()
        }
    }
    func popularFetch() {
        for i in 0...2 {
            ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let item = snapshot.value as? [String : AnyObject] {
                    for(key, value) in item {
                        if key == self.popularList[i]["key"] {
                            
                            if let user = value["UserProfile"] as? [String : String] {
                                self.SearchList.append(user)
                            }
                        } else {
                            continue
                        }
                    }
                    self.SearchResultTable.reloadData()
                }
                
            })
        }
    }
    func Sort() {
        for i in (1..<self.popularList.count).reversed() {
            for j in 0..<i {
                if Int(self.popularList[j]["count"]!)! >= Int(self.popularList[j+1]["count"]!)! { // 맨 앞 값거나 크면 그대로
                    continue
                } else { //앞 값이 작고 뒷 값이 크다 그래서 스왑을 해야한다.
                    let temp = self.popularList[j]
                    self.popularList[j] = self.popularList[j+1]
                    self.popularList[j+1] = temp
                }
            }
        }
        popularFetch()
    }
    func PopularList() {
        self.SearchList.removeAll()
        ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for (key, value) in item {
                    if value["Follower"] as? [String : String] != nil { //팔로워 존재
                        for (_, value1) in (value["Follower"] as? [String : String])! {
                            self.followerList.append(value1)
                        }
                    }
                    self.popularList.append(["key" : key , "count" : "\(self.followerList.count)"])
                    self.followerList.removeAll()//다 넣고 삭제하고
                }
                //이 반복문이 끝나면 정렬하러 들어간다.
                print(self.popularList)
                self.Sort()
            }
        })
        ref?.removeAllObservers()
    }
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
    func UserKeyForPrepare(_ key1 : String) {
        ref?.child("User").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for(key,value) in item {
                    if let dic = value["UserProfile"] as? [String : String]{
                        if dic["사용자 명"] == key1 {
                            self.UserKeyForPrepare = key
                            self.UserName = dic["사용자 명"]!
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
            if self.SearchTagList.count != 0 { // 하나라도 값이 있을때 중복확인해라
                for hashtag in self.SearchTagList {
                    if hashtag["Tag"] == tag { //중복
                        return
                    } else { //없는 값
                        self.SearchTagList.append(["Tag" : tag, "Count" : "\(snapshot.childrenCount)"])
                    }
                }
            } else { // 0이다
                self.SearchTagList.append(["Tag" : tag, "Count" : "\(snapshot.childrenCount)"])
            }
            
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
