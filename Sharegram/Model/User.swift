//
//  User.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 23..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit

//struct User : NSObject {
//    var PostID : String = ""
//    var AuthorName : String = ""
//    var AuthorImage : UIImage!
//    var AuthorCaption : String = ""
//}
class Userinfo : NSObject {
    var PostID : String = ""
    var AuthorName : String = ""
    var AuthorImage : UIImage!
    var AuthorCaption : String = ""
}

struct CommonVariable {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let date = Date()
    static let formatter = DateFormatter()
}

