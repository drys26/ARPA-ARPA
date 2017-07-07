//
//  FullScreenImageController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 06/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class FullScreenImageController: UIViewController {

    var photo: UIImage!
    var newSize: CGSize!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageView.image = photo
        let widthRatio: CGFloat = imageView.bounds.size.width / (imageView.image?.size.width)!
        let heightRatio: CGFloat = imageView.bounds.size.height / (imageView.image?.size.height)!
        let scale: CGFloat = min(widthRatio, heightRatio)
        let imageWidth: CGFloat = scale * (imageView.image?.size.width)!
        let imageHeight: CGFloat = scale * (imageView.image?.size.height)!
        
        imageView.frame = CGRect(x: 0, y: 50, width: imageWidth, height: imageHeight)
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeFullScreen(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }

}

