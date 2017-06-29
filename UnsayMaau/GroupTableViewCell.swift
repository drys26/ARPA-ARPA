//
//  GroupTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var groupNameText: UILabel!
    @IBOutlet weak var groupDescriptionText: UILabel!
    @IBOutlet weak var groupMembersText: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var rootView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
