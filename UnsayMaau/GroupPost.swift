//
//  GroupPost.swift
//  UnsayMaau
//
//  Created by Nexusbond on 11/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import Foundation
import Firebase


class GroupPost: Equatable {
    
    var postRef: DatabaseReference
    var authorImageUrl: String
    var authorDisplayName: String
    var authorEmailAddress: String
    var authorImageID: String
    var frameImagesIDS: [String]
    var postDescription: String
    var frameType: String
    var postIsFinished: Bool
    var postKey: String
    var ref: DatabaseReference
    var postTimeCreated: Double
    
    init(post: DataSnapshot) {
        
        self.postRef = post.ref
        self.postKey = post.key
        self.postIsFinished = false
        let postDictionary = post.value as! [String: Any]
        self.postDescription = postDictionary["post_description"] as! String
        let authorInfo = postDictionary["author_info"] as! String
        self.postTimeCreated = postDictionary["timestamp"] as! Double
        self.authorImageID = authorInfo
        self.authorDisplayName = "1"
        self.authorEmailAddress = "1"
        self.authorImageUrl = ""
        self.ref = Database.database().reference()
        self.frameImagesIDS = []
        self.frameType = postDictionary["frame_type"] as! String
        self.frameImagesIDS.append(postDictionary["frame_one"] as! String)
        self.frameImagesIDS.append(postDictionary["frame_two"] as! String)
        if post.hasChild("finished") {
            self.postIsFinished = postDictionary["finished"] as! Bool
        }
        if post.hasChild("frame_three") {
            self.frameImagesIDS.append(postDictionary["frame_three"] as! String)
            if post.hasChild("frame_four") {
                self.frameImagesIDS.append(postDictionary["frame_four"] as! String)
            }
        }
        self.ref.child("Users").child(authorInfo).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String: Any]
            self.authorDisplayName = dictionary["display_name"] as! String
            self.authorEmailAddress = dictionary["email_address"] as! String
            self.authorImageUrl = dictionary["photo_url"] as! String
        })
    }
    
    static func == (lhs: GroupPost, rhs: GroupPost) -> Bool {
        return lhs.postKey == rhs.postKey
    }
}

