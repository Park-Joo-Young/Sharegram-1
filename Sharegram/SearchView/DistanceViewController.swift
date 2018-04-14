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
    
    var DistanceArray : [[String : String]] = []
    var PostLocation = CLLocation()
    var ref : DatabaseReference?
    var index : Int = 0
    @IBOutlet var DistancePostView: UICollectionView!
    @IBOutlet var navi: UINavigationBar!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        DistancePostView.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            //make.height.equalTo(CommonVariable.screenHeight)
            make.left.equalTo(self.view)
            make.top.equalTo(navi.snp.bottom)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        DistancePostFetch()
        //navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        destination.postID = self.DistanceArray[self.index]["postID"]!
    }
 

}
extension DistanceViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        performSegue(withIdentifier: "DistancePost", sender: self)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.DistanceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = DistancePostView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.sd_setImage(with: URL(string: self.DistanceArray[indexPath.row]["image"]!), completed: nil)
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
                        if let image = value["image"] as? String , let lat = value["latitude"] as? String , let lon = value["longitude"] as? String , let postId = value["postID"] as? String {
                            let Location = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
                            let meter = self.PostLocation.distance(from: Location)
                            if meter <= 100 { //100미터 반경안에 들어오면
                                self.DistanceArray.append(["image" : image, "postID" : postId])
                            } else {
                                continue
                            }
                        }
                    }
                    self.DistancePostView.reloadData()
                }
            }
        })
        ref?.removeAllObservers()
        return
    }
}
