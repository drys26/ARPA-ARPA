 //
//  TopEyeViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 06/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase
 
 class TopEyeViewController: UIViewController , FeedProtocol , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    
    var user: User!

    
    //

    @IBOutlet weak var topTableView: UICollectionView!
    
    // Firebase Handle
    
    var refHandle: DatabaseHandle!
    
    var refUserHandle: DatabaseHandle!
    
    var refVotePostHandle: DatabaseHandle?
    
    var refVotePostTwoHandle: DatabaseHandle?
    
    var posts: [Post] = []
    var ref: DatabaseReference = Database.database().reference()
    var uid: String = (Auth.auth().currentUser?.uid)!
    var refresher: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        getUserData()
        
        refresher.addTarget(self, action: #selector(self.loadPostData), for: .valueChanged)
        
        if #available(iOS 10.0, *){
            topTableView.refreshControl = refresher
        }else{
            
            topTableView.addSubview(refresher)
        }
        
        
        
        DispatchQueue.main.async {
            self.loadPostData()
        }
        
        
        // Set the Delegates of the collection to self
        
        topTableView.delegate = self
        topTableView.dataSource = self
        
    }
    
    
    func reloadData() {
        DispatchQueue.main.async {
            self.topTableView.reloadData()
        }
    }
    
    func loadPostData() {
        
        var voteCount = [Int]()
        
        var tempPost = [Post]()
        
        var rootVoteCount = [[Int]]()
        
        ref.child("Posts").observeSingleEvent(of: .value, with: {(rootSnapshot) in
            //var max = 0
            var max = 0
            for rootPost in rootSnapshot.children.allObjects as! [DataSnapshot] {
                let post = Post(post: rootPost)
                if post.postStatus == false && post.authorImageID != self.uid && !self.posts.contains(post) {
                    rootVoteCount.append([Int]())
                    tempPost.append(post)
                    
                    let index: Int = tempPost.index(of: post)!

                    for i in 0..<post.frameImagesIDS.count {
                        self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                            let currentVoteCount = snapshot.childrenCount.hashValue
                            rootVoteCount[index].append(currentVoteCount)
                            if rootVoteCount[index].count == post.frameImagesIDS.count {
                                let currentCount = self.countArray(arr: rootVoteCount[index])
                                var comparerCount = 0
                                if index != 0 {
                                    let i = index - 1
                                    comparerCount = self.countArray(arr: rootVoteCount[i])
                                }
                                print("Max \(max)")
                                print("Comparer Count \(comparerCount)")
                                print("Current Count \(currentCount)")
                                print("Post name \(tempPost[index].postDescription)")
                                if !self.posts.contains(tempPost[index]) {
                                    if currentCount > max {
                                        max = currentCount
                                        print("currentCount >= max \(max)")
                                        self.posts.insert(tempPost[index], at: 0)
                                    } else if currentCount >= comparerCount {
                                        print("currentCount >= comparerCount")
                                        if self.posts.count > 1 {
                                            self.posts.insert(tempPost[index], at: 1)
                                        } else {
                                            self.posts.append(tempPost[index])
                                        }
                                        
                                    } else {
                                        print("append")
                                        self.posts.append(tempPost[index])
                                    }
                                    self.reloadData()
                                }
                            }
                            
                        })
                    }
                    
                    
                    
                }
                
            }
            
        })
        refresher.endRefreshing()
    }
    
    
    
    func countArray(arr: [Int]) -> Int{
        var temp = 0
        for i in arr {
            temp += i
        }
        return temp
    }
    
    func getUserData() {
        refUserHandle = ref.child("Users").child(uid).observe(.value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
            
        })
    }
    
    func commandAction(sender: UIButton) {
        let post = posts[sender.tag]
        var followerDictionary = [String:Any]()
        var followingDictionary = [String:Any]()
        if sender.titleLabel?.text == "Follow" {
            followingDictionary["following"] = ["\(post.authorImageID)":true]
            ref.child("Users").child(uid).updateChildValues(followingDictionary)
            followerDictionary["followers"] = [uid:true]
            ref.child("Users").child(post.authorImageID).updateChildValues(followerDictionary)
            sender.setTitle("Unfollow", for: .normal)
        } else if sender.titleLabel?.text == "Unfollow" {
            ref.child("Users").child(uid).child("following").child(post.authorImageID).removeValue()
            ref.child("Users").child(post.authorImageID).child("followers").child(uid).removeValue()
            sender.setTitle("Follow", for: .normal)
        } else if sender.titleLabel?.text == "End Vote" {
            ref.child("Posts").child(post.postKey).updateChildValues(["finished":true])
            sender.setTitle("Finished", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cellIdentifier = "HomeFeedCell"
        
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFeedCell", for: indexPath) as! HomeFeedCollectionViewCell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeFeedCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HomeFeedCell.")
        }
        
        let post = posts[indexPath.row]
        
        cell.commandButton.layer.cornerRadius = 10
        
        cell.authorDisplayName.text = post.authorDisplayName
        cell.commandButton.tag = indexPath.row
        cell.commandButton.addTarget(self, action: #selector(self.commandAction), for: .touchUpInside)
//        if post.authorImageID == uid {
//            cell.commandButton.setTitle("End Vote", for: .normal)
//        } else if user.followingIDs.contains(post.authorImageID){
//            cell.commandButton.setTitle("Unfollow", for: .normal)
//        }
        
        cell.commandButton.setTitle("Follow", for: .normal)
        
        cell.authorImageView.layer.cornerRadius = cell.authorImageView.frame.size.width / 2
        
        cell.authorImageView.sd_setImage(with: URL(string: post.authorImageUrl))
        let frameType = post.frameType
        
        let (imageStack , labels, textview) = returnHomeCellStackView(post: post, frameType: frameType, width: cell.rootView.frame.size.width , height: cell.rootView.frame.size.height,labelWidth: cell.rootDescriptionCaption.frame.size.width)
        
        // Add the view in the root stack view
        
        if cell.rootView.subviews.count == 0 {
            
            cell.rootView.addSubview(imageStack)
            
            let leading = NSLayoutConstraint(item: imageStack, attribute: .right, relatedBy: .equal, toItem: cell.rootView, attribute: .right, multiplier: 1.0, constant: 0)
            let trailing = NSLayoutConstraint(item: imageStack, attribute: .left, relatedBy: .equal, toItem: cell.rootView, attribute: .left, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: imageStack, attribute: .top, relatedBy: .equal, toItem: cell.rootView, attribute: .top, multiplier: 1.0, constant: 0)
            let bottom = NSLayoutConstraint(item: imageStack, attribute: .bottom, relatedBy: .equal, toItem: cell.rootView, attribute: .bottom, multiplier: 1.0, constant: 0)
            
            cell.rootView.addConstraints([leading, trailing, top, bottom])
            
        }
        if cell.rootDescriptionCaption.subviews.count == 0 {
            for i in 0..<labels.count {
                cell.rootDescriptionCaption.addArrangedSubview(labels[i])
                if i == labels.count - 1 {
                    cell.rootDescriptionCaption.addArrangedSubview(textview)
                }
            }
            let viewCommentButton = UIButton(type: .system)
            viewCommentButton.setTitle("View More Comments", for: .normal)
            viewCommentButton.tag = indexPath.row
            viewCommentButton.addTarget(self, action: #selector(self.viewCommentAction(sender:)), for: .touchUpInside)
            cell.rootDescriptionCaption.addArrangedSubview(viewCommentButton)
        }
        
        return cell
    }
    
    func viewCommentAction(sender: UIButton){
        let post = posts[sender.tag]
        getUserData()
        user.userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild("post_voted/\(post.postKey)") || post.authorImageID == self.user.userId {
                self.performSegue(withIdentifier: "goToCommentView", sender: post)
            } else {
                self.showAlertController(message: "You need to vote to comment.", title: "Vote First")
            }
        })
        
    }
    
    func showAlertController(message: String , title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
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
    
    
    // Size for cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 598)
    }
    
    // Count of Post
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func returnHomeCellStackView(post: Post , frameType: String , width: CGFloat , height: CGFloat , labelWidth: CGFloat) -> (UIStackView,[UILabel],UITextView) {
        // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        // Array of Label
        
        var labelViews = [UILabel]()
        
        var count = returnCountOfFrames(frameType: frameType)
        
        
        let returnStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: width , height: height))
        returnStackView.translatesAutoresizingMaskIntoConstraints = false
        returnStackView.distribution = .fillEqually
        
        if frameType == "TWO_HORIZONTAL" || frameType == "THREE_HORIZONTAL" {
            returnStackView.axis = .horizontal
        } else if frameType == "TWO_VERTICAL" || frameType == "THREE_VERTICAL" {
            returnStackView.axis = .vertical
        } else if frameType == "FOUR_CROSS" {
            returnStackView.axis = .vertical
        }
        
        var arrOfVotes: [Int] = [Int]()
        var max = 0
        var index = 0
        
        for i in 0..<count {
            
            let labelView = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 10))
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
            imgView.addSubview(voteView)
            
            
            
            let voteLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 90, height: 20))
            if post.authorImageID == self.uid {
                self.refVotePostHandle = self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observe(.value, with: {(snapshot) in
                    let voteCount = snapshot.childrenCount
//                    if arrOfVotes.count == 1 {
//                        max = arrOfVotes[0]
//                        index = i
//                    }
//                    arrOfVotes.append(voteCount.hashValue)
//                    
//                    if arrOfVotes[i] > max {
//                        max = arrOfVotes[i]
//                        let attribText = NSMutableAttributedString(string: "  \(max)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
//                        
//                        let imageAttach = NSTextAttachment()
//                        imageAttach.image = UIImage(named: "crown.png")
//                        
//                        let attribImage = NSAttributedString(attachment: imageAttach)
//                        
//                        let combi = NSMutableAttributedString()
//                        combi.append(attribImage)
//                        combi.append(attribText)
//                        
//                        voteLabel.attributedText = combi
//                    } else {
                    voteLabel.text = "\(voteCount)"
                    //}
                    
                })
            } else {
                self.ref.child("Users").child(self.uid).child("post_voted").observeSingleEvent(of:.value, with: {(snapshot) in
                    if snapshot.hasChild(post.postKey) {
                        var handle = self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observeSingleEvent(of: .value
                            , with: {(snapshot) in
                                let voteCount = snapshot.childrenCount
                                // arrOfVotes.append(voteCount.hashValue)
                                // voteLabel.text = "\(voteCount)"
                                //                                if arrOfVotes.count == 1 {
                                //                                    max = arrOfVotes[0]
                                //                                    index = i
                                //                                }
                                //                                arrOfVotes.append(voteCount.hashValue)
                                //
                                //                                if arrOfVotes[i] > max {
                                //                                    max = arrOfVotes[i]
                                //                                    let attribText = NSMutableAttributedString(string: "  \(max)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
                                //
                                //                                    let imageAttach = NSTextAttachment()
                                //                                    imageAttach.image = UIImage(named: "crown.png")
                                //
                                //                                    let attribImage = NSAttributedString(attachment: imageAttach)
                                //
                                //                                    let combi = NSMutableAttributedString()
                                //                                    combi.append(attribImage)
                                //                                    combi.append(attribText)
                                //
                                //                                    voteLabel.attributedText = combi
                                //                                } else {
                                voteLabel.text = "\(voteCount)"
                                //}
                        })
                    } else {
                        voteLabel.text = "?"
                    }
                })
            }
            voteLabel.font = UIFont(name: voteLabel.font.fontName, size: 12)
            voteLabel.textColor = UIColor.white
            //            imgView.addSubview(voteView)
            voteLabel.tag = 1
            voteView.addSubview(voteLabel)
            
            
            
            // Create an Long Tap Gesture Recognizer
            
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(self.voteImage(sender:)))
            
            // Add Gesture Recognizer
            
            imgView.addGestureRecognizer(tap)
            
            // Append image view to the array
            
            imageViews.append(imgView)
            
            //print(String(describing: imgView))
            
//            print("Count of First Loop \(i)")
        }
        
        for i in 0..<post.frameImagesIDS.count {
            ref.child("Images").child(post.postKey).child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let postImage = PostImages(snap: snapshot)
                imageViews[i].sd_setImage(with: URL(string: postImage.imageUrl))
                
                let myString = "\(i + 1) "
                let myString2 = "\(postImage.imageDescription)"
                let myAttrib = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)]
                
                let attribText = NSMutableAttributedString(string: myString, attributes: myAttrib)
                let attribText2 = NSMutableAttributedString(string: myString2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                
                let combi = NSMutableAttributedString()
                
                combi.append(attribText)
                combi.append(attribText2)
                
                labelViews[i].attributedText = combi
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
        
        let textView = UITextView()
        
        textView.text = post.postDescription
        
        textView.isScrollEnabled = false
        
        let separator: UIView = UIView(frame: CGRect(x: 0, y: labelViews[labelViews.count - 1].frame.maxY + 10, width: labelWidth, height: 1))
        separator.backgroundColor = UIColor.lightGray
        
        labelViews[labelViews.count - 1].addSubview(separator)
        
        
        //textView.addSubview(separator)
        
        //(returnStackView , labelViews , textView)
        return (returnStackView , labelViews , textView)
    }
    
    func voteImage(sender: UITapGestureRecognizer) {
        
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
            
            let refVote = Database.database().reference()
            
            // Check if post is already finished
            
            refVote.child("Posts").child(postID).observeSingleEvent(of: .value, with: {(snapshot) in
                
                let value = snapshot.value as! [String : Any]
                let finished = value["finished"] as! Bool
                if finished == true {
                    self.showAlertController(message: "This post is already done", title: "Finished")
                } else {
                    // Check if user already voted
                    
                    refVote.child("Users").child(self.uid).child("post_voted").observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.hasChild(postID) {
                            self.showAlertController(message: "You already voted for this post.", title: "Done")
                        }  else {
                            // Create a Dictionary for votes node
                            
                            //                    let voteDictionary = ["\(self.uid!)": true]
                            //
                            //                    // Insert to the database
                            //
                            //                    refVote.child("Vote_Post").child(imageID).updateChildValues(voteDictionary)
                            //
                            //                    refVote.child("Users").child(self.uid!).child("post_voted").updateChildValues(["\(postID)": true])
                            //
                            //                    refVote.child("Vote_Post").child(imageID).observe(.value, with: {(snapshot) in
                            //                        let voteCount = snapshot.childrenCount
                            //                        let label = imageView.viewWithTag(1) as! UILabel
                            //                        let voteString = "\(voteCount)"
                            //                        label.text = voteString
                            //                    })
                            
                            // Create a Dictionary for votes node
                            //
                            let voteDictionary = ["\(self.uid)": true]
                            
                            var max = 0
                            var arrOfVotes = [Int]()
                            
                            // Insert to the database
                            
                            let timestamp = NSDate().timeIntervalSince1970 * 1000
                            
                            refVote.child("Posts").child(postID).updateChildValues(["timestamp":0 - timestamp])
                            
                            refVote.child("Vote_Post").child(imageID).updateChildValues(voteDictionary)
                            
                            refVote.child("Users").child(self.uid).child("post_voted").updateChildValues(["\(postID)": "\(imageView.tag + 1)"])
                            
                            refVote.child("Vote_Post").child(imageID).observeSingleEvent(of: .value, with: {(snapshot) in
                                let voteCount = snapshot.childrenCount
                                let rootView = imageView.viewWithTag(0) as! UIView
                                let label = rootView.viewWithTag(1) as! UILabel
                                //
                                ////                                let attribText = NSMutableAttributedString(string: " \(voteCount)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
                                ////
                                ////                                let imageAttach = NSTextAttachment()
                                ////                                imageAttach.image = UIImage(named: "crown.png")
                                ////
                                ////                                let attribImage = NSAttributedString(attachment: imageAttach)
                                ////
                                ////                                let combi = NSMutableAttributedString()
                                ////                                combi.append(attribImage)
                                ////                                combi.append(attribText)
                                //
                                //                                //label.attributedText = combi
                                label.text = "\(voteCount)"
                                
                                //                                if frameType.contains("TWO") || frameType.contains("THREE") {
                                //                                    let label = imageView.viewWithTag(1) as! UILabel
                                //                                    label.text = "\(voteCount)"
                                //                                } else {
                                //                                    let rootImage = imageView.viewWithTag(1) as! UIImageView
                                //                                    let rootView = rootImage.viewWithTag(0) as! UIView
                                //                                    let label = rootView.viewWithTag(1) as! UILabel
                                //                                    label.text = "\(voteCount)"
                                //                                }
                                
                                arrOfVotes.append(voteCount.hashValue)
                                
                            })
                            refVote.removeAllObservers()
                            
                            let root: UIStackView
                            
                            
                            
                            if frameType.contains("TWO") || frameType.contains("THREE") {
                                root = imageView.superview as! UIStackView
                                print(String(describing: root))
                                for imageViewHolder in root.subviews {
                                    //let imageViewHolder = root.subviews[i] as! UIImageView
                                    if imageViewHolder.tag != imageView.tag {
                                        
                                        
                                        let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
                                        let imageID = imageInfo?[0]
                                        
                                        print(imageInfo!)
                                        print(String(describing: imageViewHolder))
                                        
                                        
                                        
                                        refVote.child("Vote_Post").child(imageID!).observeSingleEvent(of: .value, with: {(snapshot) in
                                            let voteCount = snapshot.childrenCount
                                            let voteString = "\(voteCount)"
                                            
                                            if arrOfVotes.count == 1 {
                                                max = arrOfVotes[0]
                                            }
                                            arrOfVotes.append(voteCount.hashValue)
                                            
                                            let index = root.subviews.index(of: imageViewHolder)
                                            
                                            let rootImage = imageViewHolder as! UIImageView
                                            let rootView = rootImage.viewWithTag(0) as! UIView
                                            let label = rootView.viewWithTag(1) as! UILabel
                                            
                                            //                                            if arrOfVotes[index!] > max {
                                            //                                                print(" arrvotes > max")
                                            //                                                max = arrOfVotes[index!]
                                            //                                                let attribText = NSMutableAttributedString(string: "  \(max)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
                                            //
                                            //                                                let imageAttach = NSTextAttachment()
                                            //                                                imageAttach.image = UIImage(named: "crown.png")
                                            //
                                            //                                                let attribImage = NSAttributedString(attachment: imageAttach)
                                            //
                                            //                                                let combi = NSMutableAttributedString()
                                            //                                                combi.append(attribImage)
                                            //                                                combi.append(attribText)
                                            //
                                            //                                                label.attributedText = combi
                                            //                                            } else {
                                            label.text = voteString
                                            //}
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
                                            
                                            refVote.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
                                                let voteCount = snapshot.childrenCount
                                                let voteString = "\(voteCount)"
                                                let rootImage = imageViewHolder as! UIImageView
                                                let rootView = rootImage.viewWithTag(0) as! UIView
                                                let label = rootView.viewWithTag(1) as! UILabel
                                                
                                                //                                                if arrOfVotes.count == 1 {
                                                //                                                    max = arrOfVotes[0]
                                                //                                                }
                                                //                                                arrOfVotes.append(voteCount.hashValue)
                                                //                                                let index = root.subviews.index(of: imageViewHolder)
                                                //
                                                //                                                if arrOfVotes[index! - 1] > max {
                                                //                                                    max = arrOfVotes[index! - 1]
                                                //                                                    let attribText = NSMutableAttributedString(string: "  \(max)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
                                                //                                                    
                                                //                                                    let imageAttach = NSTextAttachment()
                                                //                                                    imageAttach.image = UIImage(named: "crown.png")
                                                //                                                    
                                                //                                                    let attribImage = NSAttributedString(attachment: imageAttach)
                                                //                                                    
                                                //                                                    let combi = NSMutableAttributedString()
                                                //                                                    combi.append(attribImage)
                                                //                                                    combi.append(attribText)
                                                //                                                    
                                                //                                                    label.attributedText = combi
                                                //                                                } else {
                                                label.text = voteString
                                                //}
                                                
                                                //label.text = voteString
                                            })
                                        }
                                    }
                                }
                            }
                            
                        }
                    })
                    
                    
                }
                
            })
            
            
        }
    }
    

}
