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
    override func viewWillAppear(_ animated: Bool) {
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
            make.top.equalTo(navi.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        HashTagPostImage.layer.cornerRadius = 30
        HashTagPostImage.clipsToBounds = true
        
        NumberOfPost.snp.makeConstraints { (make) in
            make.width.equalTo(width/6)
            make.height.equalTo(height/30)
            make.right.equalTo(HashTagFollow.snp.centerX)
            make.centerY.equalTo(HashTagPostImage)
        }
        SubText.snp.makeConstraints { (make) in
            make.size.equalTo(NumberOfPost)
            make.left.equalTo(HashTagFollow.snp.centerX)
            make.top.equalTo(NumberOfPost)
        }
        SubText.tintColor = UIColor.lightGray
        
        HashTagFollow.snp.makeConstraints { (make) in
            make.size.equalTo(width/3)
            make.height.equalTo(height/25)
            make.top.equalTo(NumberOfPost.snp.bottom).offset(5)
            make.left.equalTo(HashTagPostImage.snp.right).offset(20)
        }
        segment.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(height/20)
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
        if segment.selectedSegmentIndex == 0 { //최신 컨텐츠 날짜 정렬
            
        } else { //근처 컨텐츠 위치 정렬
            
        }
    }
}
extension HashTagViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
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
