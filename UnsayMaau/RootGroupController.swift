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
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(false),
            .menuItemSeparatorPercentageHeight(0)
            
        ]
        
        
        
        let extra: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        self.view.addSubview(extra)
        let navheight = (navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height
        let frame = CGRect(x: 0, y: navheight, width: view.frame.width, height: view.frame.height)
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: frame, pageMenuOptions: parameters)

        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        let navheight = (navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height
//        let frame = CGRect(x: 0, y: navheight, width: view.frame.width, height: view.frame.height - navheight)
//        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: frame, pageMenuOptions: parameters)
//    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
<<<<<<< HEAD
    
    
    
    
    
    
    
=======

>>>>>>> 56c0b196debfa2528e05b7f56cb97feaab8c7703
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
