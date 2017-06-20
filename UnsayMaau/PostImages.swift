//
//  PostImages.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class PostImages {
    
    var imageUrl: String
    var imageDescription: String
    var frameNumber: Int
    
    
    init(snap: DataSnapshot) {
        let imagesDict = snap.value as! [String: Any]
        self.imageUrl = imagesDict["image_url"] as! String
        self.frameNumber = imagesDict["frame_no"] as! Int
        self.imageDescription = imagesDict["image_description"] as! String
    }
    
}
