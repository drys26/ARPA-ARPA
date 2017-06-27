//
//  GroupController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 20/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Floaty
import SDWebImage
import Firebase


class GroupController: UIViewController {


    @IBOutlet weak var floats: Floaty!
    
    var groups = [Group]()
    
    var rootRef: DatabaseReference!
    
    var refGroups: DatabaseReference!
    
    var refGroupsHandle: DatabaseHandle!
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubview(toFront: floats)
        
    }
    
    func getUserData(){
        rootRef.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
        })
    }
    
    func loadGroups(){
        refGroupsHandle = refGroups.observe(.childAdded, with: {(snapshot) in
            let group = Group(snap: snapshot)
            if !self.groups.contains(group) {
                if group.groupStatus == false {
                    self.groups.append(group)
                    DispatchQueue.main.async {
                        self.groupTableView.reloadData()
                    }
                    
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTableView.delegate = self
        groupTableView.dataSource = self
        rootRef = Database.database().reference()
        refGroups = rootRef.child("Groups")
        loadGroups()
        getUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refGroups.removeObserver(withHandle: refGroupsHandle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addGroupAction(_ sender: Any) {
        performSegue(withIdentifier: "goToAddGroup", sender: nil)
    }
    
    func clickCell(sender: UITapGestureRecognizer){
        if let rootView = sender.view as? UIView {
            let group = groups[rootView.tag]
            if !group.admins.contains(user){
                let pendingDictionary = ["pending_members": ["\(uid!)": true]]
                refGroups.child(group.groupId).updateChildValues(pendingDictionary)
                showAlertController(message: "Please wait for response", title: "Request Send")
            } else {
                // TODO: Enter group view controller
                // and display data
                performSegue(withIdentifier: "goToGroupPage", sender: group)
            }
        }
    }
    
    
    func showAlertController(message: String , title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGroupPage" {
            if let group = sender as? Group {
                let root = segue.destination as! RootGroupController
                root.group = group
            }
        }
    }
    
}



extension GroupController: UITableViewDelegate {
    
}

extension GroupController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "groupCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        
        let group = groups[indexPath.row]
        
        cell.rootView.tag = indexPath.row
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickCell(sender:)))
        
        cell.rootView.addGestureRecognizer(tap)
        
        cell.backgroundImageView.sd_setImage(with: URL(string: group.backgroundImageUrl))
        cell.groupDescriptionText.text = group.groupDescription
        cell.groupMembersText.text = "\(group.members.count)"
        cell.groupNameText.text = group.groupName
        
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return groups.count
    }
}
