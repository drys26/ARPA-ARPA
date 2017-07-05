//
//  AcceptGroupTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 05/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class AcceptGroupTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userInvitedImageView: UIImageView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var rootButtonStackView: UIStackView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userInvitedImageView.image = nil
        descriptionTextView.text = nil
        for btn in rootButtonStackView.subviews {
            btn.removeFromSuperview()
        }
    }

}
