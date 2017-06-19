//
//  Helpers.swift
//  UnsayMaau
//
//  Created by Nexusbond on 16/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import Foundation
import Firebase

class Helpers {}

protocol PostFrames {
    var imageClickIndex: Int {get set}
    var imageData: [Data] {get set}
    var imageDescription: [String] {get set}
    var imageIDS: [String] {get set}
    var frames: [Int] {get set}
    var ref: DatabaseReference {get set}
    var postID: String {get set}
    func promptDescription(index: Int)
    func editImageDesc(index: Int)
    func presentImagePickerController(index: Int)
    func updateImagesDictionary(count: Int , temporaryImagesDictionary: [String: Any])
    func postAction()
    func uploadImage(datas: [Data])
}


public enum Frames {
    case TWO_VERTICAL
    case FOUR_CROSS
}
