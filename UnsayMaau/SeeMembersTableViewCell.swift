//
//  SeeMembersTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class SeeMembersTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberDisplayName: UILabel!
    @IBOutlet weak var memberCommandButton: UIButton!
    
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
