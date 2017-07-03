//
//  CommentTableViewCell.swift
//  UnsayMaau
//
//  Created by Nexusbond on 03/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell , UITextViewDelegate {
    
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentUserDisplayName: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var buttonStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    
    override func prepareForReuse() {
        commentImageView.image = nil
        commentUserDisplayName.text = nil
        commentTextView.text = nil
        for button in buttonStackView.subviews {
            button.removeFromSuperview()
        }
    }
}
