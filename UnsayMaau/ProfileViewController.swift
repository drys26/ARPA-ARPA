//
//  ProfileViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import PageMenu
import Floaty
import GoogleSignIn
import Firebase

class ProfileViewController: UIViewController , CAPSPageMenuDelegate {
    
    
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var groupHeader: UILabel!
    @IBOutlet weak var followingHeader: UILabel!
    @IBOutlet weak var followersHeader: UILabel!
    @IBOutlet weak var postHeader: UILabel!
    
    
    @IBOutlet weak var postStackView: UIStackView!
    @IBOutlet weak var followersStackView: UIStackView!

    @IBOutlet weak var followingStackView: UIStackView!
    
    @IBOutlet weak var groupStackView: UIStackView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var floats: Floaty!
    @IBOutlet weak var StackViewCounter: UIStackView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var goToFollowButton: UIButton!
    
    @IBOutlet weak var settingsBtn: UIButton!
    
    
    var isCurrentUser: Bool = true
    
    var pageMenu: CAPSPageMenu?
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var ref: DatabaseReference!
    
    @IBAction func goToFollowers(_ sender: Any) {
        
        performSegue(withIdentifier: "goToFollowFinder", sender: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ref == nil {
            ref = Database.database().reference()
        }
        
        navigationController?.title = "Profile"
        
        if isCurrentUser == true {
            //navigationController?.setNavigationBarHidden(true, animated: animated)
            backButton.isHidden = true
            settingsBtn.isHidden = false
        } else {
            logoutButton.isHidden = true
            backButton.isHidden = false
            settingsBtn.isHidden = true
        }
        getUserData()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    func getUserData(){
        var id = ""
        if isCurrentUser == false {
            id = user.userId
        } else {
            id = uid!
        }
        ref.child("Users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            self.ref.child("Users_Posts").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                self.postLabel.text = "\(snapshot.childrenCount.hashValue)"
            })
            self.ref.child("Users_Groups").child(id).child("Member_Groups").observeSingleEvent(of: .value, with: { (snapshot) in
                self.groupLabel.text = "\(snapshot.childrenCount.hashValue)"
            })
            self.coverImage.sd_setImage(with: URL(string: self.user.coverPhotoUrl))
            self.followersLabel.text = "\(self.user.followersIDs.count)"
            self.followingLabel.text = "\(self.user.followingIDs.count)"
            self.profileImage.sd_setImage(with: URL(string: self.user.photoUrl))
            self.userDisplayName.text = self.user.displayName
            
        })
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print(index)
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print(index)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var controllerArray: [UIViewController] = []
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "ProfileLiveController")
        firstVC?.title = "Live"
        
        
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "ProfileFinishedController")
        secondVC?.title = "Finished"
        
        let thirdVC = storyboard?.instantiateViewController(withIdentifier: "ProfileInteractionController")
        thirdVC?.title = "Interaction"
        
        let fourthVC = storyboard?.instantiateViewController(withIdentifier: "NotificationsController")
        fourthVC?.title = "Notifications"
        
        controllerArray.append(firstVC!)
        controllerArray.append(secondVC!)
        controllerArray.append(thirdVC!)
        controllerArray.append(fourthVC!)
        
        // a bunch of random customization
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(UIColor.black),
            .bottomMenuHairlineColor(UIColor.clear),
            .menuHeight(40.0),
            .menuItemWidth(100.0),
            .centerMenuItems(true),
            .selectedMenuItemLabelColor(UIColor.black),
            .enableHorizontalBounce(false),
            //            .menuItemSeparatorWidth(1.0),
            //            .menuMargin(20.0),
            //            .menuHeight(40.0),
            //            .selectionIndicatorHeight(2.0)
            .menuItemSeparatorPercentageHeight(0)
            
        ]
        
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: StackViewCounter.frame.maxY , width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        pageMenu?.delegate = self
        
        self.view.addSubview(pageMenu!.view)
        
        self.view.bringSubview(toFront: floats)
        
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width / 2
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        if isCurrentUser == false {
            let tapBack = UITapGestureRecognizer(target: self, action: #selector(self.dismissPVC))
            backButton.addGestureRecognizer(tapBack)
        }
        
        
        
 
    }
    
    func dismissPVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
//    func goToFollowers(sender: UITapGestureRecognizer){
//        print("Tap")
//        if let label = sender.view as? UILabel {
//            
//        }
//        
//        self.performSegue(withIdentifier: "goToFollowFinder", sender: "followers")
//        
//    }
    

    @IBAction func toogleSettings(_ sender: Any) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance().signOut()
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            let svc = segue.destination as! SettingsViewController
            svc.profileImage = self.profileImage.image
        } else if segue.identifier == "goToFollowFinder" {
            let sfvc = segue.destination as! SeeFollowsViewController
            sfvc.user = user
            sfvc.followType = "followers"
            //sender as! String
        }
    }
    
}
