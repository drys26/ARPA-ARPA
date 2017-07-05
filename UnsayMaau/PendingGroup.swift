//
//  PendingGroup.swift
//  UnsayMaau
//
//  Created by Nexusbond on 05/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import Foundation
import Firebase

class PendingGroup {

    var ref: DatabaseReference
    var groupId: String
    var userId: String
    
    init(snap: DataSnapshot) {
        self.ref = snap.ref
        self.groupId = snap.key
        self.userId = snap.value as! String
    }
}
