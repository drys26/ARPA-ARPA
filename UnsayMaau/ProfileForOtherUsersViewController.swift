//
//  ProfileForOtherUsersViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 10/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class ProfileForOtherUsersViewController: UIViewController {
    
    var user: User!
    
    @IBOutlet weak var profileDisplayName: UILabel!
    @IBOutlet weak var coverPhotoImageView: UIImageView!

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    func loadUserData(){
    
        
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
