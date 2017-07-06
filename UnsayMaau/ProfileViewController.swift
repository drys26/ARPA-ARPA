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

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var floats: Floaty!
    @IBOutlet weak var StackViewCounter: UIStackView!
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    
    
    var pageMenu: CAPSPageMenu?
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var ref: DatabaseReference!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if ref == nil {
            ref = Database.database().reference()
            getUserData()
        }
    }
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
            self.ref.child("Users_Posts").child(self.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                self.postLabel.text = "\(snapshot.childrenCount.hashValue)"
            })
            self.ref.child("Users_Groups").child(self.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                self.groupLabel.text = "\(snapshot.childrenCount.hashValue)"
            })
            self.coverImage.sd_setImage(with: URL(string: self.user.coverPhotoUrl))
            self.followersLabel.text = "\(self.user.followersIDs.count)"
            self.followingLabel.text = "\(self.user.followingIDs.count)"
            self.profileImage.sd_setImage(with: URL(string: self.user.photoUrl))
            self.userDisplayName.text = self.user.displayName
        })
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
        
        
        self.view.addSubview(pageMenu!.view)
        
        self.view.bringSubview(toFront: floats)
        
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width / 2
        
        
        
    }
    

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
        }
    }
    

}
