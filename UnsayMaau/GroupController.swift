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
    
<<<<<<< HEAD
    
    @IBOutlet weak var searchBar: UISearchBar!
=======
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    
>>>>>>> 56c0b196debfa2528e05b7f56cb97feaab8c7703
    
    var groups = [Group]()
    
    var searchGroups = [Group]()
    
    var isSearching = false
    
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
        
<<<<<<< HEAD
//        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
=======
        refreshControl.addTarget(self, action: #selector(GroupController.refreshData), for: .valueChanged)
>>>>>>> 56c0b196debfa2528e05b7f56cb97feaab8c7703
        
    self.view.bringSubview(toFront: floats)
        self.view.bringSubview(toFront: floats)
<<<<<<< HEAD
=======
        
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
>>>>>>> 56c0b196debfa2528e05b7f56cb97feaab8c7703
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
        refGroupsHandle = refGroups.observe(.childAdded, with: {(snapshot) in
            let group = Group(snap: snapshot)
            if !self.groups.contains(group) {
                if group.groupStatus == false {
                    self.groups.append(group)
                    self.reload()
                }
            }
        })
    }
    
    func closeFloatingActionButton(){
        floats.open()
        floats.close()
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
        if refGroups != nil {
            refGroups.removeObserver(withHandle: refGroupsHandle)
        }
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
            if group.members.contains(user) || group.admins.contains(user) {
                // TODO: Enter group view controller
                // and display data
                performSegue(withIdentifier: "goToGroupPage", sender: group)
            } else if !group.admins.contains(user) || !group.members.contains(user)  {

                let pendingDictionary = ["pending_members": ["\(uid!)": true]]
                refGroups.child(group.groupId).updateChildValues(pendingDictionary)
                showAlertController(message: "Please wait for response", title: "Request Send")
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
        if isSearching == false {
            return groups.count
        } else {
            return searchGroups.count
        }
        return 0
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        closeFloatingActionButton()
        searchGroups.removeAll()
        isSearching = true
        reload()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // TODO: Show Groups
        if searchBar.text != nil {
            loadSearchedGroups()
        }
        
    }
    
    
    
    
    
    func loadSearchedGroups(){
        let searchText = searchBar.text
        print(searchText!)
//        let strSearch = "je"
        rootRef.child("Groups").queryOrdered(byChild:  "group_name").queryStarting(atValue: searchText!).queryEnding(atValue: searchText! + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! [String: Any]
            
            for child in snapshot.children {
                print(child)
            }
            
//            let key = value.keys.first
//            
//            self.rootRef.child("Groups").child(key!).observeSingleEvent(of: .value, with: {(snapshot1) in
//                print(snapshot1)
////                let group = Group(snap: snapshot1)
////                self.searchGroups.append(group)
////                self.reload()
//            })
        })
//
//        let searchRef = refGroups.queryOrdered(byChild: "group_name").queryEqual(toValue: searchText!)
//        searchRef.observeSingleEvent(of: .value, with: {(snapshot) in
//            if snapshot.exists() {
//                for a in ((snapshot.value as AnyObject).allKeys)!{
//                    print(a)
//                    self.rootRef.child("Groups").child(a as! String).observeSingleEvent(of: .value, with: {(snapshot1) in
//                        let group = Group(snap: snapshot1)
//                        self.searchGroups.append(group)
//                        self.reload()
//                    })
//                }
//               // let key = ((snapshot.value as AnyObject).allKeys)!
//            } else {
//                print("we don't have that, add it to the DB now")
//            }
//        })
    }
    
}
