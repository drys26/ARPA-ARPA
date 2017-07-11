//
//  HomeRoot.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import PageMenu
import Floaty
import Firebase

class HomeRoot: UIViewController {

    @IBOutlet weak var float: Floaty!
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var ref: DatabaseReference!
    
    var pageMenu: CAPSPageMenu?
    
    @IBAction func goToSelectFrameAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goToSelectFrame", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectFrame" {
            let sfcv = segue.destination as! SelectFrameViewController
            sfcv.isGroup = false
        }
    }
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            self.observeNotifications()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ref == nil {
            ref = Database.database().reference()
            getUserData()
        }
    }
    
    func observeNotifications(){
        ref.child("Users_Groups").child(self.user.userId).child("Pending_Groups_Notifications").observe(.value, with: { (snapshot) in
            
            var count = snapshot.childrenCount.hashValue
            
            if count == 0 {
                self.navigationController?.tabBarController?.tabBar.items?[4].badgeValue = nil
            } else {
                self.navigationController?.tabBarController?.tabBar.items?[4].badgeValue = "\(count)"
            }
            
            
        })
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToSelectFrame" {
//            let simvc = segue.destination as! SelectImageFromLibraryViewController
//            simvc.passArrayDelegate = self as! PassPostDelegate
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "WhatsBest"))
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        var controllerArray: [UIViewController] = []
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "HomePostViewController")
        postVC?.title = "Posts"
        
        let actVC = storyboard?.instantiateViewController(withIdentifier: "HomeActViewController")
        actVC?.title = "Activity"
        
        controllerArray.append(postVC!)
        controllerArray.append(actVC!)
        
        
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
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: (navigationController?.navigationBar.frame.size.height)! + 20, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        
        self.view.addSubview(pageMenu!.view)
        
        view.bringSubview(toFront: float)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
