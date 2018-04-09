//
//  CommentTableViewCell.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 6..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import ActiveLabel
import SnapKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var ProFileImage: UIImageView!
    @IBOutlet var TimeAgo: UILabel!
    @IBOutlet var LikeBut: UIButton!
    @IBOutlet var ReplyBut: UIButton!
    var Comment = ActiveLabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(Comment)
        ProFileImage.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.width.equalTo(self.bounds.width/5)
            make.height.equalTo(self.bounds.height-20)
            make.centerY.equalTo(self)
        }
        Comment.snp.makeConstraints { (make) in
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.width.equalTo(CommonVariable.screenWidth/2)
            make.height.equalTo(self.bounds.height/1.5)
            make.top.equalTo(self)
        }
        TimeAgo.snp.makeConstraints { (make) in
            make.left.equalTo(Comment)
            make.width.equalTo(self.bounds.width/5)
            make.height.equalTo(self.bounds.height/4)
            make.top.equalTo(Comment.snp.bottom)
        }
        ReplyBut.snp.makeConstraints { (make) in
            make.size.equalTo(TimeAgo)
            make.top.equalTo(TimeAgo)
            make.left.equalTo(TimeAgo.snp.right).offset(30)
        }
        LikeBut.snp.makeConstraints { (make) in
            make.width.equalTo(self.bounds.width/8)
            make.height.equalTo(self.bounds.height/4)
            make.right.equalTo(self)
            make.centerY.equalTo(ProFileImage)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
