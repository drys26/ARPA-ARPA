//
//  SelectImageFromLibraryViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 19/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class SelectImageFromLibraryViewController: UIViewController , PostFrames , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var postDescription: UITextField!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    
    
    var imageData: [Data] = []
    var imageDescription: [String] = []
    var imageViews: [UIImageView] = []
    var imageIDS: [String] = []
    var frames: [Int] = []
    var ref: DatabaseReference = Database.database().reference()
    var postID: String = ""
    var imageClickIndex: Int = 0
    
    var typeOfFrame: String!
    
    var uid: String = (Auth.auth().currentUser?.uid)!
    
    var postsDictionary = [String:Any]()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the Database Reference
        ref = Database.database().reference()
        
        // Get the User Data
        
        getUserData()
        
        frames = [1,2,3,4]
        
        // set the root distribution 
        
        rootStackView.distribution = .fillEqually
        
        // Set the Done Button in right bar button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(postAction))
        
        // Use switch to know what type of frame the user choose
        
        switch typeOfFrame {
        case "TWO_HORIZONTAL":
            print("two_horizontal")
            twoHorizontalFrames()
            break
        case "FOUR_CROSS":
            print("four_cross")
            fourCrossFrames()
            break
        case "TWO_VERTICAL":
            twoVerticalFrames()
            break
        case "THREE_VERTICAL":
            threeVerticalFrames()
            break
        case "THREE_HORIZONTAL":
            threeHorizontalFrames()
            break
        default:
            print("nothing")
            break
        }
    }
    
    func getUserData(){
        ref.child("Users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
            print(self.user.displayName)
            print(self.user.photoUrl)
        })
    }
    
    func twoHorizontalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        // set the user interaction to true
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        
        // Create an Long Tap Gesture Recognizer
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        
        // Add Minimun Duration of each Long Gesture
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        
        // Add A Tap Gesture
        
        let firstImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFirstFrame))
        let secondImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseSecondFrame))
        
        // Add Gesture Recognizer
        
        firstImageView.addGestureRecognizer(firstImageTapGesture)
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        secondImageView.addGestureRecognizer(secondImageTapGesture)
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        
    }
    
    func threeHorizontalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        let thirdImageView = UIImageView(image: UIImage(named: "number_3"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        
        // set the user interaction to true
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        thirdImageView.isUserInteractionEnabled = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        
        // Create an Long Tap Gesture Recognizer
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        let thirdImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editThirdFrame))
        
        // Add Minimun Duration of each Long Gesture
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        thirdImageLongGesture.minimumPressDuration = 1.0
        
        // Add A Tap Gesture
        
        let firstImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFirstFrame))
        let secondImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseSecondFrame))
        let thirdImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseThirdFrame))
        
        // Add Gesture Recognizer
        
        firstImageView.addGestureRecognizer(firstImageTapGesture)
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        secondImageView.addGestureRecognizer(secondImageTapGesture)
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        thirdImageView.addGestureRecognizer(thirdImageTapGesture)
        thirdImageView.addGestureRecognizer(thirdImageLongGesture)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        rootStackView.addArrangedSubview(thirdImageView)
    }
    
    func twoVerticalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        // set the user interaction to true
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        
        // Create an Long Tap Gesture Recognizer
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        
        // Add Minimun Duration of each Long Gesture
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        
        // Add A Tap Gesture
        
        let firstImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFirstFrame))
        let secondImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseSecondFrame))
        
        // Add Gesture Recognizer
        
        firstImageView.addGestureRecognizer(firstImageTapGesture)
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        secondImageView.addGestureRecognizer(secondImageTapGesture)
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        
    }
    
    func threeVerticalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        let thirdImageView = UIImageView(image: UIImage(named: "number_3"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        
        // set the user interaction to true
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        thirdImageView.isUserInteractionEnabled = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        
        // Create an Long Tap Gesture Recognizer
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        let thirdImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editThirdFrame))
        
        // Add Minimun Duration of each Long Gesture
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        thirdImageLongGesture.minimumPressDuration = 1.0
        
        // Add A Tap Gesture
        
        let firstImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFirstFrame))
        let secondImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseSecondFrame))
        let thirdImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseThirdFrame))
        
        // Add Gesture Recognizer
        
        firstImageView.addGestureRecognizer(firstImageTapGesture)
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        secondImageView.addGestureRecognizer(secondImageTapGesture)
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        thirdImageView.addGestureRecognizer(thirdImageTapGesture)
        thirdImageView.addGestureRecognizer(thirdImageLongGesture)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        rootStackView.addArrangedSubview(thirdImageView)
    }
    
    func fourCrossFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create 2 Stackviews 
        
        let upper = UIStackView()
        let lower = UIStackView()
        
        // set the children stackviews properties
        
        upper.distribution = .fillEqually
        upper.axis = .horizontal
        
        lower.distribution = .fillEqually
        lower.axis = .horizontal
        
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        let thirdImageView = UIImageView(image: UIImage(named: "number_3"))
        let fourthImageView = UIImageView(image: UIImage(named: "number_4"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        fourthImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        fourthImageView.clipsToBounds = true
        
        // set the user interaction to true
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        thirdImageView.isUserInteractionEnabled = true
        fourthImageView.isUserInteractionEnabled = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        imageViews.append(fourthImageView)
        
        // Create an Long Tap Gesture Recognizer
        
        let firstImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFirstFrame))
        let secondImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editSecondFrame))
        
        let thirdImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editThirdFrame))
        let fourthImageLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.editFourthFrame))
        
        // Add Minimun Duration of each Long Gesture
        
        firstImageLongGesture.minimumPressDuration = 1.0
        secondImageLongGesture.minimumPressDuration = 1.0
        
        thirdImageLongGesture.minimumPressDuration = 1.0
        fourthImageLongGesture.minimumPressDuration = 1.0
        
        // Add A Tap Gesture
        
        let firstImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFirstFrame))
        let secondImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseSecondFrame))
        
        let thirdImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseThirdFrame))
        let fourthImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseFourthFrame))
        
        // Add Gesture Recognizer
        
        firstImageView.addGestureRecognizer(firstImageTapGesture)
        firstImageView.addGestureRecognizer(firstImageLongGesture)
        secondImageView.addGestureRecognizer(secondImageTapGesture)
        secondImageView.addGestureRecognizer(secondImageLongGesture)
        
        thirdImageView.addGestureRecognizer(thirdImageTapGesture)
        thirdImageView.addGestureRecognizer(thirdImageLongGesture)
        fourthImageView.addGestureRecognizer(fourthImageTapGesture)
        fourthImageView.addGestureRecognizer(fourthImageLongGesture)
        
        
        // add view to upper and lower stackviews
        
        upper.addArrangedSubview(firstImageView)
        upper.addArrangedSubview(secondImageView)
        
        lower.addArrangedSubview(thirdImageView)
        lower.addArrangedSubview(fourthImageView)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(upper)
        rootStackView.addArrangedSubview(lower)
        
        
    }
    
    func chooseFirstFrame(){
        presentImagePickerController(index: 1)
    }
    
    func chooseSecondFrame(){
        presentImagePickerController(index: 2)
    }
    
    func chooseThirdFrame(){
        presentImagePickerController(index: 3)
    }
    
    func chooseFourthFrame(){
        presentImagePickerController(index: 4)
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
    
    func editImageDesc(index: Int) {
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
                if (self?.imageDescription.count)! >= index {
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
    
    func presentImagePickerController(index: Int) {
        imageClickIndex = index
        print("Clicked the image view")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
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
            imageViews[0].image = selectedImage
            break
        case 2:
            imageViews[1].image = selectedImage
            break
        case 3:
            imageViews[2].image = selectedImage
            break
        case 4:
            imageViews[3].image = selectedImage
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
    
    func updateImagesDictionary(count: Int, temporaryImagesDictionary: [String : Any]) {
        ref.child("Images").child(postID).child(imageIDS[count]).setValue(temporaryImagesDictionary)
        ref.child("Images").child(postID).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount.hashValue == self.imageIDS.count {
                self.ref.child("Posts").child(self.postID).setValue(self.postsDictionary)
            }
            print(snapshot.childrenCount)
            print(snapshot.children.allObjects.count)
            print(snapshot.childrenCount.hashValue)
        })
    }
    
    func populateArray(count: Int) {
        for i in 0..<count {
            imageIDS.append(ref.childByAutoId().key)
        }
    }
    
    func postAction() {
        print("Post Action")
        postID = ref.childByAutoId().key
        
        var uid = Auth.auth().currentUser?.uid
        
        var status: Bool!
        
        if statusSegment.selectedSegmentIndex == 0 {
            status = false
        } else {
            status = true
        }
        
        if typeOfFrame == "TWO_VERTICAL" || typeOfFrame == "TWO_HORIZONTAL" {
            populateArray(count: 2)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"post_description":postDescription.text,"frame_type":typeOfFrame,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        } else if typeOfFrame == "FOUR_CROSS" {
            populateArray(count: 4)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"frame_three": imageIDS[2],"frame_four":imageIDS[3],"post_description":postDescription.text,"frame_type":typeOfFrame ,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        } else if typeOfFrame == "THREE_VERTICAL" || typeOfFrame == "THREE_HORIZONTAL" {
            populateArray(count: 3)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"frame_three": imageIDS[2],"post_description":postDescription.text,"frame_type":typeOfFrame ,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        }
        
        uploadImage(datas: imageData)
    }
    func uploadImage(datas: [Data]) {
        
        var stopper = 0
        
        if typeOfFrame == "TWO_VERTICAL" || typeOfFrame == "TWO_HORIZONTAL" {
            stopper = 1
        } else if typeOfFrame == "THREE_VERTICAL" || typeOfFrame == "THREE_HORIZONTAL" {
            stopper = 2
        } else if typeOfFrame == "FOUR_CROSS" {
            stopper = 3
        }
        
        for i in 0...stopper {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
