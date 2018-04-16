//
//  HasgTagViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 14..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import ScrollableSegmentedControl
import CoreLocation

class HashTagViewController: UIViewController {
    
    @IBOutlet var navi: UINavigationBar!
    @IBOutlet var HashTagPostImage: UIImageView!
    @IBOutlet var NumberOfPost: UILabel!
    @IBOutlet var SubText: UILabel!
    @IBOutlet var HashTagFollow: UIButton!
    @IBOutlet var HashTagPostCollection: UICollectionView!
    
    var segment = ScrollableSegmentedControl()
    var ref : DatabaseReference?
    var width : CGFloat = CommonVariable.screenWidth
    var height : CGFloat = CommonVariable.screenHeight
    var HashTagName : String = ""
    var HashTagPost = [Post]()
    var index : Int = 0
    var count : Int = 0
    override func viewWillAppear(_ animated: Bool) {
        print(HashTagName)
        self.view.addSubview(segment)
        ref = Database.database().reference()
        
        navi.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(10)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        HashTagPostImage.snp.makeConstraints { (make) in
            make.width.equalTo(width/5)
            make.height.equalTo(height/10)
            make.top.equalTo(navi.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
        }
        HashTagPostImage.makeRounded()
//        HashTagPostImage.layer.cornerRadius = 30
//        HashTagPostImage.clipsToBounds = true

        NumberOfPost.snp.makeConstraints { (make) in
            make.width.equalTo(width/6)
            make.height.equalTo(height/30)
            make.right.equalTo(HashTagFollow.snp.centerX)
            make.centerY.equalTo(HashTagPostImage)
        }
        NumberOfPost.textAlignment = .right
        NumberOfPost.text = "\(count) "

        SubText.snp.makeConstraints { (make) in
            make.size.equalTo(NumberOfPost)
            make.left.equalTo(HashTagFollow.snp.centerX)
            make.top.equalTo(NumberOfPost)
        }
        SubText.text = "게시물"
        SubText.tintColor = UIColor.lightGray
        
        HashTagFollow.snp.makeConstraints { (make) in
            make.size.equalTo(width/3)
            make.height.equalTo(height/25)
            make.top.equalTo(NumberOfPost.snp.bottom).offset(5)
            make.left.equalTo(HashTagPostImage.snp.right).offset(50)
        }
        segment.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(height/20)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(HashTagPostImage.snp.bottom).offset(10)
        }
        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "최신 컨텐츠", at: 0)
        segment.insertSegment(withTitle: "근처 컨텐츠", at: 1)
        segment.tintColor = UIColor.black
        segment.selectedSegmentContentColor = UIColor.lightGray
        segment.selectedSegmentIndex = 0
        
        HashTagPostCollection.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(segment.snp.bottom)
        }
        HashTagPostFetch()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HashTagViewController {
    func HashTagPostFetch() { //해쉬태그 따오기
            let hashtag = self.HashTagName.replacingOccurrences(of: "#", with: "")
            print(hashtag)
            ref?.child("HashTagPosts").child(hashtag).child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.count = Int(snapshot.childrenCount)
                if let item = snapshot.value as? [String : AnyObject] {
                    for(_, value) in item {
                        if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                            let post = Post()
                            if value["latitude"] as? String == nil { //위치가 없으면
                                print("여기좀 와주세요 아저시!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ㄱ")
                                post.caption = Description
                                post.Id = ID
                                post.image = image
                                post.username = Author
                                post.PostId = postID
                                post.timeAgo = Date
                                
                                self.HashTagPost.append(post)
                            } else {
                                post.caption = Description
                                post.Id = ID
                                post.image = image
                                let lat = value["latitude"] as? String
                                let lon = value["longitude"] as? String
                                post.lat = Double(lat!)
                                post.lon = Double(lon!)
                                post.username = Author
                                post.PostId = postID
                                post.timeAgo = Date
                                self.HashTagPost.append(post)
                            }
                        }
                    }
                    if self.HashTagPost.count == self.count { // 게시물을 다 땃을 때
                        print("시발?")
                        self.HashTagPostCollection.reloadData()
                        self.HashTagPostImage.sd_setImage(with: URL(string: self.HashTagPost[0].image!), completed: nil)
                        if self.segment.selectedSegmentIndex == 0 { //근처 컨텐츠
                            //함수1
                            return
                        } else {
                            return
                            //함수2
                        }

                    }
                }
            })
        ref?.removeAllObservers()
    }
}
extension HashTagViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = HashTagPostCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageview = cell.viewWithTag(1) as? UIImageView
        imageview?.sd_setImage(with: URL(string: self.HashTagPost[indexPath.row].image!), completed: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.HashTagPost.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = HashTagPostCollection.frame.width / 3-1
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
extension UIImageView {
    
    func makeRounded() {
        let radius = self.frame.width/2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
