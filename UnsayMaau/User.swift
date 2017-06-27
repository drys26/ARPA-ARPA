//
//  User.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class User {
    
    var email = ""
    var photoUrl = ""
    var displayName: String = ""
    var followersIDs: [String] = []
    var followingIDs: [String] = []
    
    
    init(snap: DataSnapshot) {
        let userDict = snap.value as! [String: Any]
        self.email = userDict["email_address"] as! String
        self.displayName = userDict["display_name"] as! String
        self.photoUrl = userDict["photo_url"] as! String
        if snap.hasChild("following") {
            let followingDictionary = userDict["following"] as! [String:Any]
            for (key , value) in followingDictionary {
                self.followingIDs.append(key)
            }
        }
        if snap.hasChild("followers") {
            let followingDictionary = userDict["followers"] as! [String:Any]
            for (key , value) in followingDictionary {
                self.followersIDs.append(key)
            }
        }
    }
    
}

