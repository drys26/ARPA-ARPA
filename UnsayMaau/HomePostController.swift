//
//  HomePostController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Floaty
import Firebase
import SDWebImage

class HomePostController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!

    
    var posts = [Post]()
    
    
    // Firebase reference
    
    var ref: DatabaseReference!
    
    // Firebase Handle
    
    var refHandle: UInt!
    
    var refUserHandle: UInt!
    
    var refVotePostHandle: UInt?
    
    var refVotePostTwoHandle: UInt?
    
    var uid = Auth.auth().currentUser?.uid
    
    var user: User!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear ")
        // Set the Database Reference
        if ref == nil {
            ref = Database.database().reference()
            getUserData()
            showPost()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("View Did Disapper")
        ref.removeObserver(withHandle: refUserHandle)
        ref.removeObserver(withHandle: refHandle)
        if let refVoteTemp = refVotePostHandle {
            ref.removeObserver(withHandle: refVotePostHandle!)
        }
        if let refVoteTemp = refVotePostTwoHandle {
            ref.removeObserver(withHandle: refVotePostTwoHandle!)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates of the collection to self
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        self.view.accessibilityIdentifier = "root_view"
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            
        
        
            return CGSize(width: view.frame.width - 20, height: 598)
        
    }
    
    
    
    
    
    func getUserData(){
        refUserHandle = ref.child("Users").child(uid!).observe(.value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
            print(self.user.displayName)
            print(self.user.photoUrl)
            print(self.user.followingIDs)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPost(){
        refHandle = ref.child("Posts").observe(.childAdded, with: {(snapshot) in
            let post = Post(post: snapshot)
            
            // Append post only if the post is by the user and the user followed
            
            if self.uid! == post.authorImageID || self.user.followingIDs.contains(post.authorImageID) {
                self.posts.append(post)
                print("Post Count \(self.posts.count)")
                DispatchQueue.main.async {
                    self.homeCollectionView.reloadData()
                }
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func commandAction(sender: UIButton){
        let post = posts[sender.tag]
        var followerDictionary = [String:Any]()
        var followingDictionary = [String:Any]()
        if sender.titleLabel?.text == "Follow" {
            followingDictionary["following"] = ["\(post.authorImageID)":true]
            ref.child("Users").child(uid!).updateChildValues(followingDictionary)
            followerDictionary["followers"] = ["\(uid!)":true]
            ref.child("Users").child(post.authorImageID).updateChildValues(followerDictionary)
            sender.setTitle("Unfollow", for: .normal)
        } else if sender.titleLabel?.text == "Unfollow" {
            ref.child("Users").child(uid!).child("following").child(post.authorImageID).removeValue()
            ref.child("Users").child(post.authorImageID).child("followers").child(uid!).removeValue()
            sender.setTitle("Follow", for: .normal)
        } else {
            ref.child("Posts").child(post.postKey).updateChildValues(["finished":true])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "HomeFeedCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeFeedCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HomeFeedCell.")
        }
        let post = posts[indexPath.row]
        cell.followBtn.layer.cornerRadius = 10
        let separator: UIView = UIView(frame: CGRect(x: cell.rootDescription.frame.minX, y: cell.rootDescription.frame.maxY, width: cell.rootDescription.frame.size.width, height: 1))
        separator.backgroundColor = UIColor.lightGray
        
        
        cell.authorDisplayName.text = post.authorDisplayName
        cell.commandButton.tag = indexPath.row
        cell.commandButton.addTarget(self, action: #selector(self.commandAction), for: .touchUpInside)
        if post.authorImageID == uid {
            cell.commandButton.setTitle("End Vote", for: .normal)
        } else if user.followingIDs.contains(post.authorImageID){
            cell.commandButton.setTitle("Unfollow", for: .normal)
        }

        cell.authorImageView.layer.cornerRadius = cell.authorImageView.frame.size.width / 2
        
        cell.authorImageView.sd_setImage(with: URL(string: post.authorImageUrl))
        let frameType = post.frameType
        
        let (imageStack , label , caption) = returnHomeCellStackView(post: post, frameType: frameType, width: cell.rootView.frame.size.width, height: cell.rootView.frame.size.height , descriptionWidth: cell.rootDescription.frame.size.width , captionHeight: cell.rootCaption.frame.size.height,descriptionHeight: cell.rootDescription.frame.size.height)
        
        // Add the view in the root stack view
        
        if cell.rootView.subviews.count == 0 {
            cell.rootView.addSubview(imageStack)
            
            
            let leading = NSLayoutConstraint(item: imageStack, attribute: .right, relatedBy: .equal, toItem: cell.rootView, attribute: .right, multiplier: 1.0, constant: 0)
            let trailing = NSLayoutConstraint(item: imageStack, attribute: .left, relatedBy: .equal, toItem: cell.rootView, attribute: .left, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: imageStack, attribute: .top, relatedBy: .equal, toItem: cell.rootView, attribute: .top, multiplier: 1.0, constant: 0)
            let bottom = NSLayoutConstraint(item: imageStack, attribute: .bottom, relatedBy: .equal, toItem: cell.rootView, attribute: .bottom, multiplier: 1.0, constant: 0)
            
            cell.rootView.addConstraints([leading, trailing, top, bottom])
            
            print(cell.rootView.frame.size.width)
        }
        
        if cell.rootDescription.subviews.count == 0 {
            cell.rootDescription.addSubview(separator)
            for lbl in label {
                cell.rootDescription.addArrangedSubview(lbl)
            }
        }
        if cell.rootCaption.subviews.count == 0 {
            cell.rootCaption.addArrangedSubview(caption)
        }
        return cell
    }
    
    func returnCountOfFrames(frameType: String) -> Int {
        var count = 0
        if frameType == "TWO_HORIZONTAL" || frameType == "THREE_HORIZONTAL" {
            count = 2
            if frameType == "THREE_HORIZONTAL" {
                count = 3
            }
        } else if frameType == "TWO_VERTICAL" || frameType == "THREE_VERTICAL" {
            count = 2
            if frameType == "THREE_VERTICAL" {
                count = 3
            }
        } else if frameType == "FOUR_CROSS" {
            count = 4
        }
        return count
    }
    
    func returnHomeCellStackView(post: Post , frameType: String , width: CGFloat , height: CGFloat , descriptionWidth: CGFloat , captionHeight: CGFloat , descriptionHeight: CGFloat ) -> (UIStackView,[UILabel],UITextView) {
        
        // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        // Array of Label
        
        var labelViews = [UILabel]()
        
        
        
       // var label = UILabel(frame: CGRect(x: 0, y: 0, width: descriptionWidth, height:descriptionHeight))
        
        var label = UILabel()
        
     //   var textView = UITextView(frame: CGRect(x: 0, y: 0, width: descriptionWidth, height: captionHeight))
        
        var textView = UITextView()
        
        textView.text = "\(post.postDescription)"
        
        // Count for the image view objects to be instantiated
        
        var count = returnCountOfFrames(frameType: frameType)
        
        label.numberOfLines = count
        
        let returnStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: width , height: height))
        returnStackView.translatesAutoresizingMaskIntoConstraints = false
        returnStackView.distribution = .fillEqually
        
        print(returnStackView.frame.size.width)
        
        if frameType == "TWO_HORIZONTAL" || frameType == "THREE_HORIZONTAL" {
            returnStackView.axis = .horizontal
        } else if frameType == "TWO_VERTICAL" || frameType == "THREE_VERTICAL" {
            returnStackView.axis = .vertical
        } else if frameType == "FOUR_CROSS" {
            returnStackView.axis = .vertical
        }
        
        for i in 0..<count {
            
            let labelView = UILabel(frame: CGRect(x: 0, y: 0, width: descriptionWidth, height: 10))
            labelView.font = UIFont.systemFont(ofSize: 14)
            labelViews.append(labelView)
            
            
            let imgView = UIImageView()
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            imgView.isUserInteractionEnabled = true
            imgView.accessibilityLabel = "\(post.frameImagesIDS[i]),\(post.postKey),\(post.authorImageID),\(post.frameType)"
            imgView.tag = i
            
            
            let voteView = UIView(frame: CGRect(x: 5, y: 5 , width: 80, height: 30))
            voteView.backgroundColor = UIColor.darkGray
            voteView.tag = 0
            voteView.layer.cornerRadius = 16
            voteView.alpha = 0.7
            
            
            let voteLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 90, height: 20))
            if post.authorImageID == uid! {
                refVotePostHandle = ref.child("Vote_Post").child(post.frameImagesIDS[i]).observe(.value, with: {(snapshot) in
                    let voteCount = snapshot.childrenCount
                    voteLabel.text = "\(voteCount)"
                })
                
            } else {
                 refVotePostHandle = ref.child("Users").child(uid!).child("post_voted").observe(.value, with: {(snapshot) in
                    if snapshot.hasChild(post.postKey) {
                        var handle = self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observe(.value
                            , with: {(snapshot) in
                            let voteCount = snapshot.childrenCount
                            voteLabel.text = "\(voteCount)"
                        })
                    } else {
                        voteLabel.text = "?"
                    }
                })
                
            }
            voteLabel.font = UIFont(name: voteLabel.font.fontName, size: 12)
            voteLabel.textColor = UIColor.white
            
            
            imgView.addSubview(voteView)

            voteLabel.tag = 1

            voteView.addSubview(voteLabel)
            
            // Create an Long Tap Gesture Recognizer
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.voteImage(sender:)))
            
            // Add Gesture Recognizer
            
            imgView.addGestureRecognizer(tap)
            
            // Append image view to the array
            
            imageViews.append(imgView)
            
            print("Count of First Loop \(i)")
        }
        
        for i in 0..<post.frameImagesIDS.count {
            ref.child("Images").child(post.postKey).child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let postImage = PostImages(snap: snapshot)
                imageViews[i].sd_setImage(with: URL(string: postImage.imageUrl))
                labelViews[i].text = postImage.imageDescription
                print(labelViews[i].text)
            })
        }
        
        if count == 4 {
            
            let upper = UIStackView()
            let lower = UIStackView()
            
            upper.axis = .horizontal
            lower.axis = .horizontal
            
            upper.distribution = .fillEqually
            lower.distribution = .fillEqually
            
            upper.addArrangedSubview(imageViews[0])
            upper.addArrangedSubview(imageViews[1])
            lower.addArrangedSubview(imageViews[2])
            lower.addArrangedSubview(imageViews[3])
            
            returnStackView.addArrangedSubview(upper)
            returnStackView.addArrangedSubview(lower)
            
            
        } else {
            for i in 0..<imageViews.count {
                returnStackView.addArrangedSubview(imageViews[i])
            }
        }
        
        return (returnStackView , labelViews , textView)
    }
    
    
    
    func voteImage(sender: UITapGestureRecognizer){
        if let imageView = sender.view as? UIImageView {
            
            // Tag is Frame no of the image
            
            print(imageView.tag)
            
            // Accessibility Label is the image info
            // Contains image id , post id , author image id
            
            print(imageView.accessibilityLabel!)
            
            // Make an array of the label value
            
            let imageInfo = imageView.accessibilityLabel!.components(separatedBy: ",")
            
            let imageID = imageInfo[0]
            let postID = imageInfo[1]
            let voteUserID = imageInfo[2]
            let frameType = imageInfo[3]
            
//            // Check if post is already finished
//            
//            ref.child("Posts").child(postID).observeSingleEvent(of: .value, with: {(snapshot) in
//            
//                if snapshot.hasChild("finished") {
//                    self.showAlertController(message: "This post is already done", title: "Finished")
//                } else {
//                    
//                }
//            })
            
            // Check if user already voted
            
            self.ref.child("Users").child(self.uid!).child("post_voted").observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.hasChild(postID) {
                    self.showAlertController(message: "You already voted for this post.", title: "Done")
                }  else {
                    
                    // Create a Dictionary for votes node
                    
                    let voteDictionary = ["\(self.uid!)": true]
                    
                    // Insert to the database
                    
                    self.ref.child("Vote_Post").child(imageID).updateChildValues(voteDictionary)
                    
                    self.ref.child("Users").child(self.uid!).child("post_voted").updateChildValues(["\(postID)": true])
                    
                    self.refVotePostTwoHandle = self.ref.child("Vote_Post").child(imageID).observe(.value, with: {(snapshot) in
                        let voteCount = snapshot.childrenCount
                        let label = imageView.viewWithTag(1) as! UILabel
                        let voteString = "\(voteCount)"
                        label.text = voteString
                    })
                    
                }
            })
            
            let root: UIStackView
            
            if frameType.contains("TWO") || frameType.contains("THREE") {
                root = imageView.superview as! UIStackView
                print(String(describing: root))
                for imageViewHolder in root.subviews {
                    if imageViewHolder.tag != imageView.tag {
                        
                        let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
                        let imageID = imageInfo?[0]
                        
                        print(imageInfo!)
                        print(String(describing: imageViewHolder))
                        
                        self.refVotePostTwoHandle = self.ref.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
                            let voteCount = snapshot.childrenCount
                            let voteString = "\(voteCount)"
                            let rootImage = imageViewHolder as! UIImageView
                            let rootView = rootImage.viewWithTag(0) as! UIView
                            let label = rootView.viewWithTag(1) as! UILabel
                            label.text = voteString
                        })
                        
                    }
                }
            } else {
                root = imageView.superview?.superview as! UIStackView
                
                print(String(describing: root))
                
                for stackviews in root.subviews {
                    for imageViewHolder in stackviews.subviews {
                        if imageViewHolder.tag != imageView.tag {
                            let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
                            let imageID = imageInfo?[0]
                            
                            print(imageInfo!)
                            print(String(describing: imageViewHolder))
                            
                            self.refVotePostTwoHandle = self.ref.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
                                let voteCount = snapshot.childrenCount
                                let voteString = "\(voteCount)"
                                let rootImage = imageViewHolder as! UIImageView
                                let rootView = rootImage.viewWithTag(0) as! UIView
                                let label = rootView.viewWithTag(1) as! UILabel
                                label.text = voteString
                            })
                        }
                    }
                }
            }
        }
    }
    
    func showAlertController(message: String , title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
