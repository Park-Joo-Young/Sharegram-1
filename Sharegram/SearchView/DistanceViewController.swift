//
//  DistanceViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 14..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import CoreLocation

class DistanceViewController: UIViewController {
    
    var DistanceArray = [Post]()
    var PostLocation = CLLocation()
    var ref : DatabaseReference?
    var index : Int = 0
    var distance : Double = 0
    @IBOutlet var DistancePostView: UICollectionView!
    @IBOutlet var navi: UINavigationBar!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        
        DistancePostFetch()

        //navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        navi.topItem?.title = "근처 게시물"
        navi.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        navi.tintColor = UIColor.black
        DistancePostView.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            //make.height.equalTo(CommonVariable.screenHeight)
            make.left.equalTo(self.view)
            make.top.equalTo(navi.snp.bottom)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        // Do any additional setup after loading the view.
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
        let destination = segue.destination as! SinglePostViewController
        destination.UserPost = self.DistanceArray[self.index]
    }
 

}
extension DistanceViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        if self.DistanceArray.count != 0 {
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "SinglePost") as! SinglePostViewController
            vc.UserPost = self.DistanceArray[self.index]
            present(vc, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.DistanceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dic = self.DistanceArray[indexPath.row]
        let cell = DistancePostView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.sd_setImage(with: URL(string: dic.image!), completed: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = DistancePostView.frame.width / 3-1
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
extension DistanceViewController {
    func DistancePostFetch() { // 100미터 반경안에 있는 게시물들 한 번에 모으기
        self.DistanceArray.removeAll()
        ref?.child("WholePosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("Nothing")
            } else {
                if let item = snapshot.value as? [String : AnyObject] {
                    for (_, value) in item {
                        if let Description = value["Description"] as? String, let Author = value["Author"] as? String, let Date = value["Date"] as? String, let ID = value["ID"] as? String, let image = value["image"] as? String , let postID = value["postID"] as? String {
                            if value["latitude"] as? String != nil { //위치가 있는 게시물들만
                                let lat = value["latitude"] as? String
                                let lon = value["longitude"] as? String
                                let Location = CLLocation(latitude: Double(lat!)!, longitude: Double(lon!)!)
                                let meter = self.PostLocation.distance(from: Location)
                                let post = Post()
                                if meter <= self.distance { //100미터 반경안에 들어오면
                                    post.caption = Description
                                    post.Id = ID
                                    post.image = image
                                    post.lat = Double(lat!)
                                    post.lon = Double(lon!)
                                    post.username = Author
                                    post.PostId = postID
                                    post.timeAgo = Date
                                    post.timeInterval = 0
                                    self.DistanceArray.append(post)
                                            print(self.DistanceArray)
                                } else {
                                    continue
                                }
                            }
                            
                        }
                    }
                    self.DistancePostView.reloadData()
                }
            }
        })
        ref?.removeAllObservers()
        }
}
