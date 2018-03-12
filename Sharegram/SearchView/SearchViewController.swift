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
        ref?.child("WholePosts").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                let post = Post()
                if item["latitude"] == nil && item["longitude"] == nil { //위치가 없으면
                    post.caption = item["Description"]
                    post.Id = item["ID"]
                    post.image = item["image"]
                    post.lat = 0
                    post.lon = 0
                    post.numberOfLikes = item["Like"]
                    post.username = item["Author"]
                    post.PostId = item["postID"]
                    post.timeAgo = item["Date"]
                    self.Posts.append(post)
                } else {
                    post.caption = item["Description"]
                    post.Id = item["ID"]
                    post.image = item["image"]
                    post.lat = Int(item["latitude"]!)
                    post.lon = Int(item["longitude"]!)
                    post.numberOfLikes = item["Like"]
                    post.username = item["Author"]
                    post.PostId = item["postID"]
                    post.timeAgo = item["Date"]
                    self.Posts.append(post)
                    self.WholePostCollectionView.reloadData()
                }

            }
        })
        ref?.removeAllObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.Posts.removeAll()
        SnapWholePosts()
        SearchController.searchBar.showsCancelButton = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        
        SearchController = UISearchController(searchResultsController: nil)
        SearchController.delegate = self
        SearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        SearchController.hidesNavigationBarDuringPresentation = false
        SearchController.dimsBackgroundDuringPresentation = false
        SearchController.searchBar.searchBarStyle = .prominent
        SearchController.searchBar.sizeToFit()
        SearchController.searchBar.barTintColor = UIColor.lightGray
    
        self.navigationItem.titleView = SearchController.searchBar
//        self.definesPresentationContext = false
        
        WholePostCollectionView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.top.equalTo(self.view)
        }
        let collectionLayout = WholePostCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionLayout?.invalidateLayout()
        // Do any additional setup after loading the view.

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "Post" {
            let destination = segue.destination as! PostViewController
            destination.Id = self.Posts[index].Id!
            //destination.Profileimage = self.ImageUrl
        } else if segue.identifier == "Koloda" {
            let destination = segue.destination as! PostView11Controller
            destination.Id = self.Posts[index].Id!
        }
    }
}

extension SearchViewController : UISearchResultsUpdating, UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
         //performSegue(withIdentifier: "Search", sender: self)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Search") as! SubSearchViewController
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    func presentSearchController(_ searchController: UISearchController) {
       
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Test")
//        vc?.modalPresentationStyle = .popover
//        vc?.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)!)
//        //vc?.modalTransitionStyle = .flipHorizontal
//        self.present(vc!, animated: true, completion:  nil)

        
    }
    func updateSearchResults(for searchController: UISearchController) {
         //performSegue(withIdentifier: "Search", sender: self)
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

