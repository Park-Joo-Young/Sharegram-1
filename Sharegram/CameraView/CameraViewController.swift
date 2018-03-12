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
class CameraViewController: UIViewController, UINavigationControllerDelegate {
    
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

    @IBAction func ActCamera(_ sender: UIBarButtonItem) {
        locationManager.startUpdatingLocation()
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            flag = true
            imagepicker.delegate = self
            imagepicker.sourceType = .camera
            imagepicker.mediaTypes = [kUTTypeImage as String]
            imagepicker.allowsEditing = true
            imagepicker.showsCameraControls = true
            present(imagepicker, animated: true, completion: {
                self.locationManager.stopUpdatingLocation()
            })
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
//        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
//            flag = true
//            imagepicker.delegate = self
//            imagepicker.sourceType = .photoLibrary
//            imagepicker.mediaTypes = [kUTTypeImage as String]
//            imagepicker.allowsEditing = false
//
//            present(imagepicker, animated: true, completion: nil)
//        }
    }
    
    @IBAction func ActNext(_ sender: UIBarButtonItem) { // 다음화면 넘어가기
        performSegue(withIdentifier: "write", sender: self)
        self.capture = nil
        self.myImageView.image = nil
        self.object.lat = 0
        self.object.lon = 0
    }

    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            locationManager.requestWhenInUseAuthorization()
        }
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
    override func viewWillAppear(_ animated: Bool) {
        if imageArray.count == 0 {
            grabPhotos()
        } else {
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
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
        let collectionLayout = PhotoCollection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionLayout?.invalidateLayout()
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
            destination.object.lat = object.lat
            destination.object.lon = object.lon
            if self.asset?.location == nil { //사진 찍고 바로 넘어갔을 때
                if self.location == nil { //카메라를 찍지 않았다.
                    asset = fetchResult[0]
                    destination.object.lat = (self.asset?.location?.coordinate.latitude)!
                    destination.object.lon = (self.asset?.location?.coordinate.longitude)!
                    return
                } else {
                    destination.object.lat = object.lat
                    destination.object.lon = object.lon
                }
            } else { //클릭을 해서 있는 사진을 골랐을 경우 ( 위치)
                destination.object.lat = (self.asset?.location?.coordinate.latitude)!
                destination.object.lon = (self.asset?.location?.coordinate.longitude)!
            }
            
        }
    }
}
extension CameraViewController : UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //imageArray.removeAll()
        //        locationManager.requestLocation()
        capture = info[UIImagePickerControllerEditedImage] as? UIImage

        PHPhotoLibrary.shared().performChanges({
            print("일단찍자?")
            let request = PHAssetChangeRequest.creationRequestForAsset(from: self.capture!)
            print("일단찍자?")
            if self.location != nil { // 위치를 동의하고 사진을 찍었을 시
                print("?")
                request.location = self.location
            }
        }, completionHandler: nil)
        
        //UIImageWriteToSavedPhotosAlbum(capture, self, nil, nil)
        
        //grabPhotos()
        self.dismiss(animated: true, completion: nil)
        myImageView.image = capture
        //grabPhotos()
        //locationManager.stopUpdatingLocation()
//        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
//        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
//            if flag {
//                //UIImageWriteToSavedPhotosAlbum(capture, self, nil, nil) //사진 저장
//                if CLLocationManager.locationServicesEnabled() {
//                    if location != nil {
//                        print("\(object.lat) , \(object.lon)")
//                        //convertToAddressWith(coordinate: location)
//                    }
//
//                }
//            }
//
//            imageArray.removeAll()
//            self.PhotoCollection.reloadData()
//            myImageView.image = capture
//        }

        
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
        //store the user location here to firebase or somewhere
    }
}
extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}
