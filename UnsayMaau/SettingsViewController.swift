//
//  SettingsViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 05/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var sections = ["Profile","General"]
    
    var settings = [Settings]()
    
    var profileImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        userProfileImageView.image = profileImage
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.layer.frame.size.width / 2
        
        userProfileImageView.clipsToBounds = true
        
    }
    
    func loadSettings(){
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 && indexPath.row == 0 {
            // Profile Action
            print("edit profile")
        } else if indexPath.section == 1 && indexPath.row == 0 {
            // Privacy Action
            print("privacy")
        } else if indexPath.section == 1 && indexPath.row == 1 {
            // Security Action
            print("security")
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionHeaderHeight + 40
        } else {
            return tableView.sectionHeaderHeight + 50
        }
        return 0
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
