//
//  SearchGroupUsersViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 04/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class SearchGroupUsersViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UISearchBarDelegate {

    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var userTableView: UITableView!
    
    var users = [User]()
    
    var group: Group!
    
    var rootRef: DatabaseReference!
    
    var groupHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Search user"
        
        
//        navigationItem.titleView = userSearchBar
        // Do any additional setup after loading the view.
        userTableView.delegate = self
        userTableView.dataSource = self
        userSearchBar.delegate = self
        userSearchBar.placeholder = "Search User ..."
        
        rootRef = Database.database().reference()
        
        observeGroup()
    }
    
    func loadSearchUsers(){
        let searchText = userSearchBar.text!
        let uid = Auth.auth().currentUser?.uid
        let userRef = rootRef.child("Users").queryOrdered(byChild: "search_name").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased() + "\u{f8ff}")
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
        
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let user = User(snap: child)
                if !child.hasChild("account_status") && user.userId != uid && !self.group.invitedPendingMembers.contains(user) {
                    self.users.append(user)
                    self.reload()
                }
            }
        })
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.userTableView.reloadData()
        }
    }
    
    func observeGroup(){
        groupHandle = group.groupRef.observe(.value, with: {(snapshot) in
            self.group = Group(snap: snapshot)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        group.groupRef.removeObserver(withHandle: groupHandle)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // TODO: Show Search Users
        users.removeAll()
        loadSearchUsers()
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "searchUsersCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchUsersTableViewCell else {
            fatalError("The dequeued cell is not an instance of searchUsersCell.")
        }
        
        let user = users[indexPath.row]
        
        cell.userDisplayName.text = user.displayName
        cell.userImageView.sd_setImage(with: URL(string: user.photoUrl))
        
        let button = UIButton(type: .custom)
        
        button.tag = indexPath.row
        
        button.setImage(UIImage(named: "invite_members"), for: .normal)
        
        button.addTarget(self, action: #selector(self.inviteAction(sender:)), for: .touchUpInside)
        
        cell.buttonStackView.addArrangedSubview(button)
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func inviteAction(sender: UIButton) {
        let user = users[sender.tag]
        let uid = Auth.auth().currentUser?.uid
        group.groupRef.child("invited_pending_members").updateChildValues(["\(user.userId)": true])
        rootRef.child("Users_Groups").child(user.userId).child("Pending_Groups").updateChildValues([group.groupId:uid!])
        users.remove(at: sender.tag)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.reload()
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
