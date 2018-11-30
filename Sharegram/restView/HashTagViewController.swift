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

class HashTagViewController: UIViewController { // 해시태그에 해당하는 게시물들을 포함한 뷰 최근과 근처 게시물이 있따.
    
    @IBOutlet var navi: UINavigationBar!
    @IBOutlet var HashTagPostImage: UIImageView!
    @IBOutlet var NumberOfPost: UILabel!
    @IBOutlet var SubText: UILabel!
    @IBOutlet var HashTagFollow: UIButton!
    @IBOutlet var HashTagPostCollection: UICollectionView!
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var segment = ScrollableSegmentedControl()
    var ref : DatabaseReference?
    var width : CGFloat = CommonVariable.screenWidth
    var height : CGFloat = CommonVariable.screenHeight
    var HashTagName : String = ""
    var postId : String = ""
    var HashTagPost = [Post]()
    var LocationPost = [Post]()
    var index : Int = 0
    var count : Int = 0
    var currentLocation : CLLocation!
    var locationManager:CLLocationManager!
    
    
    override func viewWillAppear(_ animated: Bool) {
        print(HashTagName)

        ref = Database.database().reference()
        
        
        HashTagPostFetch()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(segment)
        // Do any additional setup after loading the view.
        isAuthorizedtoGetUserLocation()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 200.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        navi.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(10)
        }
        UINavigationBar.appearance().barTintColor = UIColor.white
        navi.tintColor = UIColor.black
        navi.topItem?.title = HashTagName
        HashTagPostImage.snp.makeConstraints { (make) in
            make.width.equalTo(width/5)
            make.height.equalTo(height/10)
            make.top.equalTo(navi.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
        }
        HashTagPostImage.layer.cornerRadius = 30
        HashTagPostImage.clipsToBounds = true
        
        NumberOfPost.snp.makeConstraints { (make) in
            make.width.equalTo(width/6)
            make.height.equalTo(height/30)
            make.right.equalTo(HashTagFollow.snp.centerX)
            make.centerY.equalTo(HashTagPostImage)
        }
        NumberOfPost.textAlignment = .right
        
        
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
        HashTagFollow.setTitle("", for: .normal)
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
        let attr = NSDictionary(object: UIFont(name: "BM DoHyeon OTF", size : 15)!, forKey: NSAttributedStringKey.font as NSCopying)
        segment.setTitleTextAttributes(attr as? [NSAttributedStringKey : Any], for: .normal)
        segment.selectedSegmentContentColor = UIColor.lightGray
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(ActSegClicked(_:)), for: .valueChanged)
        HashTagPostCollection.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(segment.snp.bottom)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! SinglePostViewController
        destination.UserPost = self.HashTagPost[self.index]
    }
 

}
extension HashTagViewController {
    @objc func ActSegClicked(_ sender : ScrollableSegmentedControl) {
        if self.segment.selectedSegmentIndex == 0 { //최신 컨텐츠
            self.DateSort()
            self.HashTagPostCollection.reloadData()
            //함수1
            return
        } else { // 근처
            self.DistanceFilter()
            self.HashTagPostCollection.reloadData()
            return
            //함수2
        }
    }
    func DistanceFilter() { // 현재 위치를 받아서 가까운 근처의 컨텐츠를 보여준다.
        self.LocationPost.removeAll()
        print(self.currentLocation)
        if self.currentLocation != nil { // 위치를 받았으면
            for i in 0..<self.HashTagPost.count {
                if self.HashTagPost[i].lat == 0 { //위치가 없는 게시물이면 넘어가
                    continue
                } else {
                    let PostLocation = CLLocation(latitude: self.HashTagPost[i].lat!, longitude: self.HashTagPost[i].lon!)
                    let meter = Int(self.currentLocation.distance(from: PostLocation))
                    if meter <= 500 {
                        self.LocationPost.append(self.HashTagPost[i])
                    }
                }
            }
            self.HashTagPostCollection.reloadData()
        }

    }
    func HashTagPostFetch() { //해쉬태그 따오기
        self.HashTagPost.removeAll()
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
                                post.timeInterval = 0
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
                                post.timeInterval = 0
                                self.HashTagPost.append(post)
                            }
                        }
                    }
                    if self.HashTagPost.count == self.count { // 게시물을 다 땃을 때
                        print("시발?")
                        self.HashTagPostImage.sd_setImage(with: URL(string: self.HashTagPost[0].image!), completed: nil)
                        self.NumberOfPost.text = "\(self.count) "
                        if self.segment.selectedSegmentIndex == 0 { //최신 컨텐츠
                            self.DateSort()
                            self.HashTagPostCollection.reloadData()
                            //함수1
                            return
                        } else { // 근처
                            self.DistanceFilter()

                            return
                            //함수2
                        }

                    }
                }
            })
        ref?.removeAllObservers()
    }
    func DateSort() { //날짜 순 정렬 구조체 반환 함수
        for i in (1..<self.HashTagPost.count).reversed() {
            for j in 0..<i {
                if self.HashTagPost[j].timeInterval! < self.HashTagPost[j+1].timeInterval! { //맨 앞값이 작으면 가장 최근 포스트이기에
                    print("제일 작다는디?")
                    continue
                }
                else if self.HashTagPost[j].timeInterval! > self.HashTagPost[j+1].timeInterval! { //뒤에 값이 작으면
                    let postTemp = self.HashTagPost[j]
                    self.HashTagPost[j] = self.HashTagPost[j+1]
                    self.HashTagPost[j+1] = postTemp
                }
            }
        }
        return
    }
    func DateFetch() { // 날짜 따오기
        let date = Date()
        let format = DateFormatter()
        TimeZone.ReferenceType.default = TimeZone(abbreviation: "KST")!
        format.dateFormat = "yyyy-MM-dd"
        format.timeZone = TimeZone.ReferenceType.default
        CommonVariable.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommonVariable.formatter.locale = Locale(identifier: "ko_kr")
        //CommonVariable.formatter.timeZone = TimeZone.init(abbreviation: "KST")
        for i in 0..<self.HashTagPost.count {
            let Date = format.string(from: date)
            let caption = self.HashTagPost[i].timeAgo!.components(separatedBy: " ").map{ String($0) }
            let StartDate = format.date(from: Date)!.addingTimeInterval(32400)
            let endDate = format.date(from: caption[0])!.addingTimeInterval(32400) //게시물 작성한 날짜 일자로 계산
            let interval = StartDate.timeIntervalSince(endDate)
            if interval < 1 { // 하루 미만이면
                let start = CommonVariable.formatter.date(from: CommonVariable.formatter.string(from: date))!.addingTimeInterval(32400)
                let end = CommonVariable.formatter.date(from: self.HashTagPost[i].timeAgo!)!.addingTimeInterval(32400)
                let subinterval = Int(start.timeIntervalSince(end) / 60.0) //분 단위 계산
                self.HashTagPost[i].timeInterval = Int(subinterval * 60) // 초 차이
                print(subinterval)
                if subinterval > 60 { // 1시간 이상
                    self.HashTagPost[i].timeAgo = "\(Int(subinterval / 60))시간 전"
                }
                //print(interval)
                self.HashTagPost[i].timeAgo = "\(subinterval)분 전"
                continue
            }
            self.HashTagPost[i].timeInterval = Int(interval)
        }
        DateSort()
        return
    }
}
extension HashTagViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SinglePost") as! SinglePostViewController
        vc.UserPost = self.HashTagPost[self.index]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segment.selectedSegmentIndex == 0 { //최신
            let cell = HashTagPostCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let imageview = cell.viewWithTag(1) as? UIImageView
            imageview?.sd_setImage(with: URL(string: self.HashTagPost[indexPath.row].image!), completed: nil)
            return cell
        } else {
            let cell = HashTagPostCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let imageview = cell.viewWithTag(1) as? UIImageView
            imageview?.sd_setImage(with: URL(string: self.LocationPost[indexPath.row].image!), completed: nil)
            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segment.selectedSegmentIndex == 0 {
            return self.HashTagPost.count
        } else {
            return self.LocationPost.count
        }
        
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
extension HashTagViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        let location = locations.last! as CLLocation
        currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
