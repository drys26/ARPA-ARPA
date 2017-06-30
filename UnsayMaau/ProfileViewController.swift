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
    
    var pageMenu: CAPSPageMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        var controllerArray: [UIViewController] = []
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "ProfileLiveController")
        firstVC?.title = "Live"
        
        
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "ProfileFinishedController")
        secondVC?.title = "Finished"
        
        let thirdVC = storyboard?.instantiateViewController(withIdentifier: "ProfileInteractionController")
        thirdVC?.title = "Interaction"
        
        controllerArray.append(firstVC!)
        controllerArray.append(secondVC!)
        controllerArray.append(thirdVC!)
        
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
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(false),
            //            .selectionIndicatorHeight(2.0)
            .menuItemSeparatorPercentageHeight(0)
            
        ]
        
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: StackViewCounter.frame.maxY , width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        
        self.view.addSubview(pageMenu!.view)
        
        self.view.bringSubview(toFront: floats)
        
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width / 2
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }

}
