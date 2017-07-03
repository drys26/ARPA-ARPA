//
//  AddGroupViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var groupNameText: UITextField!
    @IBOutlet weak var groupShortDescription: UITextField!
    
    @IBOutlet weak var groupStatusSegment: UISegmentedControl!
    
    var postsDictionary = [String:Any]()
    
    var ref: DatabaseReference!
    
    var groupPostId: String!
    
    var imageDataTemp: Data?
    
    var imageDataUrl: String?
    
    var backgroundImageId: String?
    
    var uid: String = (Auth.auth().currentUser?.uid)!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        // Set the Done Button in right bar button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.postAction))
        
        // Do any additional setup after loading the view.
        
    }
    
    func postAction() {
        print("Post Action")
        
        groupPostId = ref.childByAutoId().key
        
        if let imageData = imageDataTemp {
            uploadImagePartTwo(data: imageData)
        }

        var status: Bool!
        
        if groupStatusSegment.selectedSegmentIndex == 0 {
            status = false
        } else {
            status = true
        }
        
        let groupName = groupNameText.text
        
        var groupDescription: String = "NULL"
        
        if groupShortDescription.text != "" {
            groupDescription = groupShortDescription.text!
        }
        
        postsDictionary = ["group_name":groupName!,"group_description":groupDescription,"private_status": status,"search_name": groupName!.lowercased(),"admin_members":["\(uid)":true]]
        
        //ref.child("Posts").child(groupPostId).setValue(postsDictionary)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selectImageFromLibrary(_ sender: Any) {
        presentImagePickerController()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage , let imageData = UIImageJPEGRepresentation(selectedImage, 0.2) else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        backgroundImageView.image = selectedImage
        imageDataTemp = imageData
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerController(){
        print("Clicked the image view")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func uploadImagePartTwo(data: Data){
        let storageRef = Storage.storage().reference(withPath: "Group_Post_Images/\(groupPostId!).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "images/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetaData, completion: { (metadata,error) in
            if(error != nil){
                print("I received an error! \(error?.localizedDescription ?? "null")")
            } else {
                let downloadUrl = metadata!.downloadURL()
                print("Upload complete! Heres some metadata!! \(String(describing: metadata))")
                print("Here's your download url \(downloadUrl!)")
                self.postsDictionary["background_image_url"] = downloadUrl!.absoluteString
                self.updatePostDictionary()
            }
        })
        navigationController?.popViewController(animated: true)
    }
    
    func updatePostDictionary(){
        ref.child("Groups").child(groupPostId).setValue(postsDictionary)
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
