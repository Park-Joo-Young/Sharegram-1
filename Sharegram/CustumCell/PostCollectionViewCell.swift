//
//  PostCollectionViewCell.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 2. 22..
//  Copyright © 2018년 이창화.화All rights reserved.
//

import UIKit
import ActiveLabel
import SnapKit


class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ProFileImage: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var ExceptionBut: UIButton!
    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var LikeBut: UIButton!
    @IBOutlet weak var CommnetBut: UIButton!
    @IBOutlet weak var ConfigureBut: UIButton!
    @IBOutlet weak var LikeCountLabel: UILabel!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var FisrtComment: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!
    var Caption = ActiveLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
