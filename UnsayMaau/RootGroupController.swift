//
//  RootGroupController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import PageMenu
import Firebase

class RootGroupController: UIViewController {

    var group: Group!
    
    var uid = Auth.auth().currentUser?.uid
    
    var pageMenu: CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "See Members", style: .plain, target: self, action: #selector(self.goToSeeMembers))

        var controllerArray: [UIViewController] = []
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "GroupFeed")
        firstVC?.title = "FEED"
        
        
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "GroupChat") as! UINavigationController
        
        secondVC.title = "CHAT"
        
        let rootView = secondVC.viewControllers.first as! ChatViewController
        
        rootView.group = group
//
        
//        let containerChatView = rootView.view.viewWithTag(5) as! UIView
        
        
        
        
        
//        containerChatView.senderId = "\(uid)"
//        containerChatView.senderDisplayName = "Sample"
        
        
        
//        rootView.senderId = "\(uid)"
//        rootView.senderDisplayName = "Sample"
        
        
        controllerArray.append(firstVC!)
        controllerArray.append(secondVC)
        
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
        
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: (self.navigationController?.navigationBar.frame.maxY)!, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        let extra: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        self.view.addSubview(extra)
            
        
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    
    
    
    
    
    
    func goToSeeMembers(){
        performSegue(withIdentifier: "goToSeeMembers", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSeeMembers" {
            let smvc = segue.destination as! SeeMembersViewController
            smvc.group = group
        }
    }
    

}
