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
import SkyFloatingLabelTextField
import FontAwesome

class LoginViewController: UIViewController , GIDSignInDelegate , GIDSignInUIDelegate {


    @IBOutlet weak var emailAddress: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passWord: SkyFloatingLabelTextFieldWithIcon!
    
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        emailAddress.iconFont = UIFont(name: "FontAwesome", size: 20)
        emailAddress.iconText = "\u{f003}"
        
        passWord.iconFont = UIFont(name: "FontAwesome", size: 20)
        passWord.iconText = "\u{f023}"
        
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

