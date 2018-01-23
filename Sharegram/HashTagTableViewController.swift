//
//  HashTagTableViewController.swift
//  Sharegram
//
//  Created by apple on 2018. 1. 23..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import Firebase
class HashTagTableViewController: UITableViewController {
    var ref : DatabaseReference?
    var HashTagArray : [HashTag] = []
    var array : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        ref?.child("HashTagPosts").observe(.value, with: { (snapshot) in

            if snapshot.value is NSNull {
                print("Null")
            } else {
                //print(snapshot.childrenCount)
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key
                    self.aa(Int(snapshot.childrenCount), key)

                }
                
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func aa(_ number : Int, _ key : String) {
        
        self.ref?.child("HashTagPosts").child(key).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if snapshot.key == "Count" {
                print("count")
                if let item = snapshot.value as? [String : String] {
                    self.HashTagArray.append(HashTag(name: item["Name"]!, count: item["Count"]!))
                    if self.HashTagArray.count == number {
                        self.tableView.reloadData()
                    }
                }
            }
        })
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
        return self.HashTagArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = self.HashTagArray[indexPath.row].name
        cell.detailTextLabel?.text = "\(self.HashTagArray[indexPath.row].count) 게시물"
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //선택시
        <#code#>
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
