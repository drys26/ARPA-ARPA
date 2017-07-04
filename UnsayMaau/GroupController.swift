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


class GroupController: UIViewController,UISearchBarDelegate {
    
    
    @IBOutlet weak var floats: Floaty!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    
    
    var groups = [Group]()
    
    var searchGroups = [Group]()
    
    var isSearching: Bool!
    
    var rootRef: DatabaseReference!
    
    var refGroups: DatabaseReference!
    
    var refGroupsHandle: DatabaseHandle!
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "WhatsBest"))
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        
        isSearching = false
        
        searchBar.delegate = self
        
        
        refreshControl.addTarget(self, action: #selector(self.loadGroups), for: .valueChanged)
        
        
        self.view.bringSubview(toFront: floats)
        self.view.bringSubview(toFront: floats)
        
        
        if #available(iOS 10.0, *){
            groupTableView.refreshControl = refreshControl
        }
        else{
            groupTableView.addSubview(refreshControl)
        }
    }
    
    func refreshData(){
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
        refreshControl.endRefreshing()
        
    }
    
    func getUserData(){
        rootRef.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
        })
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.groupTableView.reloadData()
        }
        
    }
    
    func loadGroups(){
        if isSearching == true {
            searchGroups.removeAll()
            loadSearchedGroups()
        } else {
            refGroups.observeSingleEvent(of: .value, with: {(snapshot) in
                if let rootGroups = snapshot.children.allObjects as? [DataSnapshot] {
                    for rootGroup in rootGroups {
                        let group = Group(snap: rootGroup)
                        if !self.groups.contains(group) {
                            if group.groupStatus == false {
                                self.groups.append(group)
                                self.reload()
                            }
                        }
                        if self.groups.contains(group) && group.groupStatus == true {
                            if let index = self.groups.index(of: group) {
                                self.groups.remove(at: index)
                                DispatchQueue.main.async {
                                    self.groupTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            })
        }
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTableView.delegate = self
        groupTableView.dataSource = self
        rootRef = Database.database().reference()
        rootRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild("Groups") {
                self.refGroups = self.rootRef.child("Groups")
                self.loadGroups()
            }
        })
        getUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if refGroups != nil {
//            refGroups.removeObserver(withHandle: refGroupsHandle)
//        }
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
            
            //loadGroups()
            // Refresh Group
            
            var group1: Group!
            if isSearching == false {
                group1 = groups[rootView.tag]
            } else {
                group1 = searchGroups[rootView.tag]
            }
            
            
            
//            group1.groupRef.observeSingleEvent(of: .value, with: {(snapshot) in
//            
//                let newGroup = Group(snap: snapshot)
//                
//                if newGroup.members.contains(self.user) || newGroup.admins.contains(self.user) {
//                    // TODO: Enter group view controller
//                    // and display data
//                    self.performSegue(withIdentifier: "goToGroupPage", sender: newGroup)
//                } else if !newGroup.admins.contains(self.user) || !newGroup.members.contains(self.user)  {
//                    let pendingDictionary = ["pending_members": ["\(self.uid!)": true]]
//                    self.refGroups.child(group1.groupId).updateChildValues(pendingDictionary)
//                    self.showAlertController(message: "Please wait for response", title: "Request Send")
//                }
//            })
            
            if group1.members.contains(self.user) || group1.admins.contains(self.user) {
                // TODO: Enter group view controller
                // and display data
                self.performSegue(withIdentifier: "goToGroupPage", sender: group1)
            } else if !group1.admins.contains(self.user) || !group1.members.contains(self.user)  {
                let pendingDictionary = ["pending_members": ["\(self.uid!)": true]]
                self.refGroups.child(group1.groupId).updateChildValues(pendingDictionary)
                self.showAlertController(message: "Please wait for response", title: "Request Send")
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
        
        var group: Group!
        if isSearching == false {
            group = groups[indexPath.row]
        } else {
            group = searchGroups[indexPath.row]
        }
        
        
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
        if isSearching == false {
            return groups.count
        } else {
            return searchGroups.count
        }
        return 0
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       // closeFloatingActionButton()
        
        if searchBar.text != nil {
            if isSearching == false {
                searchGroups.removeAll()
                isSearching = true
            } else {
                reload()
            }
        } else {
            searchBar.returnKeyType = .done
            isSearching = true
        }
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if sear
//    }
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // TODO: Show Groups
        if searchBar.text != nil {
            searchGroups.removeAll()
            loadSearchedGroups()
        }
        
    }
    
    func loadSearchedGroups(){
        let searchText = searchBar.text
        print(searchText!)
        //        let strSearch = "je"
        let query = rootRef.child("Groups").queryOrdered(byChild:  "search_name").queryStarting(atValue: searchText!.lowercased()).queryEnding(atValue: searchText!.lowercased() + "\u{f8ff}")
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let group = Group(snap: child)
                if group.groupStatus == false {
                    self.searchGroups.append(group)
                    self.reload()
                }
            }
        })
    }
    
}
