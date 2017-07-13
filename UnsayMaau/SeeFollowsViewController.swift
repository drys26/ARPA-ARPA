//
//  SeeFollowsViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 10/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SeeFollowsViewController: UIViewController, UITableViewDelegate , UITableViewDataSource  {
    
    
    @IBOutlet weak var followTableView: UITableView!
    @IBOutlet weak var followSearchBar: UISearchBar!
    
    var followType: String! // determine whether following or followers
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var users = [User]()
    
    var rootRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if rootRef == nil {
            rootRef = Database.database().reference()
            loadFollows()
        }
        
        followTableView.delegate = self
        followTableView.dataSource = self
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.touchForOptions(recognizer:)))
    
        followTableView.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Followers"
    }
    
    func loadFollows(){
        let userRef = rootRef.child("Users")
        if followType == "followers" {
            for userId in user.followersIDs {
                userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                    let followerUser = User(snap: snapshot)
                    print(followerUser.userId)
                    if !self.users.contains(followerUser) {
                        self.users.append(followerUser)
                        self.reload()
                    }
                    
                })
            }
        } else {
            for userId in user.followingIDs {
                userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                    let followingUser = User(snap: snapshot)
                    
                    if !self.users.contains(followingUser) {
                        self.users.append(followingUser)
                        self.reload()
                    }
                    
                })
            }
        }
        
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.followTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "followCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FollowTableViewCell else {
            fatalError("The dequeued cell is not an instance of followCell.")
        }
        
        let currentUser = users[indexPath.row]
        
        cell.followDisplayName.text = currentUser.displayName
        cell.followImageView.sd_setImage(with: URL(string: currentUser.photoUrl))
        cell.followImageView.layer.cornerRadius = cell.followImageView.frame.size.width / 2
        cell.followLocation.text = ""
        
        if user.userId == uid! {
            if followType == "following" {
                cell.actionButton.isHidden = true
            } else {
                cell.actionButton.setTitle("Unfollow", for: .normal)
                cell.actionButton.isHidden = false
                cell.actionButton.tag = indexPath.row
                cell.actionButton.addTarget(self, action: #selector(self.unfollowCommand(sender:)), for: .touchUpInside)
                cell.actionButton.layer.cornerRadius = 10
            }
        }
        return cell
    }
    
    func unfollowCommand(sender: UIButton){
        let currentUser = users[sender.tag]
        let userRef:DatabaseReference = rootRef.child("Users").child(uid!).child("following")
        
        if sender.titleLabel?.text == "Unfollow" {
            userRef.child(currentUser.userId).removeValue()
            sender.setTitle("Follow", for: .normal)
        } else {
            userRef.child(currentUser.userId).setValue(true)
            sender.setTitle("Unfollow", for: .normal)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func touchForOptions(recognizer: UIGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let swipeLocation = recognizer.location(in: self.followTableView)
            if let swipedIndexPath = followTableView.indexPathForRow(at: swipeLocation) {
                if let swipedCell = self.followTableView.cellForRow(at: swipedIndexPath) {
                    // Swipe happened. Do stuff!

                    let section = swipedIndexPath.section
                    let row = swipedIndexPath.row
                    
                    
                    
                    let pressedUser = users[row]
                    
                    print(pressedUser.displayName)
                    
                    let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    
                    profileVC.user = pressedUser
                    
                    profileVC.isCurrentUser = false
            
                    present(profileVC, animated: true, completion: nil)
                    
                }
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
