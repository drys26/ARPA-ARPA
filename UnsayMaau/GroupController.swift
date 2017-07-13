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
    
    var groups = [[Group]]()
    
    var countOfNotifications = [String:Any]()
    
    var searchGroups = [Group]()
    
    var isSearching: Bool!
    
    var rootRef: DatabaseReference!
    
    var refGroups: DatabaseReference!
    
    var refGroupsHandle: DatabaseHandle!
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var sections = [String]()
    
    //["Your Group","Trending"]
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "WhatsBest"))
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        
        // Set the search bar delegate and add refresh control to the table view
        
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
    
    // Get the current user data
    
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
        //        if isSearching == true {
        //            searchGroups.removeAll()
        //            loadSearchedGroups()
        //        } else {
        //            refGroups.observeSingleEvent(of: .value, with: {(snapshot) in
        //                if let rootGroups = snapshot.children.allObjects as? [DataSnapshot] {
        //                    for rootGroup in rootGroups {
        //                        let group = Group(snap: rootGroup)
        //                        if !self.groups.contains(group) {
        //                            if group.groupStatus == false {
        //                                self.groups.append(group)
        //                                self.reload()
        //                            }
        //                        }
        //                        if self.groups.contains(group) && group.groupStatus == true {
        //                            if let index = self.groups.index(of: group) {
        //                                self.groups.remove(at: index)
        //                                DispatchQueue.main.async {
        //                                    self.groupTableView.reloadData()
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //            })
        //        }
        
        // If there is pending members
        
        //        if snapshot.hasChild("pending_members") {
        //            self.sections.insert("Pending", at: 0)
        //            self.sections.remove(at: 1)
        //            self.group.groupRef.child("pending_members").observeSingleEvent(of: .value, with: {(rootSnapshot) in
        //                let value = rootSnapshot.value as! [String: Any]
        //                for (key , _) in value {
        //                    self.rootRef.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
        //                        let user = User(snap: snapshot)
        //                        self.users[0].append(user)
        //                        self.reload()
        //                    })
        //                }
        //            })
        //        }
        
        // Append the groups array and sections array if group count == 0
        if groups.count == 0 {
            self.groups.append([Group]())
            self.groups.append([Group]())
            self.sections.append("Your Group")
            self.sections.append("Trending")
        }
        
        // If user is searching
        if isSearching == true {
            searchGroups.removeAll()
            loadSearchedGroups()
        } else { // if the user is not searching
            
            // Get the users groups in member groups node in firebase database
            rootRef.child("Users_Groups").child(uid!).child("Member_Groups").observeSingleEvent(of: .value, with: { (rootSnapshot) in
                if rootSnapshot.childrenCount != 0 {
                    
                    // if section index 0 is Trending then insert groups section in index 0
                    
                    if self.sections[0] == "Trending" {
                        self.sections.insert("Your Group", at: 0)
                        self.groups.insert([Group](), at: 0)
                    }
                    
                    let valueDictionary = rootSnapshot.value as! [String: Any]
                    
                    // Loop through the dictionary of the users groups
                    
                    for (key,_) in valueDictionary {
                        
                        self.refGroups.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            let yourGroup = Group(snap: snapshot)
                            
                            // Get your joined groups
                            let isNotInGroups = !self.groups[0].contains(yourGroup)
                            
                            if isNotInGroups {
                                self.groups[0].append(yourGroup)
                                if self.countOfNotifications[yourGroup.groupId] == nil {
                                    self.rootRef.child("Group_Notifications").child(key).child("Post_Notifications").observeSingleEvent(of: .value, with: { (snapshotOfCount) in
                                        print(" \(yourGroup.groupId)  Snapshot of count \(snapshotOfCount.childrenCount)")
                                        self.countOfNotifications[yourGroup.groupId] = snapshotOfCount.childrenCount.hashValue
                                    })
                                }
                                self.reload()
                            }
                            if self.groups[1].contains(yourGroup) {
                                self.groups[1].remove(at: self.groups[1].index(of: yourGroup)!)
                                self.reload()
                            }
                        })
                    }
                    
                } else {
                    if self.sections[0] == "Your Group" {
                        self.sections.remove(at: 0)
                        self.groups.remove(at: 0)
                    }
                }
                
                self.refGroups.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let rootGroups = snapshot.children.allObjects as? [DataSnapshot] {
                        
                        if rootGroups.count != 0 {
                            
                            if !self.sections.contains("Trending") {
                                self.sections.insert("Trending", at: self.sections.count - 1)
                                //self.sections.remove(at: self.sections.count - 1)
                            }
                            
                            
                            
                            for groupSnap in rootGroups {
                                
                                let trendingGroup = Group(snap: groupSnap)
                                
                                print(trendingGroup.groupName)
                                
                                let i = self.groups.count - 1
                                
                                //                                if self.groups.count == 2 {
                                //                                    if self.groups[0].contains(trendingGroup) {
                                //                                        self.groups[1].remove(at: self.groups[1].index(of: trendingGroup)!)
                                //                                        self.reload()
                                //                                    }
                                //                                }
                                
                                if !self.groups[i - 1].contains(trendingGroup) && !self.groups[i].contains(trendingGroup) && trendingGroup.groupStatus == false {
                                    self.groups[i].append(trendingGroup)
                                    print(trendingGroup.groupId)
                                    self.reload()
                                }
                                //
                                
                                //                                if self.groups[i - 1].contains(trendingGroup) && self.groups[i].count != 0 {
                                //                                    // Remove from trending
                                //                                    self.groups[i].remove(at: self.groups[i].index(of: trendingGroup)!)
                                //                                    self.reload()
                                //                                }
                            }
                            
                        }
                        
                        
                    }
                    
                })
                
                
            })
            
        }
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSearching = false
        groupTableView.delegate = self
        groupTableView.dataSource = self
        rootRef = Database.database().reference()
        getUserData()
        rootRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild("Groups") {
                self.refGroups = self.rootRef.child("Groups")
                self.loadGroups()
            }
        })
        
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
            
            let arr = rootView.accessibilityLabel!.components(separatedBy: ",")
            
            let section = Int(arr[0])!
            let row = Int(arr[1])!
            
            var group1: Group!
            if isSearching == false {
                group1 = groups[section][row]
            } else {
                group1 = searchGroups[rootView.tag]
            }
            
            // Get the Groups Data
            rootRef.child("Groups").child(group1.groupId).observeSingleEvent(of: .value, with: {(snapshot) in
                let valueDictionary = snapshot.value as! [String: Any]
                var membersDictionary = [String: Any]()
                var adminDictionary = [String: Any]()
                if snapshot.hasChild("members") {
                    membersDictionary = valueDictionary["members"] as! [String: Any]
                }
                if snapshot.hasChild("admin_members") {
                    adminDictionary = valueDictionary["admin_members"] as! [String: Any]
                }
                
                // If member is Admin
                let isAdmin = adminDictionary[self.user.userId] != nil
                // If member is Member
                let isMember = membersDictionary[self.user.userId] != nil
                
                let newGroup = Group(snap: snapshot)
                                                                                                                                                                                                                       
                if isAdmin || isMember {
                    // TODO: Enter group view controller
                    // and display data
                    
                    
                    // Index path for every cell
                    let index = IndexPath(row: row, section: section)
                    let cell = self.groupTableView.cellForRow(at: index) as! GroupTableViewCell
                    
                    for view in cell.rootView.subviews {
                        // if view tag equals to 51 remove it
                        if view.tag == 51 {
                            view.removeFromSuperview()
                        }
                    }
                    
                    // Perform Segue and pass the newGroup variable
                    
                    self.performSegue(withIdentifier: "goToGroupPage", sender: newGroup)
                    
                } else if !isAdmin || !isMember  {
                    let pendingDictionary = ["pending_members": ["\(self.uid!)": true]]
                    self.refGroups.child(newGroup.groupId).updateChildValues(pendingDictionary)
                    self.showAlertController(message: "Please wait for response", title: "Request Send")
                }
            })
            //            if group1.members.contains(self.user) || group1.admins.contains(self.user) {
            //                // TODO: Enter group view controller
            //                // and display data
            //                self.performSegue(withIdentifier: "goToGroupPage", sender: group1)
            //            } else if !group1.admins.contains(self.user) || !group1.members.contains(self.user)  {
            //                let pendingDictionary = ["pending_members": ["\(self.uid!)": true]]
            //                self.refGroups.child(group1.groupId).updateChildValues(pendingDictionary)
            //                self.showAlertController(message: "Please wait for response", title: "Request Send")
            //            }
            
            
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
                root.user = self.user
            }
        }
    }
    
}



extension GroupController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.groups[section].count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count { //&& groups[section].count > 0
            return sections[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionHeaderHeight + 35
        }
        //        if groups[section].count == 0 {
        //            return 0.01
        //        }
        return tableView.sectionHeaderHeight
    }
    
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
            group = groups[indexPath.section][indexPath.row]
        } else {
            //group = searchGroups[indexPath.section][indexPath.row]
        }
        
        
        cell.rootView.tag = indexPath.row
        
        cell.rootView.accessibilityLabel = "\(indexPath.section),\(indexPath.row)"
        
        //        if countOfNotifications[group.groupId] != nil  {
        //            let labelForNotifications = UILabel(frame: CGRect(x: cell.rootView.frame.maxX - 80, y: 15, width: cell.rootView.frame.size.width, height: 30))
        //            labelForNotifications.tag = indexPath.row
        //            labelForNotifications.textColor = UIColor.white
        //            let count = countOfNotifications[group.groupId] as! Int
        //            if count != 0 {
        //                labelForNotifications.text = "\(count)"
        //                cell.rootView.addSubview(labelForNotifications)
        //            }
        //        }
//        
//        self.rootRef.child("Group_Notifications").child(group.groupId).child("Post_Notifications").observe(.value, with: { (snapshotOfCount) in
//            if snapshotOfCount.childrenCount != 0 {
//                let dictionary = snapshotOfCount.value as! [String: Any]
//                let notified = dictionary["notified_users"] as! [String: Any]
//                if notified[self.uid!] == nil {
//                    let labelForNotifications = UILabel(frame: CGRect(x: cell.rootView.frame.maxX - 80, y: 15, width: cell.rootView.frame.size.width, height: 30))
//                    labelForNotifications.tag = 51
//                    labelForNotifications.textColor = UIColor.white
//                    let count = snapshotOfCount.childrenCount.hashValue - 1
//                    if count != 0 {
//                        labelForNotifications.text = "\(count)"
//                        cell.rootView.addSubview(labelForNotifications)
//                    }
//                }
//            }
//        })
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickCell(sender:)))
        
        cell.rootView.addGestureRecognizer(tap)
        cell.backgroundImageView.sd_setImage(with: URL(string: group.backgroundImageUrl))
        cell.groupDescriptionText.text = group.groupDescription
        cell.groupMembersText.text = "\(group.members.count) members"
        cell.groupNameText.text = group.groupName
        
        
        
        return cell
        
    }
    
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection
    //        section: Int) -> Int {
    //        if isSearching == false {
    //            return groups.count
    //        } else {
    //            return searchGroups.count
    //        }
    //        return 0
    //    }
    
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
