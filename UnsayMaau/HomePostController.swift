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

class HomePostController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    var posts = [Post]()
    
    
    // Firebase reference
    
    var ref: DatabaseReference!
    
    // Firebase Handle
    
    var refHandle: UInt!
    
    var refUserHandle: UInt!
    
    var refVotePostHandle: UInt!
    
    var refVotePostTwoHandle: UInt!
    
    var uid = Auth.auth().currentUser?.uid
    
    var user: User!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear ")
        // Set the Database Reference
        
        ref = Database.database().reference()
        getUserData()
        showPost()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("View Did Disapper")
        ref.removeObserver(withHandle: refUserHandle)
        ref.removeObserver(withHandle: refHandle)
        ref.removeObserver(withHandle: refVotePostHandle)
        ref.removeObserver(withHandle: refVotePostTwoHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates of the collection to self
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        self.view.accessibilityIdentifier = "root_view"
        
        
        
        
        
        
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
        } else {
            ref.child("Users").child(uid!).child("following").child(post.authorImageID).removeValue()
            ref.child("Users").child(post.authorImageID).child("followers").child(uid!).removeValue()
            sender.setTitle("Follow", for: .normal)
        }
    }
    
    func isFollowed(post: Post) -> Bool {
        
        return true
    }
    
    func countVotes(imageID: String) -> Int {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "HomeFeedCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeFeedCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HomeFeedCell.")
        }
        let post = posts[indexPath.row]
        
        cell.authorDisplayName.text = post.authorDisplayName
        cell.commandButton.tag = indexPath.row
        cell.commandButton.addTarget(self, action: #selector(self.commandAction), for: .touchUpInside)
        if post.authorImageID == uid {
            cell.commandButton.setTitle("End Vote", for: .normal)
        } else if user.followingIDs.contains(post.authorImageID){
            cell.commandButton.setTitle("Unfollow", for: .normal)
        }
        cell.authorImageView.sd_setImage(with: URL(string: post.authorImageUrl))
        let frameType = post.frameType
        
        // Add the view in the root stack view
        
        if cell.rootView.subviews.count == 0 {
            cell.rootView.addSubview(returnHomeCellStackView(post: post, frameType: frameType, width: cell.rootView.frame.size.width, height: cell.rootView.frame.size.height))
        }
        return cell
    }
    
    
    
    
    func returnHomeCellStackView(post: Post , frameType: String , width: CGFloat , height: CGFloat ) -> UIStackView {
        
        
        // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        // Count for the image view objects to be instantiated
        
        var count = 0
        
        var returnStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: width , height: height))
        
        returnStackView.distribution = .fillEqually
        
        if frameType == "TWO_HORIZONTAL" || frameType == "THREE_HORIZONTAL" {
            returnStackView.axis = .horizontal
            count = 2
            if frameType == "THREE_HORIZONTAL" {
                count = 3
            }
        } else if frameType == "TWO_VERTICAL" || frameType == "THREE_VERTICAL" {
            returnStackView.axis = .vertical
            count = 2
            if frameType == "THREE_VERTICAL" {
                count = 3
            }
        } else if frameType == "FOUR_CROSS" {
            returnStackView.axis = .vertical
            count = 4
        }
        
        for i in 0..<count {
            let imgView = UIImageView()
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            imgView.isUserInteractionEnabled = true
            imgView.accessibilityLabel = "\(post.frameImagesIDS[i]),\(post.postKey),\(post.authorImageID),\(post.frameType)"
            imgView.tag = i
            let voteView = UIView(frame: CGRect(x: 10, y: imgView.frame.maxY, width: 80, height: 30))
            voteView.backgroundColor = UIColor.darkGray
            voteView.tag = 0
            voteView.layer.cornerRadius = 16
            voteView.alpha = 0.7
            imgView.addSubview(voteView)
            
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
                print("\(i)  \(postImage.imageUrl)")
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
        //
        //        returnStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the tag of the root stack view
        
        //returnStackView.tag = 10
        
        return returnStackView
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
            
            
            
            // Check if user already voted
            
            ref.child("Users").child(uid!).child("post_voted").observeSingleEvent(of: .value, with: {(snapshot) in
                
                if snapshot.hasChild(postID) {
                    self.showAlertController(message: "You already voted for this post.", title: "Done")
                } else {
                    
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
//                        let postID = imageInfo?[1]
//                        let voteUserID = imageInfo?[2]
//                        let frameType = imageInfo?[3]
                        
                        print(imageInfo!)
                        print(String(describing: imageViewHolder))
                        
                        refVotePostTwoHandle = ref.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
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
                            
                            refVotePostTwoHandle = ref.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
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
                
//                for imageViewHolder in root.subviews {
//                    if imageViewHolder.tag != imageView.tag {
//
//                        let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
//                        let imageID = imageInfo?[0]
//                        
//                        print(imageInfo!)
//                        print(String(describing: imageViewHolder))
//                        
//                        refVote.child("Vote_Post").child(imageID!).observeSingleEvent(of: .value, with: {(snapshot) in
//                            let voteCount = snapshot.childrenCount
//                            let voteString = "\(voteCount)"
//                            let rootImage = imageViewHolder as! UIImageView
//                            let rootView = rootImage.viewWithTag(0) as! UIView
//                            let label = rootView.viewWithTag(1) as! UILabel
//                            label.text = voteString
//                        })
//                        refVote.removeAllObservers()
//                    }
//                }
            }
        }
    }
    
    func updateImageViewsWithVotes(frameType: String,currentImageViewTag: Int){
        print(frameType)
        print(currentImageViewTag)
        
        
        //        if frameType.contains("TWO") {
        //
        //            let refVote = Database.database().reference()
        //            for imageViewHolder in imageViewsArr.subviews as! [UIImageView] {
        //                if imageViewHolder.tag != currentImageViewTag {
        //
        //                    let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
        //
        //                    let imageID = imageInfo?[0]
        //                    let postID = imageInfo?[1]
        //                    let voteUserID = imageInfo?[2]
        //                    let frameType = imageInfo?[3]
        //                    let postTag = Int((imageInfo?[4])!)
        //
        //                    refVote.child("Vote_Post").child(imageID!).observeSingleEvent(of: .value, with: {(snapshot) in
        //                        let voteCount = snapshot.childrenCount
        //                        let label = imageViewHolder.viewWithTag(1) as! UILabel
        //                        let voteString = "\(voteCount)"
        //                        label.text = voteString
        //                    })
        //                    refVote.removeAllObservers()
        //                }
        //            }
        //        }
    }
    
    func showAlertController(message: String , title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
