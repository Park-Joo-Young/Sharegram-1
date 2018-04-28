//
//  ProFileView.swift
//  
//
//  Created by 이창화 on 2018. 3. 2..
//

import UIKit
import SnapKit
import ScrollableSegmentedControl
class ProFileView: UIView {
    
    @IBOutlet weak var ProFileImage: UIImageView!
    @IBOutlet weak var FollowerCount: UILabel!
    @IBOutlet weak var FollowerLabel: UILabel!
    @IBOutlet weak var ProFileEditBut: UIButton!
    //@IBOutlet weak var MySettingBut: UIButton!

    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowingLabel: UILabel!
    
    @IBOutlet weak var MyFostCollectionView: UICollectionView!
    var Segment = ScrollableSegmentedControl()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ProFileView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func awakeFromNib() {
        self.addSubview(Segment)
        self.frame.size = CGSize(width: CommonVariable.screenWidth, height: CommonVariable.screenHeight)
        
        ProFileImage.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(10)
            make.width.equalTo(70)
            make.height.equalTo(70)
        }
        
        FollowerCount.snp.makeConstraints { (make) in
            make.top.equalTo(ProFileImage)
            make.width.equalTo(UIScreen.main.bounds.width/7)
            make.height.equalTo(UIScreen.main.bounds.height/33)
            make.left.equalTo(ProFileEditBut)
        }
        FollowerCount.textAlignment = .center
        FollowerCount.text = ""
        //FollowerCount.adjustsFontSizeToFitWidth = true
        FollowerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(FollowerCount.snp.bottom)
            make.size.equalTo(FollowerCount)
            make.left.equalTo(FollowerCount)
        }
        
        FollowerLabel.text = "팔로워"
        //FollowerLabel.numberOfLines = 0
        FollowerLabel.textAlignment = .center
        FollowerLabel.textColor = UIColor.lightGray
        //FollowerLabel.adjustsFontSizeToFitWidth = true
        
        FollowingCount.snp.makeConstraints { (make) in
            make.top.equalTo(FollowerCount)
            make.size.equalTo(FollowerCount)
            make.right.equalTo(ProFileEditBut)
        }
        FollowingCount.textAlignment = .center
        FollowingCount.text = ""
        //FollowingCount.adjustsFontSizeToFitWidth = true
        
        FollowingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(FollowerLabel.snp.top)
            make.size.equalTo(FollowerCount)
            make.right.equalTo(ProFileEditBut.snp.right)
        }
        FollowingLabel.text = "팔로잉"
        FollowingLabel.textAlignment = .center
        FollowingLabel.textColor = UIColor.lightGray
        //FollowingLabel.adjustsFontSizeToFitWidth = true
        
        ProFileEditBut.snp.makeConstraints { (make) in
            make.top.equalTo(FollowerCount.snp.bottom).offset(40)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
            make.height.equalTo(UIScreen.main.bounds.height/30)
            make.left.equalTo(ProFileImage.snp.right).offset(20)
        }
        //ProFileEditBut.setTitle("프로필 수정", for: .normal)
        ProFileEditBut.backgroundColor = UIColor.white
        ProFileEditBut.layer.borderWidth = 1.5
        ProFileEditBut.layer.borderColor = UIColor.lightGray.cgColor
        ProFileEditBut.tintColor = UIColor.black

        
        Segment.snp.makeConstraints { (make) in
            make.top.equalTo(ProFileImage.snp.bottom).offset(30)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.height/18)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        Segment.segmentStyle = .imageOnly
        Segment.insertSegment(with: UIImage(named: "Squares.png")!, at: 0)
        Segment.insertSegment(with: UIImage(named: "Bars.png")!, at: 1)
        Segment.insertSegment(with: UIImage(named: "Man.png")!, at: 2)
        Segment.underlineSelected = false
        Segment.selectedSegmentContentColor = UIColor.black
        Segment.segmentContentColor = UIColor.gray
        Segment.backgroundColor = UIColor.white
        Segment.selectedSegmentIndex = 0
        Segment.tintColor = UIColor.lightGray
        //Segment.isUserInteractionEnabled = false
        
        MyFostCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(Segment.snp.bottom).offset(10)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        }
        MyFostCollectionView.backgroundColor = UIColor.white
        //UIColor(red: 210/255, green: 217/255, blue: 203/255, alpha: 1)
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
    }

}
