//
//  Comment.swift
//  UnsayMaau
//
//  Created by Nexusbond on 03/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import Foundation
import Firebase

class Comment {

    var ref: DatabaseReference
    var commentType: String
    var comment: String
    var userCommentID: String
    var commentKey: String
    
    init(snap: DataSnapshot) {
        self.commentKey = snap.key
        self.ref = snap.ref
        let value = snap.value as! [String: Any]
        self.commentType = value["comment_type"] as! String
        self.comment = value["comment"] as! String
        self.userCommentID = value["sender_id"] as! String
    }
    
}
