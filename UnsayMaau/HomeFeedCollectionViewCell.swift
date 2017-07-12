//
//  HomeFeedCollectionViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class HomeFeedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var authorImageView: UIImageView!
    
    @IBOutlet weak var authorDisplayName: UILabel!
    
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var commandButton: UIButton!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var followBtn: UIButton!

    @IBOutlet weak var rootDescriptionCaption: UIStackView!
    
    @IBOutlet weak var userInfoRootView: UIView!
    
    override func prepareForReuse() {
        
        authorImageView.image = nil
        authorDisplayName.text = nil
        locationText.text = nil
        commandButton.setTitle(nil, for: .normal)
        let rootViewsArr = rootView.subviews
        let rootDescriptionArr = rootDescriptionCaption.subviews
        
        for views in rootViewsArr {
            views.removeFromSuperview()
        }
        for views in rootDescriptionArr {
            views.removeFromSuperview()
        }
        
        super.prepareForReuse()
    }
    
//    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
//        
//        let estimatedHeight = rootView.frame.height + userInfoRootView.frame.height + rootDescriptionCaption.frame.height + 16 + 20
//        
//        self.layoutIfNeeded()
//        
//        return CGSize(width: (superview?.frame.width)!, height: estimatedHeight)
//        
//    }
    
}
