//
//  CameraViewController.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 1. 11..
//  Copyright © 2018년 이창화. All rights reserved.
//
// 바로 업로드 뷰
import UIKit
import SnapKit
import Firebase
import CoreLocation
import MobileCoreServices
import Photos
import SDWebImage
import PhotosUI
import CDAlertView
import Sharaku

protocol GetAccurateLocation {
    func getLocation(_ lat : Double , _ lon : Double)
}
class CameraViewController: UIViewController, UINavigationControllerDelegate, GetAccurateLocation {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var PhotoCollection: UICollectionView!
    
    let locationManager = CLLocationManager()
    var location : CLLocation!
    var object = variable()
    var imageArray = [UIImage]()
    let imagepicker : UIImagePickerController! = UIImagePickerController()
    var capture : UIImage!
    var flag = false
    var ref : DatabaseReference?
    var asset : PHAsset?
    var index = 0
    var fetchResult : PHFetchResult<PHAsset>!
    var address : String = ""
    @IBAction func ImageFiltering(_ sender: UIBarButtonItem) { // 이미지 필터링
        let ImageFilterView = SHViewController(image: myImageView.image!)
        ImageFilterView.delegate = self
        self.present(ImageFilterView, animated: true, completion: nil)
    }
    @IBAction func ActCamera(_ sender: UIBarButtonItem) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 200.0
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()

        }
       
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            flag = true
            imagepicker.delegate = self
            imagepicker.sourceType = .camera
            imagepicker.mediaTypes = [kUTTypeImage as String]
            imagepicker.allowsEditing = true
            imagepicker.showsCameraControls = true
            present(imagepicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func ActPhoto(_ sender: UIBarButtonItem) {
        flag = false
        if flag == false {
            object.lat = 0
            object.lon = 0
        }
        print("\(object.lat) , \(object.lon)")
        grabPhotos()
    }
    
    @IBAction func ActNext(_ sender: UIBarButtonItem) { // 다음화면 넘어가기
        performSegue(withIdentifier: "write", sender: self)
        self.capture = nil
        self.myImageView.image = nil
        self.object.lat = 0
        self.object.lon = 0
    }

    //if we have no permission to access user location, then ask user for permission.
    
    override func viewWillAppear(_ animated: Bool) {
        if imageArray.count == 0 {
            grabPhotos()
        } else {
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //isAuthorizedtoGetUserLocation()
        UINavigationBar.appearance().barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        isAuthorizedtoGetUserLocation()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "BM DoHyeon OTF", size : 17)!]
        
        myImageView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/2)
            make.top.equalTo(self.view).offset(44)
        }
        PhotoCollection.snp.makeConstraints { (make) in
            make.size.equalTo(myImageView)
            make.top.equalTo(myImageView.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        // Do any additional setup after loading the view.
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "write" {
            let destination = segue.destination as! WriteViewController
            destination.writeImage = myImageView.image
            if self.asset?.location == nil { //사진 찍고 바로 넘어갔을 때
                if self.location == nil { //카메라를 찍지 않았다.
                    asset = fetchResult[0]
                    destination.object.lat = 0
                    destination.object.lon = 0
                    return
                } else { // 카메라를 찍었기때문에 셀프 로케이션이 존재한다.
                    destination.object.lat = object.lat
                    destination.object.lon = object.lon
                }
            } else { //클릭을 해서 있는 사진을 골랐을 경우 ( 위치) asset.location이 있을 때
                destination.object.lat = (self.asset?.location?.coordinate.latitude)!
                destination.object.lon = (self.asset?.location?.coordinate.longitude)!
            }
        }
        else if segue.identifier == "AccurateLocation" { // 사진을 찍어서 위치값이 있을 때
            let destination = segue.destination as! AccurateLocationMapViewController
            destination.object.lat = self.object.lat
            destination.object.lon = self.object.lon
            destination.delegate = self
        }
    }
    
}
    
extension CameraViewController : UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //imageArray.removeAll()
        locationManager.stopUpdatingLocation()
        capture = info[UIImagePickerControllerEditedImage] as? UIImage


        self.dismiss(animated: true, completion: nil)
        myImageView.image = capture
        if CLLocationManager.locationServicesEnabled() {
            if location != nil {
                print(location)
                convertToAddressWith(coordinate: location)
            }
        }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension CameraViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myImageView.image = imageArray[indexPath.row]
        index = indexPath.row
        print(index)
        asset = fetchResult[index]
        print(asset?.location)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = PhotoCollection.frame.width / 4 - 1
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
extension CameraViewController : CLLocationManagerDelegate {
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last! as CLLocation
        print("Did location updates is called")
        object.lat = location.coordinate.latitude
        object.lon = location.coordinate.longitude
        self.locationManager.allowsBackgroundLocationUpdates = false
        //store the user location here to firebase or somewhere
    }
}
extension CameraViewController {
    func displayMessage() {
        let alertview = CDAlertView(title: "현재 위치는 \(convertToAddressWith(coordinate: location))", message: "다른 위치를 원하십니까?", type: CDAlertViewType.notification)
        let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.clear, handler: { (action) in
            self.performSegue(withIdentifier: "AccurateLocation", sender: self) //이전 화면으로 돌아간다 위치와 함께
        })
        let Cancel = CDAlertViewAction(title: "Cancel")
        alertview.add(action: OKAction)
        alertview.add(action: Cancel)
        alertview.show()
    }
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func getLocation(_ lat: Double, _ lon: Double) { // 정확한 위치를 받아왔을 때 그 위치로 변경.
        object.lat = lat
        object.lon = lon
        PHPhotoLibrary.shared().performChanges({
            print("일단찍자?")
            let request = PHAssetChangeRequest.creationRequestForAsset(from: self.capture!)
            request.location = CLLocation(latitude: lat, longitude: lon)
        }, completionHandler: nil)
        print(object.lat)
        print(object.lon)
    }
    func grabPhotos() {
        imageArray.removeAll()
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchResult.count > 0 {
            for i in 0..<fetchResult.count {
                imgManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                    self.imageArray.append(image!)
                    self.myImageView.image = self.imageArray[0]
                })
            }
        } else {
            print("You got no Photos!")
        }
        print(imageArray.count)
        DispatchQueue.main.async {
            self.PhotoCollection.reloadData()
        }
    }
    func convertToAddressWith(coordinate: CLLocation){
        print(coordinate.coordinate.latitude)
        print(coordinate.coordinate.longitude)
        let findLocation = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(findLocation) { (placemarks, error) -> Void in
            if error != nil {
                NSLog("\(error)")
                return
            }
            guard let placemark = placemarks?.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            self.address = addrList.joined(separator: " ")
            print(self.address)
            let alertview = CDAlertView(title: "현재 위치는 \(self.address))", message: "다른 위치를 원하십니까?", type: CDAlertViewType.notification)
            let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
                self.performSegue(withIdentifier: "AccurateLocation", sender: self) //위치를 찍으러 출발
            })
            let Cancel = CDAlertViewAction(title: "Cancel", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in //그대로 괜찮으면 라이브러리에 exif데이터와 함께 위치 저장
                PHPhotoLibrary.shared().performChanges({
                    print("일단찍자?")
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: self.capture!)
                    request.location = self.location
                }, completionHandler: nil)
            })
            alertview.add(action: OKAction)
            alertview.add(action: Cancel)
            if self.address != "" {
                alertview.show()
            }
            
        }
    }
}
extension CameraViewController : SHViewControllerDelegate {
    func shViewControllerImageDidFilter(image: UIImage) { //이미지에 필터를 씌운 후
        myImageView.image = image
    }
    
    func shViewControllerDidCancel() { //취소
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
