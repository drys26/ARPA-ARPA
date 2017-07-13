//
//  ShowCommentViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 03/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ShowCommentViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , UITextViewDelegate  {
    
    // MARK: Properties
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: UIView!
    
    var heightAdded: Bool = false
    
    var comments = [Comment]()
    
    var post: Post!
    
    var user: User!
    
    var ref: DatabaseReference!
    
    var commentRef: DatabaseReference!
    
    var commentRefHandle: DatabaseHandle!
    
    var uid = Auth.auth().currentUser?.uid
    
    var isGroupComment: Bool!
    
    var group: Group!
    
    var groupPost: GroupPost!
    
    var isImage = false
    
    @IBOutlet weak var userCommentTextView: UITextView!
    
    @IBOutlet weak var commentTable: UITableView!
    
    @IBAction func commentAction(_ sender: Any) {
        
//        var commentRef: DatabaseReference!
//        
//        if isGroupComment == false {
//            commentRef = ref.child("Post_Comment").child(post.postKey)
//        } else {
//            commentRef = ref.child("Group_Post_Comment").child(group.groupId).child(groupPost.postKey)
//        }
        
        let commentID = commentRef.childByAutoId().key
        
        
        let commentDictionary = ["sender_id":uid!,"comment": userCommentTextView.text,"comment_type": "text"] as [String : Any]
        
        commentRef.child(commentID).setValue(commentDictionary)
        
        let timestamp = NSDate().timeIntervalSince1970 * 1000
        
        if isGroupComment == false {
            post.postRef.updateChildValues(["timestamp": 0 - timestamp])
        } else {
            //group.groupRef.updateChildValues(["timestamp": 0 - timestamp])
            ref.child("Group_Posts").child(group.groupId).child(groupPost.postKey).updateChildValues(["timestamp": 0 - timestamp])
        }
        userCommentTextView.text = ""
        heightConstraint.constant = 50
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == userCommentTextView {
            
            let fixedWidth = textView.frame.size.width
            let fixedHeight = textView.frame.size.height
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            
            
            if textView.frame.size.height != fixedHeight {
                heightConstraint.constant = 10 + textView.frame.size.height + 8
            }
            
            if textView.text == "" {
                commentButton.isEnabled = false
            }
            else{
                commentButton.isEnabled = true
            }
        }
        else {
            
            let currentOffset = commentTable.contentOffset
            UIView.setAnimationsEnabled(true)
            commentTable.beginUpdates()
            commentTable.endUpdates()
            UIView.setAnimationsEnabled(true)
            commentTable.setContentOffset(currentOffset, animated: false)
            
        }
        
        
    }
    
    
    
    
    func keyboardWillShow(notification: Notification){
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func keyboardWillHide(notification: Notification){
        bottomConstraint.constant = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        userCommentTextView.delegate = self
        
        // Set the border
        
        userCommentTextView.layer.borderWidth = 0.6
        userCommentTextView.layer.borderColor = UIColor.lightGray.cgColor
        userCommentTextView.isScrollEnabled = false
        userCommentTextView.textColor = UIColor.darkText
        userCommentTextView.layer.cornerRadius = 5
        //        userCommentTextView.sizeToFit()
        userCommentTextView.layoutIfNeeded()
        let height = userCommentTextView.sizeThatFits(CGSize(width: userCommentTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        userCommentTextView.contentSize.height = height
        // set the datasource and delegate
        
        commentTable.delegate = self
        commentTable.dataSource = self
        
        // Initialize the database reference
        ref = Database.database().reference()
        
        // NAVIGATION
        
        navigationItem.title = "Comments"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backViewController))
        
        // Get User Data
        
        getUserData()
        
        loadComments()
        
        
        commentTable.estimatedRowHeight = 70
        
        commentTable.rowHeight = UITableViewAutomaticDimension
        
        commentTable.tableFooterView = UIView()
        
        
    }
    
    func backViewController(){
        if isGroupComment == false {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.commentTable.reloadData()
            
            
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        commentRef.removeObserver(withHandle: commentRefHandle)
    }
    
    func loadComments(){
        
        if isGroupComment == false {
            commentRef = ref.child("Post_Comment").child(post.postKey)
        } else {
            commentRef = ref.child("Group_Post_Comment").child(group.groupId).child(groupPost.postKey)
        }
        
        commentRefHandle = commentRef.observe(.childAdded, with: {(snapshot) in
            
            let comment = Comment(snap: snapshot)
            
            self.comments.append(comment)
            
            self.reload()
            
        })
        
        
        
    }
    
    
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.displayName)
            //            self.userImageView.sd_setImage(with: URL(string: self.user.photoUrl))
        })
    }
    
    func returnButtons(row: Int) -> [UIButton] {
        
        var buttons = [UIButton]()
        
        
        func loopButton(count: Int){
            for i in 0..<count {
                buttons.append(UIButton())
            }
        }
        
        func loopButton2(){
            for btn in buttons {
                // Set access label
                btn.accessibilityLabel = "\(row),\(btn.accessibilityLabel!)"
                // Add Target
                btn.addTarget(self, action: #selector(self.commandAction(sender:)), for: .touchUpInside)
            }
        }
        
        
        loopButton(count: 2)
        buttons[0].setImage(UIImage(named: "edit_icon"), for: .normal)
        buttons[0].accessibilityLabel = "edit"
        buttons[1].setImage(UIImage(named: "delete_icon"), for: .normal)
        buttons[1].accessibilityLabel = "delete"
        loopButton2()
        
        return buttons
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            
            if textView != userCommentTextView {
                
                textView.resignFirstResponder()
                textView.isUserInteractionEnabled = false
                
                let comment = comments[textView.tag]
                
                textView.isEditable = false
                textView.layer.borderWidth = 0
                textView.layer.borderColor = UIColor.clear.cgColor
                self.userCommentTextView.isEditable = true
                commentRef.child(comment.commentKey).updateChildValues(["comment": textView.text])
                
                return false
                
                
            }
            
        }
        return true
    }
    
    func commandAction(sender: UIButton){
        
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        let row = Int((arr?[0])!)
        let access = arr?[1]
        
        let comment = comments[row!]
        
        func removeUsers(){
            self.comments.remove(at: row!)
            self.commentTable.deleteRows(at: [IndexPath(row:row! , section: 0)], with: .bottom)
        }
        
        if access! == "edit" {
            //            group.groupRef.child("pending_members").child(user.userId).removeValue()
            //            group.groupRef.child("members").updateChildValues(["\(user.userId)": true])
            //            removeUsers()
            
            let cell = commentTable.cellForRow(at: IndexPath(row: row!, section: 0)) as! CommentTableViewCell
            
            cell.commentTextView.isUserInteractionEnabled = true
            self.userCommentTextView.isEditable = false
            cell.commentTextView.isEditable = true
            cell.commentTextView.layer.borderWidth = 1
            cell.commentTextView.layer.borderColor = UIColor.lightGray.cgColor
            cell.commentTextView.becomeFirstResponder()
            
            print("edit")
        } else if access! == "delete" {
            //            group.groupRef.child("pending_members").child(user.userId).removeValue()
            //            removeUsers()
            let alertController = UIAlertController(title: "Confirmation", message: "Do you want to delete this comment?", preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                comment.ref.removeValue()
                self.comments.remove(at: row!)
                self.reload()
            })
            let noButton = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(yesButton)
            alertController.addAction(noButton)
            self.present(alertController, animated: true, completion: nil)
            print("delete")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cellIdentifier = "commentCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CommentTableViewCell else {
            fatalError("The dequeued cell is not an instance of commentCell.")
        }
        
        let comment = comments[indexPath.row]
        
        let userRef = ref.child("Users").child(comment.userCommentID)
        
        
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as! [String: Any]
            
            let imageUrl = value["photo_url"] as! String
            
            let userDisplayName = value["display_name"] as! String
            
            var imageVoteNumber: String = ""
            
            let attribText = NSMutableAttributedString(string: "\(userDisplayName) ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
            
            cell.commentUserDisplayName.attributedText = attribText
            
            let imageAttach = NSTextAttachment()
            
            var stringChild: String!
            
            var stringValueChild: String!
            
            var stringPostKey: String!
            
            var postID: String!
            
            if self.isGroupComment == false {
                stringValueChild = "post_voted"
                stringChild = "post_voted/\(self.post.postKey)"
                stringPostKey = self.post.postKey
                postID = self.post.authorImageID
            } else {
                stringValueChild = "group_post_voted"
                stringChild = "group_post_voted/\(self.groupPost.postKey)"
                stringPostKey = self.groupPost.postKey
                postID = self.groupPost.authorImageID
            }
            
            if snapshot.hasChild(stringChild){
                
                let post_voted = value[stringValueChild] as! [String: Any]
                imageVoteNumber = post_voted[stringPostKey] as! String
                
                switch imageVoteNumber {
                case "1":
                    imageAttach.image = UIImage(named: "vote_image1")
                    break
                case "2":
                    imageAttach.image = UIImage(named: "vote_image2")
                    break
                case "3":
                    imageAttach.image = UIImage(named: "vote_image3")
                    break
                case "4":
                    imageAttach.image = UIImage(named: "vote_image4")
                    break
                default:
                    print("no image")
                    break
                }
                
                let attribImage = NSAttributedString(attachment: imageAttach)
                
                let combi = NSMutableAttributedString()
                combi.append(attribText)
                combi.append(attribImage)
                cell.commentUserDisplayName.attributedText = combi
            }
            
            
            
            
            
            if comment.userCommentID == postID {
                
                let imageAttach = NSTextAttachment()
                imageAttach.image = UIImage(named: "owner_post")
                let attribImage = NSAttributedString(attachment: imageAttach)
                
                let combi = NSMutableAttributedString()
                
                combi.append(cell.commentUserDisplayName.attributedText!)
                
                combi.append(attribImage)
                
                cell.commentUserDisplayName.attributedText = combi
                
                //                cell.commentTextView.attributedText = combi
                
            }
            
            cell.commentImageView.sd_setImage(with: URL(string: imageUrl))
            
            
            
            // cell.commentTextView.text = "\(comment.comment)  \(imageVoteNumber)"
        })
        
        
        cell.commentTextView.text = comment.comment
        
        
        cell.commentTextView.isUserInteractionEnabled = false
        cell.commentTextView.delegate = self
        cell.commentTextView.tag = indexPath.row
        
        cell.commentImageView.layer.cornerRadius = cell.commentImageView.frame.size.width / 2
        
        if cell.buttonStackView.subviews.count == 0 {
            if comment.userCommentID == uid! {
                let buttons = returnButtons(row: indexPath.row)
                for btn in buttons {
                    cell.buttonStackView.addArrangedSubview(btn)
                }
            } else {
                for view in cell.buttonStackView.subviews {
                    cell.buttonStackView.removeArrangedSubview(view)
                }
            }
        }
        
        
        
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
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
