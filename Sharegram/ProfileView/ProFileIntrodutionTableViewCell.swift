//
//  ProFileIntrodutionTableViewCell.swift
//  Sharegram
//
//  Created by 이창화 on 2018. 3. 3..
//  Copyright © 2018년 이창화. All rights reserved.
//

import UIKit
import SnapKit
class ProFileIntrodutionTableViewCell: UITableViewCell {


    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var introdutionTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        Label.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        introdutionTextField.snp.makeConstraints { (make) in
            make.left.equalTo(Label.snp.right).offset(30)
            make.width.equalTo(CommonVariable.screenWidth / 1.6)
            make.centerY.equalTo(self)
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
