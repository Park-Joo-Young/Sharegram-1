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
    @IBOutlet weak var TimeLabel: UILabel!
    var Caption = ActiveLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(Caption)
        ProFileImage.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self)
            make.width.equalTo(PostImage.frame.width/3)
            make.height.equalTo(PostImage.frame.height/5)
        }
        UserName.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width/3)
            make.height.equalTo(self.frame.height/30)
            make.left.equalTo(ProFileImage.snp.right).offset(10)
            make.centerY.equalTo(ProFileImage)
        }
        ExceptionBut.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.width.equalTo(self.frame.width/4)
            make.height.equalTo(UserName)
            make.centerY.equalTo(UserName)
        }
        PostImage.snp.makeConstraints { (make) in
            make.width.equalTo(self)
            make.top.equalTo(ProFileImage.snp.bottom).offset(10)
            make.height.equalTo(self.frame.height/2.2)
        }
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(PostImage.frame.width/10)
            make.height.equalTo(PostImage.frame.height/10)
            make.left.equalTo(self).offset(10)
            make.top.equalTo(PostImage.snp.bottom).offset(10)
        }
        CommnetBut.snp.makeConstraints { (make) in
            make.size.equalTo(LikeBut)
            make.left.equalTo(LikeBut.snp.right).offset(10)
            make.top.equalTo(LikeBut)
        }
        ConfigureBut.snp.makeConstraints { (make) in
            make.size.equalTo(LikeBut)
            make.left.equalTo(CommnetBut.snp.right).offset(10)
            make.top.equalTo(LikeBut)
        }
        LikeCountLabel.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width - 10)
            make.height.equalTo(self.frame.height / 30)
            make.top.equalTo(LikeBut.snp.bottom).offset(10)
            make.left.equalTo(LikeBut)
            
        }
        Caption.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width/1.5)
            make.height.equalTo(LikeCountLabel.frame.height*2)
            make.left.equalTo(LikeCountLabel)
            make.top.equalTo(LikeCountLabel.snp.bottom).offset(10)
        }
        TimeLabel.snp.makeConstraints { (make) in
            make.size.equalTo(LikeCountLabel)
            make.top.equalTo(Caption.snp.bottom).offset(30)
            make.left.equalTo(LikeBut)
        }
        
    }
}
