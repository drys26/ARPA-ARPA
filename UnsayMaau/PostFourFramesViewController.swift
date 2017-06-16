//
//  PostFourFramesViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 16/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class PostFourFramesViewController: UIViewController, PostFrames, UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    var imageData: [Data] = []
    var imageDescription: [String] = []
    var imageIDS: [String] = []
    var frames: [Int] = []
    var ref: DatabaseReference = Database.database().reference()
    var postID: String = ""
    var imageClickIndex: Int = 0
    var frameType = "Four_Pic_Cross"
    
    
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    @IBOutlet weak var postDescriptionText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        frames = [1,2,3,4]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(postAction))
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        let thirdImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editThirdFrame))
        let fourthImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFourthFrame))
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        thirdImageLongGesture.minimumPressDuration = 1.0
        fourthImageLongGesture.minimumPressDuration = 1.0
        
        
        
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        firstImageView.isUserInteractionEnabled = true
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        secondImageView.isUserInteractionEnabled = true
        thirdImageView.addGestureRecognizer(thirdImageLongGesture)
        thirdImageView.isUserInteractionEnabled = true
        fourthImageView.addGestureRecognizer(fourthImageLongGesture)
        fourthImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editFirstFrame(){
        editImageDesc(index: 1)
    }
    func editSecondFrame(){
        editImageDesc(index: 2)
    }
    func editThirdFrame(){
        editImageDesc(index: 3)
    }
    func editFourthFrame(){
        editImageDesc(index: 4)
    }
    
    @IBAction func chooseFirstFrame(_ sender: Any) {
        presentImagePickerController(index: 1)
    }
    
    @IBAction func chooseSecondFrame(_ sender: Any) {
        presentImagePickerController(index: 2)
    }
    
    @IBAction func chooseThirdFrame(_ sender: Any) {
        presentImagePickerController(index: 3)
    }
    
    @IBAction func chooseFourthFrame(_ sender: Any) {
        presentImagePickerController(index: 4)
    }
    
    func editImageDesc(index: Int) {
        imageClickIndex = index
        var stringDescription: String = "frame \(index) description"
        let alertController = UIAlertController(title: "Confirm", message: "Please input \(stringDescription)", preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
               textField.text = self.imageDescription[index - 1]
        })
        let show = {() -> Void in
            print(self.imageDescription[(self.imageClickIndex) - 1])
            print("removed \(index - 1) index")
            self.showImageDesc()
        }
        let action = UIAlertAction(title: "Update",style: .default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                let insert = {() -> Void in
                    self?.imageDescription.insert(enteredText!, at: index - 1)
                }
                if (self?.imageDescription.count)! > index {
                    self?.imageDescription.remove(at: index - 1)
                    insert()
                    show()
                } else {
                    insert()
                    show()
                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showImageDesc(){
        for desc in imageDescription {
            print(desc)
        }
    }
    
    func promptDescription(index: Int) {
        var stringDescription: String = "frame \(imageClickIndex) description"
        let alertController = UIAlertController(title: "Confirm", message: "Please input \(stringDescription)", preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter image description"
        })
        let action = UIAlertAction(title: "Submit",style: .default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                if (self?.imageDescription.count)! > (self?.imageClickIndex)! {
                    self?.imageDescription.remove(at: index - 1)
                    self?.imageDescription.insert(enteredText!, at: index - 1)
                    print(self?.imageDescription[(self?.imageClickIndex)! - 1])
                    self?.showImageDesc()
                } else {
                    self?.imageDescription.insert(enteredText!, at: index - 1)
                    print(self?.imageDescription[(self?.imageClickIndex)! - 1])
                    self?.showImageDesc()
                }
//                switch index {
//                case 1:
//                    if (self?.imageDescription.count)! > 1 {
//                        self?.imageDescription.remove(at: 0)
//                    } else {
//                        self?.imageDescription.insert(enteredText!, at: 0)
//                        print(self?.imageDescription[0])
//                    }
//                    break
//                case 2:
//                    if (self?.imageDescription.count)! > 2 {
//                        self?.imageDescription.remove(at: 1)
//                    } else {
//                        self?.imageDescription.insert(enteredText!, at: 1)
//                        print(self?.imageDescription[1])
//                    }
//                    break
//                case 3:
//                    if (self?.imageDescription.count)! > 3 {
//                        self?.imageDescription.remove(at: 2)
//                    } else {
//                        self?.imageDescription.insert(enteredText!, at: 2)
//                        print(self?.imageDescription[2])
//                    }
//                    break
//                case 4:
//                    if (self?.imageDescription.count)! > 4 {
//                        self?.imageDescription.remove(at: 3)
//                    } else {
//                        self?.imageDescription.insert(enteredText!, at: 3)
//                        print(self?.imageDescription[3])
//                    }
//                    break
//                default:
//                    print("No Description")
//                    break
//                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePickerController(index: Int) {
        imageClickIndex = index
        print("Clicked the image view")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func updateImagesDictionary(count: Int, temporaryImagesDictionary: [String : Any]) {
        ref.child("Images").child(postID).child(imageIDS[count]).setValue(temporaryImagesDictionary)
    }
    
    func postAction() {
        print("Post Action")
        postID = ref.childByAutoId().key
        imageIDS.append(ref.childByAutoId().key)
        imageIDS.append(ref.childByAutoId().key)
        imageIDS.append(ref.childByAutoId().key)
        imageIDS.append(ref.childByAutoId().key)
        uploadImage(datas: imageData)
        let postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"frame_three": imageIDS[2],"frame_four": imageIDS[3],"post_description":postDescriptionText.text,"frame_type":frameType] as [String : Any]
        ref.child("Posts").child(postID).setValue(postsDictionary)
    }
    
    func uploadImage(datas: [Data]) {
        for i in 0...3 {
            print(i)
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
                    self.updateImagesDictionary(count: i,temporaryImagesDictionary: imageDict)
                }
            })
        }
        // End Adding Post
        navigationController?.popToRootViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage , var imageData = UIImageJPEGRepresentation(selectedImage, 0.2) else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        if self.imageData.count > imageClickIndex {
            self.imageData.remove(at: imageClickIndex - 1)
            self.imageData.insert(imageData, at: imageClickIndex - 1)
        } else {
            self.imageData.insert(imageData, at: imageClickIndex - 1)
        }
        
        switch imageClickIndex {
        case 1:
            firstImageView.image = selectedImage
            break
        case 2:
            secondImageView.image = selectedImage
            break
        case 3:
            thirdImageView.image = selectedImage
            break
        case 4:
            fourthImageView.image = selectedImage
            break
        default:
            print("No image View Selected")
            break
        }
        
        dismiss(animated: true, completion: { () -> Void in
            self.promptDescription(index: self.imageClickIndex)
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
