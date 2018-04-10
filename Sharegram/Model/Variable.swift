//
//  Variable.swift
//  Sharegram
//
//  Created by apple on 2018. 1. 10..
//  Copyright © 2018년 박주영. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import CDAlertView

class variable {
 // 공통적으로 쓰는 변수들 여따가
    var lat : Double = 0
    var lon : Double = 0
    var dic :  [[String : String]] = [[:]]
    func DisplayMessage (_ title : String , _ message : String) {
        let alertview = CDAlertView(title: title, message: message, type: CDAlertViewType.notification)
        let OKAction = CDAlertViewAction(title: "Ok", font: UIFont.systemFont(ofSize: 16), textColor: UIColor.black, backgroundColor: UIColor.white, handler: { (action) in
            return
        })
        alertview.add(action: OKAction)
        alertview.show()
    }
}

struct HashTag {
    var name : String
    var count : String
    
}

struct HashtagTokenizer : TokenizerType, DefaultTokenizerType {
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return scalar == UnicodeScalar(35)
    }
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.letters.contains(scalar)
    }
}

