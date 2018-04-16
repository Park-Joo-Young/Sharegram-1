//
//  CommentReplyTableViewCell.swift
//  Sharegram
//
//  Created by apple on 2018. 4. 8..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
import ActiveLabel

class CommentReplyTableViewCell: UITableViewCell {
    @IBOutlet var ProFileImage: UIImageView!
    @IBOutlet var TimeAgo: UILabel!
    @IBOutlet var arrow: UIImageView!
    var Comment = ActiveLabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(Comment)
        ProFileImage.snp.makeConstraints { (make) in
            make.left.equalTo(arrow.snp.right).offset(10)
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
            make.width.equalTo(self.bounds.width/3)
            make.height.equalTo(self.bounds.height/4)
            make.top.equalTo(Comment.snp.bottom)
        }
        arrow.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.size.equalTo(TimeAgo)
            make.top.equalTo(ProFileImage)
        }
        arrow.image = UIImage(named: "Replyarrow.png")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
