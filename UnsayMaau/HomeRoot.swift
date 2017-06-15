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

class HomeRoot: UIViewController {

    
    var pageMenu: CAPSPageMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let floaty = Floaty(frame: CGRect(x: view.frame.size.width / 2, y: view.frame.size.height, width: 50, height: 50))
        floaty.backgroundColor = UIColor.cyan
        self.view.addSubview(floaty)
        

        var controllerArray: [UIViewController] = []
        
        let postVC = storyboard?.instantiateViewController(withIdentifier: "HomePostViewController")
        postVC?.title = "Posts"
        
        let actVC = storyboard?.instantiateViewController(withIdentifier: "HomeActViewController")
        actVC?.title = "Activity"
        
        controllerArray.append(postVC!)
        controllerArray.append(actVC!)
        
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor.black),
            .selectionIndicatorColor(UIColor.black),
            .bottomMenuHairlineColor(UIColor.clear),
            .menuHeight(40.0),
            .menuItemWidth(100.0),
            .centerMenuItems(true),
            .selectedMenuItemLabelColor(UIColor.black),
            .enableHorizontalBounce(false)
            
            
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: (navigationController?.navigationBar.frame.size.height)! + 20, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        
        self.view.addSubview(pageMenu!.view)
        
        view.bringSubview(toFront: floaty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
