//
//  AcceptGroupViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 05/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class AcceptGroupViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    
    @IBOutlet weak var acceptGroupTable: UITableView!
    
    var pendingGroups = [PendingGroup]()
    
    var rootRef: DatabaseReference!
    
    var uid = Auth.auth().currentUser?.uid
    
    func loadPendingGroups(){
        let pendingGroupRef = rootRef.child("Users_Groups").child(uid!).child("Pending_Groups")
        
        pendingGroupRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let pendingGroup = PendingGroup(snap: child)
                self.pendingGroups.append(pendingGroup)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "acceptGroupCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AcceptGroupTableViewCell else {
            fatalError("The dequeued cell is not an instance of acceptGroupCell.")
        }
        
        let pendingGroup = pendingGroups[indexPath.row]
        
        let description = NSMutableAttributedString()
        
        
        rootRef.child("Users").child(pendingGroup.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let valueDict = snapshot.value as! [String: Any]
            let userImageUrl = valueDict["photo_url"] as! String
            let userDisplayName = valueDict["display_name"] as! String
            
            let attrib = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)]
            let attribText = NSMutableAttributedString(string: userDisplayName, attributes: attrib)
            
            cell.userInvitedImageView.sd_setImage(with: URL(string: userImageUrl))
            description.append(attribText)
            
            self.rootRef.child("Groups").child(pendingGroup.groupId).observeSingleEvent(of: .value, with: { (snapshot) in
                let groupDict = snapshot.value as! [String: Any]
                
                let groupName = groupDict["group_name"] as! String
                
                let hasInvitedString = NSAttributedString(string: " has invited you to join", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])

                let attribText1 = NSMutableAttributedString(string: " \(groupName)", attributes: attrib)
                
                description.append(hasInvitedString)
                description.append(attribText1)
                
                cell.descriptionTextView.attributedText = description
            })
            
            
        })
        
//        let accept = UIButton(type: .custom)
//        
//        button.tag = indexPath.row
//        
//        button.setImage(UIImage(named: "invite_members"), for: .normal)
//        
//        button.addTarget(self, action: #selector(self.inviteAction(sender:)), for: .touchUpInside)
//        
//        cell.buttonStackView.addArrangedSubview(button)
        
        var buttons = [UIButton]()
        
        for i in 0..<2 {
            buttons.append(UIButton(type: .custom))
            buttons[i].tag = indexPath.row
            if i == 0 {
                buttons[i].setImage(UIImage(named:"invite_members"), for: .normal)
                buttons[i].accessibilityLabel = "accept"
            } else {
                buttons[i].setImage(UIImage(named:"decline_members"), for: .normal)
                buttons[i].accessibilityLabel = "decline"
            }
            
            buttons[i].addTarget(self, action: #selector(self.inviteAction(sender:)), for: .touchUpInside)
            
        }
        
        return cell
        
    }
    
    func inviteAction(sender: UIButton) {
        
        
        let access = sender.accessibilityLabel!
        
        if access == "accept" {
            print("accept")
        } else {
            print("decline")
        }
        
//        let user = users[sender.tag]
//        let uid = Auth.auth().currentUser?.uid
//        group.groupRef.child("invited_pending_members").updateChildValues(["\(user.userId)": true])
//        rootRef.child("Users_Groups").child(user.userId).child("Pending_Groups").updateChildValues([group.groupId:uid!])
//        users.remove(at: sender.tag)
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        self.reload()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingGroups.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if rootRef == nil {
            rootRef = Database.database().reference()
            loadPendingGroups()
        }
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
