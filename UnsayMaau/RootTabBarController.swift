//
//  RootTabBarController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 10/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class RootTabBarController: UITabBarController {
    

    var user: User!
    
    var ref: DatabaseReference!
    
    var uid = Auth.auth().currentUser?.uid
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ref == nil {
            ref = Database.database().reference()
            getUserData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Remove the badge
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 4:
            item.badgeValue = nil
            ref.child("Notifications").child(user.userId).child("Pending_Groups_Notifications").removeValue()
            break
        case 2:
            item.badgeValue = nil
            break
        default:
            break
        }
 
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
