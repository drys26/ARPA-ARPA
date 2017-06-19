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
    
    
    var imageData: [Data] = []
    var imageDescription: [String] = []
    var imageViews: [UIImageView] = []
    var imageIDS: [String] = []
    var frames: [Int] = []
    var ref: DatabaseReference = Database.database().reference()
    var postID: String = ""
    var imageClickIndex: Int = 0
    
    var typeOfFrame: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch typeOfFrame {
        case "TWO_VERTICAL":
            print("two_vertical")
            twoVerticalFrames()
            break
        case "FOUR_CROSS":
            print("four_cross")
            break
        default:
            print("nothing")
            break
        }
    }
    
    func twoVerticalFrames(){
        // Root Stack View Axis == .horizontal
        
        rootStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "number_1"))
        let secondImageView = UIImageView(image: UIImage(named: "number_2"))
        
        // Set the properties to clip to bounds
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
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
    
    func chooseFirstFrame(){
        presentImagePickerController(index: 1)
    }
    
    func chooseSecondFrame(){
        presentImagePickerController(index: 2)
    }
    
    func editFirstFrame(){
        
    }
    func editSecondFrame(){
        
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
//        if self.imageData.count > imageClickIndex {
//            self.imageData.remove(at: imageClickIndex - 1)
//            self.imageData.insert(imageData, at: imageClickIndex - 1)
//        } else {
//            self.imageData.insert(imageData, at: imageClickIndex - 1)
//        }
        
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
        
    }
    func postAction() {
        
    }
    func uploadImage(datas: [Data]) {
        
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
