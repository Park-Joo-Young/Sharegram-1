//
//  AccurateLocationMapViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 22..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation
import CDAlertView

class AccurateLocationMapViewController: UIViewController {
    var MapView = MTMapView()
    var object = variable()
    var delegate : GetAccurateLocation?
    var item = [MTMapPOIItem]()
    var location : CLLocation!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(MapView)
        MapView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.width.equalTo(CommonVariable.screenWidth)
            make.height.equalTo(CommonVariable.screenHeight)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
        MapView.delegate = self
        MapView.baseMapType = .standard
        MapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: object.lat, longitude: object.lon)), zoomLevel: 3, animated: false) //맵 중심을 이전에 사진찍었던거에서 잡고
        self.item.append(poiItem(latitude: object.lat, longitude: object.lon))
        self.MapView.addPOIItems(self.item)
        if object.lat == 0.0 { //위치가 없는 게시물이면 현재 위치 받아옴
            print("가자!")
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.distanceFilter = 200.0
                locationManager.requestWhenInUseAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
        }
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
extension AccurateLocationMapViewController {
    func convertToAddressWith(coordinate: CLLocation) {
        let findLocation = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        let geoCoder = CLGeocoder()
        var address : String = ""
        geoCoder.reverseGeocodeLocation(findLocation) { (placemarks, error) -> Void in
            if error != nil {
                NSLog("\(error.debugDescription)")
                return
            }
            guard let placemark = placemarks?.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            address = addrList.joined(separator: " ")
            let alertview = CDAlertView(title: address, message: "이 위치가 맞으십니까?", type: CDAlertViewType.notification)
            let OKAction = CDAlertViewAction(title: "Ok", font: UIFont(name: "BM DoHyeon OTF", size : 16)!, textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                self.delegate?.getLocation(self.location.coordinate.latitude, self.location.coordinate.longitude)
                self.navigationController?.popViewController(animated: true) //이전 화면으로 돌아간다 위치와 함께
                return true
            })
            let Cancel = CDAlertViewAction(title: "Cancel", font: UIFont(name: "BM DoHyeon OTF", size : 16)!, textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                return true
            })
            alertview.add(action: OKAction)
            alertview.add(action: Cancel)
            alertview.show()
        }
    }
}
extension AccurateLocationMapViewController : MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.item.removeAll()
        self.item.append(poiItem(latitude: mapPoint.mapPointGeo().latitude, longitude: mapPoint.mapPointGeo().longitude))
        self.MapView.addPOIItems(self.item)
        location = CLLocation(latitude: mapPoint.mapPointGeo().latitude, longitude: mapPoint.mapPointGeo().longitude)
        if location != nil && self.item.count != 0 { //위치와 마커가 둘 다 표시가 됐으면
          convertToAddressWith(coordinate: location)
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
extension AccurateLocationMapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        let location1 = locations.last! as CLLocation
        print(location1)
        location = CLLocation(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)
        self.item.append(poiItem(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        MapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), zoomLevel: 3, animated: false) //맵 중심을 이전에 사진찍었던거에서 잡고
        print(self.item)
        self.MapView.addPOIItems(self.item)
        locationManager.stopUpdatingLocation()
    }
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
