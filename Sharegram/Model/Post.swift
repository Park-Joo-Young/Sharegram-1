//
//  Post.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//

import Foundation

class Post{
    var caption: String
    var photoString: String
    
    init(captionText: String, photoStrings: String){
        caption = captionText
        photoString = photoStrings
    }
}
