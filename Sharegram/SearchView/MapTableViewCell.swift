//
//  MapTableViewCell.swift
//  Sharegram
//
//  Created by apple on 2018. 3. 16..
//  Copyright © 2018년 박주영. All rights reserved.
//

import UIKit
import SnapKit
class MapTableViewCell: UITableViewCell, MTMapViewDelegate {
    var MapView = MTMapView()
    var Label = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(MapView)
        self.addSubview(Label)

        Label.snp.makeConstraints { (make) in
            make.size.equalTo(MapView)
        }
        Label.textAlignment = .center
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
