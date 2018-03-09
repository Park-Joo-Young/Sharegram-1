//
//  ProFileEditTableViewCell.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 3. 3..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
class ProFileEditTableViewCell: UITableViewCell {

    @IBOutlet weak var ProFileimage: UIImageView!
    @IBOutlet weak var EditBut: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ProFileimage.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width/2)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.height/3.5)
            make.top.equalTo(self).offset(20)
        }
        EditBut.snp.makeConstraints { (make) in
            make.width.equalTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.height/5)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
