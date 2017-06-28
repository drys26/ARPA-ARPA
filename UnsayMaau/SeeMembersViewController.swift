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
    
    
    @IBOutlet var modelView: UIView!
    
    @IBOutlet weak var seeMembersTableView: UITableView!
    
    var users: [[User]] = []
    
    var mainUser: User!
    
    var group: Group!
    
    var rootRef: DatabaseReference!
    
    var uid = Auth.auth().currentUser?.uid
    
    var sections = ["Pending","Active","Inactive","Admin"]
    //["Pending","Active","Inactive","Admin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootRef = Database.database().reference()
        
        modelView.layer.cornerRadius = 5
        
        // Load Pending members
        
        seeMembersTableView.delegate = self
        seeMembersTableView.dataSource = self
        
        var tap = UILongPressGestureRecognizer(target: self, action: #selector(self.touchForOptions(recognizer:)))
        
        tap.minimumPressDuration = 1.0
        
        seeMembersTableView.addGestureRecognizer(tap)
        
        getUserData()
        
        self.users.append([User]())
        self.users.append([User]())
        self.users.append([User]())
        self.users.append([User]())
        
        loadGroupMembers()
        
       
    }
    
    func commandActionButton(sender: UIButton){
        
        let info = sender.accessibilityLabel?.components(separatedBy: ",")
        
        let section = info?[0]
        let row = info?[1]
        let buttonText = info?[2]
        
        let user = users[section][row]
        
        if buttonText == "Accept" {
//            rootRef.child("Groups").child(group.groupId).child("pending_members").child(user.userId).removeValue()
//            rootRef.child("Groups").child(group.groupId).child("members").updateChildValues(["\(user.userId)": ["isActive":false,"isJoined":true]])
//            group.groupRef.child("pending_members")
        }
        

    }
    
    func touchForOptions(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let swipeLocation = recognizer.location(in: self.seeMembersTableView)
            if let swipedIndexPath = seeMembersTableView.indexPathForRow(at: swipeLocation) {
                if let swipedCell = self.seeMembersTableView.cellForRow(at: swipedIndexPath) {
                    // Swipe happened. Do stuff!
                    
                    let section = swipedIndexPath.section
                    let row = swipedIndexPath.row
                    var buttons = [UIButton]()
                    
                    if section == 0 {
                        
                        buttons.append(UIButton())
                        buttons.append(UIButton())
//
                        // Accept,Decline
                        buttons[0].setTitle("Accept", for: .normal)
                        buttons[1].setTitle("Decline", for: .normal)
                        
                        for btn in buttons {
                            // Set access label
                            btn.accessibilityLabel = "\(section),\(row),\(btn.titleLabel!.text)"
                            // Add Target
                            btn.addTarget(self, action: #selector(self.commandActionButton(sender:)), for: .touchUpInside)
                        }
                    }
                    
                    let rootStackView = modelView.viewWithTag(10) as! UIStackView
                    
                    for button in buttons {
                        rootStackView.addArrangedSubview(button)
                    }
                    
                    let user = users[section][row]
                    
                    
                    
                    
                    let visualEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
 
                    visualEffect.effect = UIBlurEffect(style: .dark)
                    
                    modelView.layer.shadowRadius = 1
                    
                    visualEffect.alpha = 0.8
                    
                    visualEffect.tag = 86
                    
                    self.view.addSubview(visualEffect)
                    self.view.addSubview(modelView)
                    modelView.center = self.view.center
                    modelView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    modelView.alpha = 0
                    UIView.animate(withDuration: 0.4, animations: {
                        self.modelView.alpha = 1
                        self.modelView.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.modelView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.modelView.alpha = 0
            self.view.viewWithTag(86)?.removeFromSuperview()
        }) {(success: Bool) in
            self.modelView.removeFromSuperview()
        }
    }
//
//    func displayOptions(sender: UILongPressGestureRecognizer){
//        if sender.state == UIGestureRecognizerState.began {
//            let touchpoint = sender.location(in: self.seeMembersTableView)
//            if let indexPath = seeMembersTableView.indexPathForRow(at: touchpoint) {
//                print("hahahaha")
//                self.view.addSubview(modelView)
//                modelView.center = self.view.center
//                modelView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//                modelView.alpha = 0
//                UIView.animate(withDuration: 0.4, animations: {
//                    self.visualEffectView.effect = self.effect
//                    self.modelView.alpha = 1
//                    self.modelView.transform = CGAffineTransform.identity
//                })
//            }
//        }
//    }
    
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
        
        group.groupRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // If there is pending members
            
            if snapshot.hasChild("pending_members") {
                self.group.groupRef.child("pending_members").observeSingleEvent(of: .value, with: {(rootSnapshot) in
                    let value = rootSnapshot.value as! [String: Any]
                    for (key , _) in value {
                        self.rootRef.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                            let user = User(snap: snapshot)
                            self.users[0].append(user)
                            reload()
                        })
                    }
                })
            }
            
            // if there is active members
            
            if snapshot.hasChild("members") {
                self.group.groupRef.child("members").observeSingleEvent(of: .value, with: {(rootSnapshot) in
                    
                    let memberDict = rootSnapshot.value as! [String: Any]
                    for (key , booleanValue) in memberDict {
                        let isActive = booleanValue as! Bool
                        self.rootRef.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                            let user = User(snap: snapshot)
                            if isActive {
                                self.users[1].append(user)
                            } else {
                                self.users[2].append(user)
                            }
                            reload()
                        })
                    }
                    
                    
                })
            }
            
            if snapshot.hasChild("admin_members") {
                self.group.groupRef.child("admin_members").observeSingleEvent(of: .value, with: {(rootSnapshot) in
                    
                    let adminMembersDict = rootSnapshot.value as! [String: Any]
                    for (key , booleanValue) in adminMembersDict {
                        let isActive = booleanValue as! Bool
                        self.rootRef.child("Users").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                            let user = User(snap: snapshot)
                            self.users[3].append(user)
                            reload()
                        })
                    }
                    
                    
                })
            }
            
        })
        
        func reload() {
            DispatchQueue.main.async {
                self.seeMembersTableView.reloadData()
            }
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

extension SeeMembersViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users[section].count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count && users[section].count > 0 {
            return sections[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableView.sectionHeaderHeight + 17
        }
        return tableView.sectionHeaderHeight
    }
}

extension SeeMembersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "seeMembersCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SeeMembersTableViewCell else {
            fatalError("The dequeued cell is not an instance of seeMembersCell.")
        }
        
        let user = users[indexPath.section][indexPath.row]
        
        cell.memberDisplayName.text = user.displayName
        
        cell.memberImageView.sd_setImage(with: URL(string: user.photoUrl))
        
        cell.memberImageView.layer.cornerRadius = cell.memberImageView.frame.size.width / 2
        
        cell.memberCommandButton.layer.cornerRadius = cell.memberCommandButton.frame.height / 2
        
        cell.memberCommandButton.accessibilityLabel = "\(indexPath.section) \(indexPath.row)"
        
        cell.memberCommandButton.addTarget(self, action: #selector(self.commandAction(sender:)), for: .touchUpInside)
        
        cell.rootView.isUserInteractionEnabled = true
        
        
        
        
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
    
    func promptForOptions(sender: UIView) {
        print("clicked")
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
        
    }
}
