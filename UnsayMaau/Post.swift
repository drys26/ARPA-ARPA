//
//  Post.swift
//  UnsayMaau
//
//  Created by Nexusbond on 16/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import Foundation
import Firebase


class Post: Equatable {
    
    var postRef: DatabaseReference
    var authorImageUrl: String
    var authorDisplayName: String
    var authorEmailAddress: String
    var authorImageID: String
    //var postImageUrl: String
    var frameImagesIDS: [String]
    var postImagesInfos: [PostImages]
    var postTimeCreated: Double
    var postDescription: String
    var frameType: String
    var postIsFinished: Bool
    
    var postKey: String
    
    var postStatus: Bool
    
    init(post: DataSnapshot) {
        self.postRef = post.ref
        self.postKey = post.key
        self.postIsFinished = false
        
        let postDictionary = post.value as! [String: Any]
        self.postStatus = postDictionary["private_status"] as! Bool
        self.postDescription = postDictionary["post_description"] as! String
        self.postTimeCreated = postDictionary["timestamp"] as! Double
        //self.postImageUrl = postDictionary["post_photo_url"] as! String
        let authorInfo = postDictionary["author_info"] as! String
        let authorArr = authorInfo.components(separatedBy: ",")
        self.authorDisplayName = authorArr[0]
        self.authorEmailAddress = authorArr[1]
        self.authorImageUrl = authorArr[2]
        self.authorImageID = authorArr[3]
    
        self.frameImagesIDS = []
        self.postImagesInfos = []
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
        
        //getImages(imageIds: self.frameImagesIDS)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postKey == rhs.postKey
    }
    
//    func getImages(imageIds: [String]){
//        var ref = Database.database().reference()
//        for id in imageIds {
//            ref.child("Images").child(self.postKey).child(id).observeSingleEvent(of: .value, with: {(snapshot) in
//                self.postImagesInfos.append(PostImages(snap: snapshot))
//            })
//        }
//        displayUrls()
//    }
    
//    func displayUrls(){
//        for postImage in postImagesInfos {
//            print(postImage.imageUrl)
//        }
//    }
    
}
