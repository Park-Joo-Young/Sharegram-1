//
//  User.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 23..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit

struct User
{
    var username: String?
    var profileImage: UIImage?
}

struct CommonVariable {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let date = Date()
    static let formatter = DateFormatter()
    static let calendar = Calendar.current
    static let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    static let year =  components.year!
    static let month = components.month!
    static let day = components.day!
    static let hour = components.hour!
    static let min = components.minute!
}

