//
//  LoginViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController , GIDSignInDelegate , GIDSignInUIDelegate {



    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var whatsBestLogo: UIImageView!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        
//        try! Auth.auth().signOut()
//        GIDSignIn.sharedInstance().signOut()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            }
        }
        
        
        
        databaseRef = Database.database().reference()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        whatsBestLogo.tintColor  = UIColor.white
       
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        performSegue(withIdentifier: "goToRegister", sender: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        UIView.animate(withDuration: 1, animations: {
            self.heightConstraint.constant = 75
            self.view.layoutIfNeeded()
        }) { (true) in
            UIView.animate(withDuration: 0.5, animations: {
                self.googleButton.alpha = 1
            }, completion: { (true) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.facebookButton.alpha = 1
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.createAccountButton.alpha = 1
                    }, completion: nil)
                })
            })
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setupButton(){
        googleButton.alpha = 0
        facebookButton.alpha = 0
        createAccountButton.alpha = 0
        googleButton.layer.cornerRadius = googleButton.frame.size.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.size.height / 2
        createAccountButton.layer.cornerRadius = createAccountButton.frame.size.height / 2
        createAccountButton.layer.borderColor = UIColor.white.cgColor
        createAccountButton.layer.borderWidth = 2
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("User Sign in to Google")
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user1, error) in
            print("User Sign in to Firebase")
            self.databaseRef.child("Users").child((user1?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                if snapshot == nil {
                    let userDictionary = ["display_name": (user1?.displayName)! ,"email_address" : (user1?.email)! , "photo_url" : (user1?.photoURL?.absoluteString)!, "cover_photo_url": (user1?.photoURL?.absoluteString)!] as [String : Any]
                    self.databaseRef.child("Users").child((user1?.uid)!).setValue(userDictionary)
                    
                }
                self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            })
        }
    }
    
    @IBAction func googleSignInAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
}

