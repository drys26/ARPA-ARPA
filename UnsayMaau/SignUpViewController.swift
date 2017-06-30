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
        
        emailTextField.layer.cornerRadius = emailTextField.frame.size.height / 2
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.leftViewMode = .always
        
        passwordTextField.layer.cornerRadius = passwordTextField.frame.size.height / 2
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.leftViewMode = .always
        
        confirmTextField.layer.cornerRadius = confirmTextField.frame.size.height / 2
        confirmTextField.layer.borderWidth = 2
        confirmTextField.layer.borderColor = UIColor.white.cgColor
        confirmTextField.leftViewMode = .always
        
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height / 2
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
