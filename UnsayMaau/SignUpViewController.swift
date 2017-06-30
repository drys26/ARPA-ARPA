//
//  SignUpViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 30/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var whatsBestLogo: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    var imageDataTemp: Data!
    
    var email: String!
    
    var pass: String!
    
    var userId: String!
    
    var imageUrl: String!
    
    var databaseRef: DatabaseReference!
    
    var userDictionary = [String: Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            }
        }
        
        
        setupDesign()
        
        picker.delegate = self
    }
    
    
    @IBAction func pickImageButton(_ sender: Any) {
        
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary
//        self.present(picker, animated: true, completion: nil)
        
        presentImagePickerController()

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage , let imageData = UIImageJPEGRepresentation(selectedImage, 0.2) else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profileImage.image = selectedImage
        imageDataTemp = imageData
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerController(){
        print("Clicked the image view")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //if request.auth != null
    // "auth != null"
    func uploadImagePartTwo(data: Data){
        let storageRef = Storage.storage().reference(withPath: "Profile_Images/\(databaseRef.childByAutoId().key).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "images/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetaData, completion: { (metadata,error) in
            if(error != nil){
                print("I received an error! \(error?.localizedDescription ?? "null")")
            } else {
                let downloadUrl = metadata!.downloadURL()
                self.imageUrl = downloadUrl?.absoluteString
                print("Upload complete! Heres some metadata!! \(String(describing: metadata))")
                print("Here's your download url \(downloadUrl!)")
                self.updateUserDictionary()
                //self.navigationController?.popViewController(animated: true)
                //self.performSegue(withIdentifier: "unwindSegueAddTopic", sender: nil)
                //self.updateTopicDictionary(topicDictionary: &self.topicDictionary)
                //                let userImagesDictionary = ["user_image_url" : "\(downloadUrl!)","about_me_display": aboutDisplay , "gender": userGender , "phone" : phone , "username" : username , "location": location]
                //                self.updateProfile(userDictionary: userImagesDictionary as! [String : String], uid: uid)
            }
        })
    }
    
    func updateUserDictionary(){
        userDictionary["photo_url"] = imageUrl
        userDictionary["cover_photo_url"] = imageUrl
        databaseRef.child("Users").child(userId!).setValue(userDictionary)
        
        Auth.auth().signIn(withEmail: email!, password: pass! , completion: {(user,error) in
            if error == nil {
                print("Login Success")
            }
        })
    }
    
    
    func setupDesign(){
        
        whatsBestLogo.tintColor = UIColor(red: 0/255, green: 191/255, blue: 156/255, alpha: 1)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        
        nameTextField.layer.cornerRadius = nameTextField.frame.size.height / 2
        nameTextField.layer.borderWidth = 2
        nameTextField.layer.borderColor = UIColor.white.cgColor
        nameTextField.leftViewMode = .always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "icons8-user")
        imageView.image = image
        paddingView.addSubview(imageView)
        nameTextField.leftView = paddingView
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Fullname", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        emailTextField.layer.cornerRadius = emailTextField.frame.size.height / 2
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.leftViewMode = .always
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView2 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image2 = UIImage(named: "icons8-message_filled")
        imageView2.image = image2
        paddingView2.addSubview(imageView2)
        emailTextField.leftView = paddingView2
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        passwordTextField.layer.cornerRadius = passwordTextField.frame.size.height / 2
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.leftViewMode = .always
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView3 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image3 = UIImage(named: "icons8-lock_filled")
        imageView3.image = image3
        paddingView3.addSubview(imageView3)
        passwordTextField.leftView = paddingView3
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        confirmTextField.layer.cornerRadius = confirmTextField.frame.size.height / 2
        confirmTextField.layer.borderWidth = 2
        confirmTextField.layer.borderColor = UIColor.white.cgColor
        confirmTextField.leftViewMode = .always
        let paddingView4 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView4 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image4 = UIImage(named: "icons8-lock_filled")
        imageView4.image = image4
        paddingView4.addSubview(imageView4)
        confirmTextField.leftView = paddingView4
        confirmTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height / 2
        
    
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func toogleSignUp(_ sender: Any) {
        
//        if nameTextField.text == "" {
//            nameTextField.rightViewMode = .always
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//            let image = UIImage(named: "icons8-cancel")
//            imageView.image = image
//            nameTextField.rightView = imageView
//        }
//        else if emailTextField.text == "" {
//            emailTextField.rightViewMode = .always
//        }
//        else if passwordTextField.text == "" {
//            passwordTextField.rightViewMode = .always
//        }
//        else if confirmTextField.text == "" {
//            confirmTextField.rightViewMode = .always
//        }

        let name = nameTextField.text
        email = emailTextField.text
        pass = passwordTextField.text
        
       
        
        
        
        userDictionary["display_name"] = name!
        userDictionary["email_address"] = email!
        
        Auth.auth().createUser(withEmail: email!, password: pass!, completion: {(user, error) in
            
            if error == nil {
                print("Success")
                
                self.userId = user?.uid
                
                
            }
        })
        
        uploadImagePartTwo(data: imageDataTemp)
        
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
