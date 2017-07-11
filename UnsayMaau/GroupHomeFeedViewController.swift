//
//  GroupHomeFeedViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 11/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Floaty

class GroupHomeFeedViewController: UIViewController {
    
    
    @IBOutlet weak var floats: Floaty!
    
    var group: Group!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.bringSubview(toFront: floats)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.addGroupPost))
        
        floats.addGestureRecognizer(tap)
        
        print(group.groupName)
        
        // Do any additional setup after loading the view.
    }
    
    func addGroupPost(){
        let selectFrameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostVC") as! SelectFrameViewController
        
        selectFrameVC.isGroup = true
        
        selectFrameVC.group = self.group
        
        navigationController?.pushViewController(selectFrameVC, animated: true)
        //present(profileVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
