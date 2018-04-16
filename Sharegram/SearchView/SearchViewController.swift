//
//  SearchViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 1. 11..
//  Copyright © 2018년 이창화. All rights reserved.
//  Write SatGatLee

import UIKit
import Firebase
import SnapKit
import SDWebImage

class SearchViewController: UIViewController{

    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    //검색 뷰

    var SearchController : UISearchController!
    var Posts = [Post]()
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    var ImageUrl : String = ""
    var index : Int = 0
    @IBOutlet weak var WholePostCollectionView: UICollectionView!
    @IBOutlet weak var WholePostImage: UIImageView!
    
    func SnapWholePosts() { // 전체 포스트 가져오기
        self.Posts.removeAll()
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let item = snapshot.value as! [String : AnyObject]
                for (_, value) in item {
                    print("여기좀 와주세요 아저시!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ㄱ")
                    if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                        let post = Post()
                        if value["latitude"] as? String == nil { //위치가 없으면
                            print("여기좀 와주세요 아저시!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ㄱ")
                            post.caption = Description
                            post.Id = ID
                            post.image = image
                            post.lat = 0.0
                            post.lon = 0.0
                            //post.numberOfLikes = Like
                            post.username = Author
                            post.PostId = postID
                            post.timeAgo = Date

                            self.Posts.append(post)
                        } else {
                            post.caption = Description
                            post.Id = ID
                            post.image = image
                            let lat = value["latitude"] as? String
                            let lon = value["longitude"] as? String
                            post.lat = Double(lat!)
                            post.lon = Double(lon!)
                            //post.numberOfLikes = Like
                            post.username = Author
                            post.PostId = postID
                            post.timeAgo = Date
                            self.Posts.append(post)
                        }
                    }
                }
            if self.Posts.count == Int(snapshot.childrenCount) {
                self.WholePostCollectionView.reloadData()
            }
        })
        ref?.removeAllObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.Posts.removeAll()
        ref = Database.database().reference()
        SearchController.searchBar.showsCancelButton = false
        SearchController.searchBar.resignFirstResponder()
        SnapWholePosts()
        
        WholePostCollectionView.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.delegate = self
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.barTintColor = UIColor.lightGray
        //self.definesPresentationContext = true
        self.navigationItem.titleView = SearchController.searchBar
        


        // Do any additional setup after loading the view.

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "Koloda" {
            let destination = segue.destination as! PostViewController
            destination.Id = self.Posts[index].Id!
        }
    }
}

extension SearchViewController : UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "Search") as! SubSearchViewController

        //performSegue(withIdentifier: "sub", sender: self)
//         vc.modalPresentationStyle = .overCurrentContext
//         present(vc, animated: false, completion: nil)
         //self.navigationItem.backBarButtonItem?.title = ""
         //navigationController?.pushViewController(vc, animated: true)
    }
    func presentSearchController(_ searchController: UISearchController) {
       //performSegue(withIdentifier: "sub", sender: self)
        performSegue(withIdentifier: "sub", sender: self)
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Test")
//        vc?.modalPresentationStyle = .popover
//        vc?.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)!)
//        //vc?.modalTransitionStyle = .flipHorizontal
//        self.present(vc!, animated: true, completion:  nil)
    }
}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        print(index)
        performSegue(withIdentifier: "Koloda", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.Posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = WholePostCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        print(self.Posts[indexPath.row].timeAgo!)
        imageView?.sd_setImage(with: URL(string: self.Posts[indexPath.row].image!), completed: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = WholePostCollectionView.frame.width / 3-1

        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

