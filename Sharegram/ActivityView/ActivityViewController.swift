//
//  ActivityViewController.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import ScrollableSegmentedControl
import CoreLocation
class ActivityViewController: UIViewController {
    var segment = ScrollableSegmentedControl()
    var MapView = MTMapView()
    var currentLocation = CLLocation() // 현재 위치를 담을
    var location : CLLocation!
    var locationManager = CLLocationManager()
    var item = [MTMapPOIItem]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addSubview(segment)
        self.view.addSubview(MapView)
        
        isAuthorizedtoGetUserLocation() //위치 인증
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 200.0
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            
        }
        segment.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight/7)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
        segment.segmentStyle = .textOnly
        segment.insertSegment(withTitle: "100", at: 0)
        segment.insertSegment(withTitle: "500", at: 1)
        segment.insertSegment(withTitle: "1000", at: 2)
        segment.selectedSegmentIndex = 0
        segment.selectedSegmentContentColor = UIColor.black
        segment.segmentContentColor = UIColor.lightGray
        segment.underlineSelected = false
        
        MapView.snp.makeConstraints { (make) in
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight)
            make.top.equalTo(segment.snp.bottom)
        }
        MapView.delegate = self
        
        MapView.removeAllPOIItems()

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
extension ActivityViewController : MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) { //위치를 사용자가 지정을 하면
        self.item.removeAll()
        self.item.append(poiItem(latitude: mapPoint.mapPointGeo().latitude, longitude: mapPoint.mapPointGeo().longitude))
        self.MapView.addPOIItems(self.item)
        location = CLLocation(latitude: mapPoint.mapPointGeo().latitude, longitude: mapPoint.mapPointGeo().longitude) // 찍은 위치를 저장한다.
        delay(0.5) { // 위치를 찍으면 0.5초뒤에 거리 뷰로 넘어간다.
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DistanceView") as! DistanceViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.PostLocation = self.location
            let str = self.segment.titleForSegment(at: self.segment.selectedSegmentIndex)!
            vc.distance = Double(str)! //현재 선택된 거리 기준으로 넘긴다.
            self.present(vc, animated: true, completion: nil)
        }
        return
    }
    func poiItem(latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.markerType = .redPin
        //item.customImage = MapImage
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)    // 마커 위치 조정
        return item
    }
}
extension ActivityViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        let location = locations.last! as CLLocation
        currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        MapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)), zoomLevel: 3, animated: false)
    }
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
extension ActivityViewController {
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}
