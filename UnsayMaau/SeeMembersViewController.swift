//
//  SeeMembersViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class SeeMembersViewController: UIViewController {
    
    @IBOutlet weak var seeMembersTableView: UITableView!
    
    var users: [[User]] = []
    
    var mainUser: User!
    
    var group: Group!
    
    var rootRef: DatabaseReference!
    
    var uid = Auth.auth().currentUser?.uid
    
    var sections = ["Pending"]
    //["Pending","Active","Inactive","Admin"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootRef = Database.database().reference()
        
        // Load Pending members
        
        seeMembersTableView.delegate = self
        seeMembersTableView.dataSource = self
        
        getUserData()
        
        loadGroupMembers()
    }
    
    func getUserData(){
        rootRef.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.mainUser = User(snap: snapshot)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadGroupMembers(){
        
        rootRef.child("Groups").child(group.groupId).child("pending_members").observeSingleEvent(of: .value, with: {(rootSnapshot) in
            let value = rootSnapshot.value as! [String: Any]
            for (key , element) in value {
                self.rootRef.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user = User(snap: snapshot)
                    self.users.append([User]())
                    self.users[0].append(user)
                    DispatchQueue.main.async {
                        self.seeMembersTableView.reloadData()
                    }
                })
            }
        })
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

extension SeeMembersViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users[section].count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count {
            return sections[section]
        }
        return nil
    }
    
    
}

extension SeeMembersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "seeMembersCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SeeMembersTableViewCell else {
            fatalError("The dequeued cell is not an instance of seeMembersCell.")
        }
        print("\(indexPath.section)  \(indexPath.row)")
        let user = users[indexPath.section][indexPath.row]
        
        cell.memberDisplayName.text = user.displayName
        
        cell.memberImageView.sd_setImage(with: URL(string: user.photoUrl))
        
        cell.memberImageView.layer.cornerRadius = cell.memberImageView.frame.size.width / 2
        
        cell.memberCommandButton.layer.cornerRadius = cell.memberCommandButton.frame.height / 2
        
        cell.memberCommandButton.accessibilityLabel = "\(indexPath.section) \(indexPath.row)"
        
        cell.memberCommandButton.addTarget(self, action: #selector(self.commandAction(sender:)), for: .touchUpInside)
        
        var isInPending = group.pendingMembers.contains(user)
        
        // TODO: if the user is admin
        
        if group.admins.contains(mainUser) {
            
            // if the user is in pending members of the group
            
            if isInPending {
                // User is Pending
                
                cell.memberCommandButton.setTitle("Accept", for: .normal)
            } else {
                // TODO: Show User if active or not
                
            }
        } else {
            if isInPending {
                // User is Pending
                cell.memberCommandButton.setTitle("Pending", for: .normal)
            } else {
                // TODO: Show User if active or not
                
            }
        }
        
        return cell
        
    }
    
    
    func commandAction(sender: UIButton){
        let arr = sender.accessibilityLabel?.components(separatedBy: " ")
        let section = Int((arr?[0])!)
        let row = Int((arr?[1])!)
        
        let user = users[section!][row!]
        
        if section == 0 {
            rootRef.child("Groups").child(group.groupId).child("pending_members").child(user.userId).removeValue()
            rootRef.child("Groups").child(group.groupId).child("members").updateChildValues(["\(user.userId)": ["isActive":false,"isJoined":true]])
        }
        
//
        
    }

}
