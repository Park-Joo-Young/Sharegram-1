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
import Firebase

class PostView: UIView {
    
    @IBOutlet weak var ProFileImage: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var ExceptionBut: UIButton!
    @IBOutlet weak var PostImage: UIImageView!
    //@IBOutlet weak var LikeBut: UIButton!
    @IBOutlet weak var CommentBut: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!
    var Caption = ActiveLabel()
    var ref : DatabaseReference?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override func awakeFromNib() {
        UserName.isUserInteractionEnabled = true
        ref = Database.database().reference()
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //draw(CGRect(x: 0.0, y: 0.0, width: CommonVariable.screenWidth, height: CommonVariable.screenHeight))
        self.frame.size = CGSize(width: CommonVariable.screenWidth/1.3, height: CommonVariable.screenHeight/1.6)
        self.addSubview(Caption)
        print("\(CommonVariable.screenWidth/1.3)            \(CommonVariable.screenHeight/1.6)")
        ref = Database.database().reference()
        
        ProFileImage.snp.makeConstraints { (make) in
            make.top.equalTo(PostImage.snp.bottom).offset(5)
            make.left.equalTo(self)
            make.width.equalTo(PostImage.bounds.width / 3)
            make.height.equalTo(PostImage.bounds.height / 3.5)
        }
        ProFileImage.layer.cornerRadius = self.ProFileImage.frame.size.height / 2
        ProFileImage.clipsToBounds = true
        UserName.snp.makeConstraints { (make) in
            make.width.equalTo(self.bounds.width/2.5)
            make.height.equalTo(self.bounds.height/30)
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.top.equalTo(ProFileImage)
            
        }
        UserName.isUserInteractionEnabled = true
        ExceptionBut.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.width.equalTo(self.bounds.width/6)
            make.height.equalTo(UserName)
            make.top.equalTo(UserName)
        }
        ExceptionBut.setImage(UIImage(named: "exception.png"), for: .normal)
        PostImage.snp.makeConstraints { (make) in
            make.width.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(self.bounds.height/1.8)
            make.left.equalTo(self)
        }
        PostImage.layer.borderWidth = 2.0
        PostImage.layer.borderColor = UIColor.black.cgColor
        PostImage.sizeToFit()
        CommentBut.snp.makeConstraints { (make) in
            make.width.equalTo(self.bounds.width/10)
            make.height.equalTo(self.bounds.height/10)
            make.right.equalTo(self.snp.right).offset(-10)
            make.bottom.equalTo(self.snp.bottom).offset(-5)
        }
        Caption.snp.makeConstraints { (make) in
            make.width.equalTo(self.bounds.width/1.5)
            make.height.lessThanOrEqualTo(ProFileImage.frame.height/1.8)
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.right.equalTo(self)
            make.centerY.equalTo(ProFileImage)
        }
        TimeLabel.snp.makeConstraints { (make) in
            make.size.equalTo(UserName)
            make.top.equalTo(ProFileImage.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
        }
        
    }
}
