//
//  PostTwoVerticalFrame.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class PostTwoVerticalFrame: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    @IBOutlet weak var postDescriptionText: UITextField!
    
    var imageData = [Data]()
    
    var imageUrl = [String]()
    
    var imageDescription = [String]()
    
    var imageIDS = [String]()
    
    var isFirstFrame: Bool = false
    
    var isSecondFrame: Bool = false
    
    var ref: DatabaseReference!
    
    var postID: String!
    
    var imagesDictionary = [String: Any]()
    
    var frames = [1 , 2]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(postAction))
    }
    
    func editImageDesc(isFirstFrame: Bool){
        var stringDescription: String = "frame 1 description"
        if !isFirstFrame {
            stringDescription = "frame 2 description"
        }
        let alertController = UIAlertController(title: "Confirm", message: "Please input \(stringDescription)", preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                if isFirstFrame {
                    textField.text = self.imageDescription[0]
                } else {
                    textField.text = self.imageDescription[1]
                }
        })
        let action = UIAlertAction(title: "Update",style: .default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                if (isFirstFrame) {
                    self?.imageDescription.remove(at: 0)
                    self?.imageDescription.insert(enteredText!, at: 0)
                    print(self?.imageDescription[0])
                } else {
                    self?.imageDescription.remove(at: 1)
                    self?.imageDescription.insert(enteredText!, at: 1)
                    print(self?.imageDescription[1])
                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editFirstFrame(_ sender: Any) {
        editImageDesc(isFirstFrame: true)
    }
    
    @IBAction func editSecondFrame(_ sender: Any) {
        editImageDesc(isFirstFrame: false)
    }
    
    
    @IBAction func chooseFirstFrame(_ sender: Any) {
        presentImagePickerController(isFirstFrame: true)
    }
    
    @IBAction func chooseSecondFrame(_ sender: Any) {
        presentImagePickerController(isFirstFrame: false)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage , var imageData = UIImageJPEGRepresentation(selectedImage, 0.2) else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        if self.isFirstFrame {
            firstImageView.image = selectedImage
            if self.imageData.count > 0 {
                self.imageData.remove(at: 0)
            } else {
                self.imageData.insert(imageData, at: 0)
                print(self.imageData[0])
            }
        } else {
            secondImageView.image = selectedImage
            if self.imageData.count > 1 {
                self.imageData.remove(at: 1)
            } else {
                self.imageData.insert(imageData, at: 1)
                print(self.imageData[1])
            }
            
            //self.imageData.insert(imageData, at: 1)
            //print(self.imageData[1])
        }
        dismiss(animated: true, completion: { () -> Void in
            self.promptDescription(isFirstFrame: self.isFirstFrame)
        })
        
    }
    
    func promptDescription(isFirstFrame: Bool){
        var stringDescription: String = "frame 1 description"
        if !isFirstFrame {
            stringDescription = "frame 2 description"
        }
        let alertController = UIAlertController(title: "Confirm", message: "Please input \(stringDescription)", preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter something"
        })
        let action = UIAlertAction(title: "Submit",style: .default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                if (self?.isFirstFrame)! {
                    if (self?.imageDescription.count)! > 0 {
                        self?.imageDescription.remove(at: 0)
                    } else {
                        self?.imageDescription.insert(enteredText!, at: 0)
                        print(self?.imageDescription[0])
                    }
                    
                } else {
                    if (self?.imageDescription.count)! > 1 {
                        self?.imageDescription.remove(at: 1)
                    } else {
                        self?.imageDescription.insert(enteredText!, at: 1)
                        print(self?.imageDescription[1])
                    }
                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Enter Description"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerController(isFirstFrame: Bool){
        print("Clicked the image view")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        if isFirstFrame {
            self.isFirstFrame = true
            self.isSecondFrame = false
        } else {
            self.isSecondFrame = true
            self.isFirstFrame = false
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func updateImagesDictionary(count: Int , temporaryImageDictionary: [String: Any]){
        //imagesDictionary["\(imageIDS[count])"] = temporaryImageDictionary
        ref.child("Images").child(postID).child(imageIDS[count]).setValue(temporaryImageDictionary)
    }
    
    func postAction(){
        print("Post Action")
        postID = ref.childByAutoId().key
        imageIDS.append(ref.childByAutoId().key)
        imageIDS.append(ref.childByAutoId().key)
        uploadImage(datas: imageData)
        let postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"post_description":postDescriptionText.text] as [String : Any]
        ref.child("Posts").child(postID).setValue(postsDictionary)
        
    }
    
    func uploadImage(datas: [Data]) {
        for i in 0..<imageData.count{
            let storageRef = Storage.storage().reference(withPath: "Post_Images/\(imageIDS[i])")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "images/jpeg"
            print("Image Data \(imageData.count)")
            print("Image Description \(imageDescription.count)")
            print("Image Frames \(frames.count)")
            print(i)
            let uploadTask = storageRef.putData(imageData[i], metadata: uploadMetaData, completion: { (metadata,error) in
                if(error != nil){
                    print("I received an error! \(error?.localizedDescription ?? "null")")
                } else {
                    let downloadUrl = metadata!.downloadURL()?.absoluteString
                    print("Upload complete! Heres some metadata!! \(String(describing: metadata))")
                    print("Here's your download url \(downloadUrl!)")
                    let imageDict = ["image_url": downloadUrl!,"image_description":self.imageDescription[i],"frame_no": self.frames[i]] as [String : Any]
                    self.updateImagesDictionary(count: i,temporaryImageDictionary: imageDict)
                }
            })
        }
        // End Adding Post
        navigationController?.popToRootViewController(animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
