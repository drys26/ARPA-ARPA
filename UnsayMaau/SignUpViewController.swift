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

    var ref: DatabaseReference!
    let picker = UIImagePickerController()
    var imageData: Data?
    var URL: String?
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var whatsBestLogo: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
        
        picker.delegate = self
    }
    
    
    @IBAction func uploadPhoto(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            }
            else{
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(data: Data){
        
        let uID = Auth.auth().currentUser?.uid
        
        let storageRef = Storage.storage().reference(withPath: "users/\(uID!).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetaData) { (metadata, error) in
            if error != nil {
                print("\(error?.localizedDescription ?? "")")
            }
            else{
                print("Successfully complete! \(metadata?.downloadURL()?.absoluteString ?? "")")
                self.URL = metadata?.downloadURL()?.absoluteString
                self.ref = Database.database().reference()
                let userDictionary = ["display_name": self.nameTextField.text! , "email_address": self.emailTextField.text! , "cover_photo_url": self.URL! , "photo_url": self.URL!] as [String: Any]
                
                self.ref.child("Users").child("\(Auth.auth().currentUser?.uid ?? "no user")").setValue(userDictionary)
                
                self.performSegue(withIdentifier: "goToMain", sender: nil)
                
            }
        }
        uploadTask.observe(StorageTaskStatus.progress) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            strongSelf.progressView.isHidden = false
            strongSelf.progressView.progress = Float(progress.fractionCompleted)
            strongSelf.progressView.isHidden = true
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageInfo = UIImageJPEGRepresentation(image, 0.8){
            imageData = imageInfo
            profileImage.image = image
            
        }
        picker.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
        
        if profileImage.image != UIImage(named: "icons8-user_male_circle_filled-1"){
        
            if nameTextField.text == "" {
                print("no name")
                nameTextField.rightViewMode = .always
            }
            else if emailTextField.text == "" {
                print("no email")
            }
            else if passwordTextField.text == ""{
                print("no password")
            }
            else if passwordTextField.text != confirmTextField.text {
                print("confirmed password not match")
            }
            else{
                Auth.auth().createUser(withEmail: "\(emailTextField.text!)", password: "\(passwordTextField.text!)", completion: { (user, error) in
                    if error == nil {
                        
                        print("successfully created account")
                        
                        Auth.auth().signIn(withEmail: "\(self.emailTextField.text!)", password: "\(self.passwordTextField.text!)", completion: { (user1, err) in
                            
                            self.uploadImageToFirebaseStorage(data: self.imageData!)
                            

                            
                        })
                        
                        
                    }
                    else{
                        let alert = UIAlertController(title: "Error", message: "\(error?.localizedDescription ?? "")", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                })
            }
            
        
        }
        else{
            print("no image selected")
        }
        
        
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    

}
