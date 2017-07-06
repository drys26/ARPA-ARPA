//
//  Group.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class Group: Equatable {

    var groupId: String
    var backgroundImageUrl: String
    var groupDescription: String
    var groupName: String
    var members: [User]
    var pendingMembers: [User]
    var invitedPendingMembers: [User]
    var admins: [User]
    var groupStatus: Bool
    var groupRef: DatabaseReference
    
    
    init(snap: DataSnapshot) {
        groupRef = snap.ref
        let groupDict = snap.value as! [String: Any]
        var ref = Database.database().reference()
        groupId = snap.key
        members = [User]()
        admins = [User]()
        invitedPendingMembers = [User]()
        pendingMembers = [User]()
        backgroundImageUrl = groupDict["background_image_url"] as! String
        groupDescription = groupDict["group_description"] as! String
        groupName = groupDict["group_name"] as! String
        groupStatus = groupDict["private_status"] as! Bool
        if snap.hasChild("admin_members") {
            let adminDict = groupDict["admin_members"] as! [String: Any]
            for (key , element) in adminDict {
                ref.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user = User(snap: snapshot)
                    self.admins.append(user)
                })
            }
        }
        
        if snap.hasChild("invited_pending_members") {
            let adminDict = groupDict["invited_pending_members"] as! [String: Any]
            for (key , element) in adminDict {
                ref.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user = User(snap: snapshot)
                    self.invitedPendingMembers.append(user)
                })
            }
        }
        
        if snap.hasChild("pending_members") {
            let pendingDict = groupDict["pending_members"] as! [String: Any]
            for (key , element) in pendingDict {
                ref.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user = User(snap: snapshot)
                    self.pendingMembers.append(user)
                })
            }
        }
        if snap.hasChild("members") {
            let pendingDict = groupDict["members"] as! [String: Any]
            for (key , element) in pendingDict {
                ref.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user = User(snap: snapshot)
                    self.members.append(user)
                })
            }
        }
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.groupId == rhs.groupId
    }
}
