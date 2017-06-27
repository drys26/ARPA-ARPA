//
//  GroupController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Floaty

class GroupController: UIViewController{

    @IBOutlet weak var floats: Floaty!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
    self.view.bringSubview(toFront: floats)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
