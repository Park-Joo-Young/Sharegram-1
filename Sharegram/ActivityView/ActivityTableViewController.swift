//
//  ActivityTableViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 17..
//  Copyright © 2018년 박주영. All rights reserved.
//
import UIKit
import Firebase
import CoreLocation
import ScrollableSegmentedControl
import SDWebImage
import SnapKit

class ActivityTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    var object = variable()
    let segment = ScrollableSegmentedControl()
    var ref : DatabaseReference?
    let locationManager = CLLocationManager()
    var location = CLLocation() //현재위치받을친구
    var location2 = CLLocation()
    var width = CommonVariable.screenWidth
    var height = CommonVariable.screenHeight
    struct MyLocation {
        var postimg : String? = nil
        var profilename : String? = nil
        var postid : String? = nil
        var description : String? = nil
        var date : String? = nil
        var longitude : Double? = nil
        var latitude : Double? = nil
    }
    var locationArray = [Post]() //스냅샷한거 배열별로들어감.
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    //this method is called by the framework on         locationManager.requestLocation();
    //현재위치저장
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last! as CLLocation
        print(location)
        //store the user location here to firebase or somewhere
    }
    func DataInput(_ distanse : Int) { //
        self.locationArray.removeAll()
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
                                let location2 = CLLocation(latitude: Double(lat!)!, longitude: Double(lon!)!)
                                let meter = Int(self.location.distance(from: location2))
                                print(meter)
                                var data = Post()
                                if meter <= distanse { //100미터
                                        data.caption = Description
                                        data.image = image
                                        data.lon = Double(lon!)!
                                        data.lat = Double(lat!)!
                                        data.username = Author
                                        data.PostId = postID
                                        data.timeAgo = Date
                                        data.timeInterval = 0
                                    data.Id = ID
                                        self.locationArray.append(data)
                                        print(self.locationArray)
                                    
                                }
                        }
                    }
                }
                self.tableView.reloadData()
              }
            }
        })
        ref?.removeAllObservers()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        tableView.dataSource = self
        
        segment.frame = CGRect(x: 0, y: 0, width: width, height: height/20)
        self.view.addSubview(segment)

        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "100m", at: 0)
        segment.insertSegment(withTitle: "500m", at: 1)
        segment.insertSegment(withTitle: "그 외", at: 2) //예시용
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
        
        let SwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SwipeLeftAction))
        SwipeLeft.direction = .left
        
        let SwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SwipeRightAction))
        SwipeRight.direction = .right
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.tableView.tableHeaderView = segment
    }
    @objc func SwipeLeftAction() {
        segment.selectedSegmentIndex += 1
    }
    @objc func SwipeRightAction() {
        segment.selectedSegmentIndex -= 1
    }
    @objc func ActSegClicked(_ sender : ScrollableSegmentedControl) {
        if segment.selectedSegmentIndex == 0 { // 100
            print("세그먼트1")
            print(self.locationArray)
            //            self.locationArray.removeAll()
            DataInput(100)
            
        }  else if segment.selectedSegmentIndex == 1 { // 500
            print("세그먼트2")
            DataInput(500)
            
        } else if segment.selectedSegmentIndex == 2{
            DataInput(1000)
        }
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(locationArray.count)
        return locationArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        let label = cell.viewWithTag(2) as? UILabel
        label?.text = locationArray[indexPath.row].caption!
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.sd_setImage(with:URL(string: locationArray[indexPath.row].image!))
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Debug")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SinglePost") as! SinglePostViewController
        vc.UserPost = self.locationArray[indexPath.row]
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
//    override func tableView(_ tableview: UITableView, didSelectRowAt: IndexPath){
//
//    }
}
