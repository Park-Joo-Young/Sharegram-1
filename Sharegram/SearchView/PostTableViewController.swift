//
//  PostTableViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 14..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SnapKit

class PostTableViewController: UITableViewController {
    var Posts = Post()
    var PostImageView = UIImageView()
    var button = UIButton()
    var item = [MTMapPOIItem]()
    var MapImage : UIImage!
    override func viewWillAppear(_ animated: Bool) {
       PostImageView.sd_setImage(with: URL(string: Posts.image!), completed: nil)
       MapImage = PostImageView.image
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        MapImage.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        MapImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.navigationItem.titleView = UIImageView(image: PostImageView.image)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Posts.lat!)
        //self.navigationController?.isNavigationBarHidden = true
        //self.navigationItem.title = Posts.username!
        


        
        //tableView.addSubview(button)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { //맵
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
            
            if Posts.lat != nil { //위치 정보가 존재하면 맵을 불러옮
                cell.MapView.snp.makeConstraints({ (make) in
                    make.width.equalTo(self.view.frame.width)
                    make.height.equalTo(self.view.frame.height/3.5)
                })
                cell.MapView.delegate = self
                cell.MapView.baseMapType = .standard
                cell.MapView.setZoomLevel(2, animated: true)
                if self.MapImage != nil {
                    item.append(poiItem(latitude: Posts.lat!, longitude: Posts.lon!))
                } else {
                    cell.MapView.baseMapType = .hybrid
                }
                cell.MapView.addPOIItems(item)
                cell.MapView.fitAreaToShowAllPOIItems()
            } else {
                cell.MapView.baseMapType = .hybrid
                cell.Label.text = "이 사진은 위치정보가 없습니다."
                cell.Label.textColor = UIColor.white
            }

            return cell
        } else { // 댓글
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Fuck"
            return cell
        }
        // Configure the cell...
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerview = UIView()
        headerview.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height/4)
        }
        headerview.addSubview(PostImageView)
        PostImageView.snp.makeConstraints { (make) in
            make.size.equalTo(headerview)
        }
        return headerview
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.view.frame.height/4
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return self.view.frame.height/3.5
        } else {
            return 200
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PostTableViewController : MTMapViewDelegate {
    func poiItem(latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()

        item.markerType = .customImage
        item.customImage = MapImage
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)    // 마커 위치 조정
        return item
    }
}
