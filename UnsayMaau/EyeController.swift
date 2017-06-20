//
//  EyeController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import PageMenu
import SWRevealViewController
import Floaty

class EyeController: UIViewController {

    @IBOutlet weak var floats: Floaty!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pageMenu: CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.layer.borderWidth = 0
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        var controllerArray: [UIViewController] = []
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "TopViewController")
        firstVC?.title = "TOP"
        
        
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "RecentViewController")
        secondVC?.title = "RECENT"
        
        
        
        
        controllerArray.append(firstVC!)
        controllerArray.append(secondVC!)
        
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
        
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 20 + 40 + 48, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        
        self.view.addSubview(pageMenu!.view)
        
        self.view.bringSubview(toFront: floats)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
