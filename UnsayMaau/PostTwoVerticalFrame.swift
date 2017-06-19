//
//  PostTwoVerticalFrame.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class PostTwoVerticalFrame: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    var imageData = [Data]()
    
    var imageUrl = [String]()
    
    var imageDescription = [String]()
    
    var isFirstFrame: Bool = false
    
    var isSecondFrame: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func editFirstFrame(_ sender: Any) {
        print("It is a long press")
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
            imageData.insert(contentsOf: imageData, at: 0)
            print(imageData[0])
        } else {
            secondImageView.image = selectedImage
            imageData.insert(contentsOf: imageData, at: 1)
            print(imageData[1])
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
        let alertController = UIAlertController(title: "Email?", message: "Please input \(stringDescription)", preferredStyle: .alert)
//        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
//            if let field = alertController.textFields?[0] {
//                
//            }
//        }
//        let confirmAction = UIAlertAction(title: "Confirm", message:"Please input \(stringDescription)", preferredStyle: .alert) { (_) in
//            if let field = alertController.textFields![0] as? UITextField {
//                if isFirstFrame {
//                    self.imageDescription.insert(field.text!, at: 0)
//                    print(self.imageDescription[0])
//                } else {
//                    self.imageDescription.insert(field.text!, at: 1)
//                    print(self.imageDescription[1])
//                }
//            }
//        }
//        
//        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)

        //alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
