//
//  PostView.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 3. 9..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
import ActiveLabel

class PostView: UIView {
    
    @IBOutlet weak var ProFileImage: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var ExceptionBut: UIButton!
    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var LikeBut: UIButton!
    @IBOutlet weak var CommentBut: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!
    var Caption = ActiveLabel()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override func awakeFromNib() {
        UserName.isUserInteractionEnabled = true
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //draw(CGRect(x: 0.0, y: 0.0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight))
        self.frame.size = CGSize(width: CommonVariable.screenWidth/1.3, height: CommonVariable.screenHeight/1.6)
        self.addSubview(Caption)
        ProFileImage.snp.makeConstraints { (make) in
            make.top.equalTo(PostImage.snp.bottom).offset(5)
            make.left.equalTo(self)
            make.width.equalTo(PostImage.frame.width/3)
            make.height.equalTo(PostImage.frame.height/3.5)
        }
        ProFileImage.layer.cornerRadius = ProFileImage.frame.height / 10.0
        ProFileImage.clipsToBounds = true
        
        UserName.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width/2)
            make.height.equalTo(self.frame.height/30)
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.top.equalTo(ProFileImage)
            
        }
        UserName.isUserInteractionEnabled = true
        ExceptionBut.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.width.equalTo(self.frame.width/6)
            make.height.equalTo(UserName)
            make.top.equalTo(UserName)
        }
        PostImage.snp.makeConstraints { (make) in
            make.width.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(self.frame.height/1.8)
            make.left.equalTo(self)
        }
        PostImage.layer.borderWidth = 2.0
        PostImage.layer.borderColor = UIColor.black.cgColor
        
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(PostImage.frame.width/10)
            make.height.equalTo(PostImage.frame.height/10)
            make.right.equalTo(CommentBut.snp.left).offset(-10)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        }
        CommentBut.snp.makeConstraints { (make) in
            make.size.equalTo(LikeBut)
            make.right.equalTo(self.snp.right).offset(-10)
            make.bottom .equalTo(LikeBut)
        }
        Caption.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width/1.5)
            make.height.equalTo(ProFileImage.frame.height/1.8)
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.right.equalTo(self)
            make.centerY.equalTo(ProFileImage)
        }
        Caption.numberOfLines = 0
        TimeLabel.snp.makeConstraints { (make) in
            make.size.equalTo(UserName)
            make.top.equalTo(ProFileImage.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
        }
        
    }
 

}
