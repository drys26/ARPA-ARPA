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

    @IBOutlet weak var float: Floaty!
    
    var pageMenu: CAPSPageMenu?
    
    @IBAction func goToSelectFrameAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goToSelectFrame", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        float.buttonColor = UIColor.cyan

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
        
        view.bringSubview(toFront: float)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
