//
//  AddGroupViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 27/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate, UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var groupShortDescription: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var groupStatusSegment: UISegmentedControl!
    
    @IBOutlet weak var usersTableView: UITableView!
    
    let textFieldTitle = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    
    var postsDictionary = [String:Any]()
    
    var searchUsers = [User]()
    
    var isInvitedUser = [User]()
    
    var ref: DatabaseReference!
    
    var groupPostId: String!
    
    var imageDataTemp: Data?
    
    var imageDataUrl: String?
    
    var backgroundImageId: String?
    
    var uid: String = (Auth.auth().currentUser?.uid)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        searchTextField.delegate = self
        
        // Set the Done Button in right bar button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(self.postAction))
        
        // Do any additional setup after loading the view.
        
        
        textFieldTitle.placeholder = "Group Name"
        textFieldTitle.borderStyle = .roundedRect
        textFieldTitle.textAlignment = .center
        self.navigationItem.titleView = textFieldTitle
        
        let lineView = UIView(frame: CGRect(x: 0, y: searchTextField.center.y, width: searchTextField.frame.width, height: 2.0))
        lineView.backgroundColor = UIColor.darkGray
        searchTextField.addSubview(lineView)
    }
    
    func postAction() {
        print("Post Action")
        
        groupPostId = ref.childByAutoId().key
        
        if let imageData = imageDataTemp {
            uploadImagePartTwo(data: imageData)
        }
        
        var status: Bool!
        
        if groupStatusSegment.selectedSegmentIndex == 0 {
            status = false
        } else {
            status = true
        }
        
        let groupName = textFieldTitle.text
        
        var groupDescription: String = "NULL"
        
        if groupShortDescription.text != "" {
            groupDescription = groupShortDescription.text!
        }
        
        postsDictionary = ["group_name":groupName!,"group_description":groupDescription,"private_status": status,"search_name": groupName!.lowercased(),"admin_members":["\(uid)":true]]
        
        //ref.child("Posts").child(groupPostId).setValue(postsDictionary)
    }
    
    func loadSearchUsers(){
        let searchText = searchTextField.text!
        let userRef = ref.child("Users").queryOrdered(byChild: "search_name").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased() + "\u{f8ff}")
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let user = User(snap: child)
                print(user.displayName)
                if !child.hasChild("account_status") && user.userId != self.uid && !self.searchUsers.contains(user) {
                    self.searchUsers.insert(user, at: 0)
                    self.reload()
                }
            }
        })
    }
    
    func removeUsersNotChecked(){
        //        for user in isInvitedUser {
        //            if !searchUsers.contains(user) {
        //                searchUsers.remove(at: searchUsers.index(of: user)!)
        //            }
        //        }
        
        for user in searchUsers {
            if !isInvitedUser.contains(user) {
                searchUsers.remove(at: searchUsers.index(of: user)!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "searchUsersCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InviteMembersTableViewCell else {
            fatalError("The dequeued cell is not an instance of searchUsersCell.")
        }
        
        let user = searchUsers[indexPath.row]
        cell.userDisplayName.text = user.displayName
        cell.userImageView.sd_setImage(with: URL(string: user.photoUrl))
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width / 2
        cell.userImageView.clipsToBounds = true
        
        if isInvitedUser.contains(user) {
            cell.userSwitch.isOn = true
        } else {
            cell.userSwitch.isOn = false
        }
        cell.userSwitch.tag = indexPath.row
        cell.userSwitch.addTarget(self, action: #selector(self.inviteUser(sender:)), for: .touchUpInside)
        return cell
    }
    
    func inviteUser(sender: UISwitch){
        let user = searchUsers[sender.tag]
        if sender.isOn == true {
            isInvitedUser.append(user)
        } else {
            if isInvitedUser.contains(user) {
                let index = isInvitedUser.index(of: user)
                isInvitedUser.remove(at: index!)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUsers.count
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        //searchUsers.removeAll()
        removeUsersNotChecked()
        loadSearchUsers()
        return true
    }
    
    
    
    @IBAction func selectImageFromLibrary(_ sender: Any) {
        presentImagePickerController()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage , let imageData = UIImageJPEGRepresentation(selectedImage, 0.2) else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = selectedImage
        imageDataTemp = imageData
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerController(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func uploadImagePartTwo(data: Data){
        let storageRef = Storage.storage().reference(withPath: "Group_Post_Images/\(groupPostId!).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "images/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetaData, completion: { (metadata,error) in
            if(error != nil){
                print("I received an error! \(error?.localizedDescription ?? "null")")
            } else {
                let downloadUrl = metadata!.downloadURL()
                print("Upload complete! Heres some metadata!! \(String(describing: metadata))")
                print("Here's your download url \(downloadUrl!)")
                self.postsDictionary["background_image_url"] = downloadUrl!.absoluteString
                self.updatePostDictionary()
            }
        })
        navigationController?.popViewController(animated: true)
    }
    
    func updatePostDictionary(){
        
        postsDictionary["timestamp"] = 0 - (NSDate().timeIntervalSince1970 * 1000)
        ref.child("Groups").child(groupPostId).setValue(postsDictionary)
        ref.child("Users_Groups").child(uid).child("Member_Groups").updateChildValues([groupPostId:true])
        if isInvitedUser.count != 0 {
            for user in isInvitedUser {
                
                // Add in group invited pending members
                
                ref.child("Groups").child(groupPostId).child("invited_pending_members").updateChildValues(["\(user.userId)": true])
                
                // Add in users pending groups
                
                ref.child("Users_Groups").child(user.userId).child("Pending_Groups").updateChildValues([groupPostId:uid])
                
                
                // Add in users pending group notifications
                
                ref.child("Notifications").child(user.userId).child("Pending_Groups_Notifications").updateChildValues([groupPostId:uid])
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
