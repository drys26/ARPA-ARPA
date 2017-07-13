//
//  FollowTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 10/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var followLocation: UILabel!
    @IBOutlet weak var followDisplayName: UILabel!
    @IBOutlet weak var followImageView: UIImageView!
    
    @IBOutlet weak var actionButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        followLocation.text = ""
        followDisplayName.text = ""
        followImageView.image = nil
        
    }

}
