//
//  Post.swift
//  Sharegram
//
//  Created by 박주영 on 2018. 1. 11..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit


class Post :NSObject// 게시물 구조체
{
    var username: String? //Author
    var userprofileimage : String?
    var timeAgo: String? // Date
    var caption: String? // Description
    var image: String? // Postimage
    var numberOfLikes: String? // like
    var lat : Double? //위도
    var lon : Double? //경도
    var Id : String?
    var PostId : String?
    var timeInterval : Int?
}
