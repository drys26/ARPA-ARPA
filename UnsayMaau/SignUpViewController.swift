//
//  SignUpViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 30/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

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
        
        
    }
    
    func setupDesign(){
        
        whatsBestLogo.tintColor = UIColor(red: 0/255, green: 191/255, blue: 156/255, alpha: 1)
        
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
    
    
    @IBAction func backToLogin(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
