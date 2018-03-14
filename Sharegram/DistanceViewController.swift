//
//  DistanceViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 14..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class DistanceViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    var ref : DatabaseReference?
    func distance(_ Location : CLLocation) -> Double {
        var Total : Double = 0
        let StandardLocation = CLLocation(latitude: 35.2459522624302, longitude: 128.645564511433)
        
        let meter = StandardLocation.distance(from: Location)
        print(Int(round(meter)))
        Total += meter
        return Total
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref?.child("LocationPosts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? [String : AnyObject] {
                for (key, _) in item {
                    //print(key)
                    self.ref?.child("LocationPosts").child(key).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                        if let item = snapshot.value as? [String : AnyObject] {
                            for (_,value) in item {
                                //print(value["Like"] as! String)
                                let Location1 = CLLocation(latitude: Double(value["latitude"] as! String)!, longitude: Double(value["longitude"] as! String)!)
                                print(Location1)
                                self.distanceLabel.text = "\(self.distance(Location1))"
                            }
                        }
                    })
                }
                
                    //let Location1 = CLLocation(latitude: Double((value["latitude"] as? String)!)!, longitude: Double((value["longitude"] as? String)!)!)
                    //print(Location1)
                   // self.distanceLabel.text = "\(self.distance(Location1))"
            }
            
        })
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
