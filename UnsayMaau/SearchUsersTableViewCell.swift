//
//  SearchUsersTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 04/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class SearchUsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
        userDisplayName.text = ""
        for btn in buttonStackView.subviews {
            btn.removeFromSuperview()
        }
    }

}
