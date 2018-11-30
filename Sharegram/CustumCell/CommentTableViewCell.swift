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
    @IBOutlet var ReplyBut: UIButton!
    var Comment = ActiveLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(Comment)
        ProFileImage.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerY.equalTo(self)
        }
        Comment.snp.makeConstraints { (make) in
            make.left.equalTo(ProFileImage.snp.right).offset(5)
            make.width.lessThanOrEqualTo(CommonVariable.screenWidth/2)
            make.height.equalTo(self.bounds.height/1.5)
            make.top.equalTo(self)
        }

        TimeAgo.snp.makeConstraints { (make) in
            make.left.equalTo(Comment)
            make.width.equalTo(self.bounds.width/3)
            make.height.equalTo(self.bounds.height/4)
            make.top.equalTo(Comment.snp.bottom)
        }
        ReplyBut.snp.makeConstraints { (make) in
            make.size.equalTo(TimeAgo)
            make.top.equalTo(TimeAgo)
            make.left.equalTo(TimeAgo.snp.right).offset(10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
