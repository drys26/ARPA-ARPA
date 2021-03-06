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
    
    var refHandle: DatabaseHandle!
    
    var refUserHandle: DatabaseHandle!
    
    var refVotePostHandle: DatabaseHandle?
    
    var refVotePostTwoHandle: DatabaseHandle?
    
    var uid = Auth.auth().currentUser?.uid
    
    var user: User!
    
    var refresher:UIRefreshControl!
    
    var isStarting = false


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("View will appear ")
        // Set the Database Reference
//        if ref != nil {
//            getUserPost()
//        }
        
        if ref == nil {
            ref = Database.database().reference()
            getUserData()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        print("View Did Disapper")
        ref.removeObserver(withHandle: refUserHandle)
        if let refHandle1 = refHandle {
            ref.removeObserver(withHandle: refHandle1)
        }
        if let refVoteTemp = refVotePostHandle {
            ref.removeObserver(withHandle: refVoteTemp)
        }
        if let refVoteTemp2 = refVotePostTwoHandle {
            ref.removeObserver(withHandle: refVoteTemp2)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresher.addTarget(self, action: #selector(self.showPost), for: .valueChanged)
        
        
        if #available(iOS 10.0, *){
            homeCollectionView.refreshControl = refresher
        }else{
            
            homeCollectionView.addSubview(refresher)
        }
        
        // Set the Delegates of the collection to self
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        self.view.accessibilityIdentifier = "root_view"

    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let postDesc = posts[indexPath.item].postDescription
        
        let approxHeight = NSString(string: postDesc).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
        
        print("\(approxHeight.height)")
        
        let knownHeight = 48 + 8 + 200 + 8 + 84 + approxHeight.height + 30 + 24 + 24
        
        
        return CGSize(width: view.frame.size.width - 20, height: knownHeight)
        
    }
    
    
    
    
    
    
    func reloadData(){
        homeCollectionView.reloadData()
    }
    
    
    func observeNotifications(){
        ref.child("Users_Groups").child(self.user.userId).child("Pending_Groups").observe(.value, with: { (snapshot) in
//            self.tabBarController?.tabBar.items?[4].badgeValue = "\(snapshot.childrenCount.hashValue)"
//            self.navigationController?.tabBarController?.tabBar.items?[4].badgeValue = "\(snapshot.childrenCount.hashValue)"
            
        })
    }

    
    func getUserData(){
        refUserHandle = ref.child("Users").child(uid!).observe(.value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            if self.isStarting == false {
                self.isStarting = true
                DispatchQueue.main.async {
                    self.showPost()
                  //  self.observeNotifications()
                }
            }
            
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showPost(){
//        let postRef = ref.child("Posts").qu
        ref.child("Posts").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: {(snapshot) in
            //print(snapshot)
            
            if let rootPosts = snapshot.children.allObjects as? [DataSnapshot] {
                for rootPost in rootPosts {
                    
                    let post = Post(post: rootPost)
                    
                    print(post.postKey)

                    
                    if self.posts.contains(post) && post.postTimeCreated != self.posts[self.posts.index(of: post)!].postTimeCreated {
                        
                        let index = self.posts.index(of: post)!
                        self.posts.remove(at: index)
                        self.posts.insert(post, at: 0)
                    }
                    
                    if (self.posts.contains(post) && post.postIsFinished == true) || !self.user.followingIDs.contains(post.authorImageID) {
                        if let index = self.posts.index(of: post) {
                            self.posts.remove(at: index)
                            DispatchQueue.main.async {
                                self.homeCollectionView.reloadData()
                            }
                        }
                    }
                    
                    if (self.uid! == post.authorImageID || self.user.followingIDs.contains(post.authorImageID)) && !self.posts.contains(post) && post.postIsFinished == false {
                        self.posts.append(post)
                        DispatchQueue.main.async {
                            self.homeCollectionView.reloadData()
                        }
                    }
                    
                    
                    
                    
                }
            }
        })
        refresher.endRefreshing()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func commandAction(sender: UIButton){
        let post = posts[sender.tag]
        var followerDictionary = [String:Any]()
        var followingDictionary = [String:Any]()
        if sender.titleLabel?.text == "Follow" {
            ref.child("Users").child(uid!).child("following").updateChildValues(["\(post.authorImageID)":true])
            ref.child("Users").child(post.authorImageID).child("followers").updateChildValues([uid!:true])
            sender.setTitle("Unfollow", for: .normal)
        } else if sender.titleLabel?.text == "Unfollow" {
            ref.child("Users").child(uid!).child("following").child(post.authorImageID).removeValue()
            ref.child("Users").child(post.authorImageID).child("followers").child(uid!).removeValue()
            sender.setTitle("Follow", for: .normal)
        } else if sender.titleLabel?.text == "End Vote" {
            ref.child("Posts").child(post.postKey).updateChildValues(["finished":true])
            sender.setTitle("Finished", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "HomeFeedCell"
        print("cellForItemAt")
        
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeFeedCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HomeFeedCell.")
        }
        let post = posts[indexPath.row]
        
        cell.commandButton.layer.cornerRadius = 10
        
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
        
//        let estimatedHeight = cell.rootView.frame.height + cell.rootDescriptionCaption.frame.height + cell.userInfoRootView.frame.height + 8 + 8 + 20
//        
//        cell.frame.size = CGSize(width: view.frame.width - 20, height: estimatedHeight)
        
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
    
//    func returnSizeForCell(collection: UICollectionView,indexPath: IndexPath) -> CGFloat {
//        
//        let cell = homeCollectionView.cellForItem(at: indexPath)
//        
//        let height = 200 + cell.userInfoRootView.frame.size.height + cell.rootDescriptionCaption.frame.size.height + 16 + 20
//        
//        print(height)
//        
//        return height
//        
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCommentView" {
            if let post = sender as? Post {
                let root = segue.destination as! UINavigationController
                let scvc = root.viewControllers.first as! ShowCommentViewController
                scvc.post = post
                scvc.isGroupComment = false
            }
        }
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
    
    func returnHomeCellStackView(post: Post , frameType: String , width: CGFloat , height: CGFloat , labelWidth: CGFloat) -> (UIStackView,[UILabel],UITextView) {
        
        // (UIStackView,[UILabel],UITextView)
        // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        // Array of Label
        
        var labelViews = [UILabel]()
        
        
        
        // var label = UILabel(frame: CGRect(x: 0, y: 0, width: descriptionWidth, height:descriptionHeight))
        
        //   var textView = UITextView(frame: CGRect(x: 0, y: 0, width: descriptionWidth, height: captionHeight))
        
        // Count for the image view objects to be instantiated
        
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
//        let initializeLabelQ = DispatchQueue(label: "initializeQ", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//        
//        initializeLabelQ.async {
        
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
            if post.authorImageID == self.uid! {
                self.refVotePostHandle = self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observe(.value, with: {(snapshot) in
                    let voteCount = snapshot.childrenCount
                    if arrOfVotes.count == 1 {
                        max = arrOfVotes[0]
                        index = i
                    }
                    arrOfVotes.append(voteCount.hashValue)
                    
                    if arrOfVotes[i] > max {
                        max = arrOfVotes[i]
                        let attribText = NSMutableAttributedString(string: "  \(max)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
                        
                        let imageAttach = NSTextAttachment()
                        imageAttach.image = UIImage(named: "crown.png")
                        
                        let attribImage = NSAttributedString(attachment: imageAttach)
                        
                        let combi = NSMutableAttributedString()
                        combi.append(attribImage)
                        combi.append(attribText)
                        
                        voteLabel.attributedText = combi
                    } else {
                        voteLabel.text = "\(voteCount)"
                    }
                    
                })
            } else {
                self.ref.child("Users").child(self.uid!).child("post_voted").observeSingleEvent(of:.value, with: {(snapshot) in
                    if snapshot.hasChild(post.postKey) {
                        var handle = self.ref.child("Vote_Post").child(post.frameImagesIDS[i]).observeSingleEvent(of: .value
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
//        }
    
        
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
        
        
        
        //(returnStackView , labelViews , textView)
        return (returnStackView , labelViews , textView)
    }
    
    func voteImage(sender: UITapGestureRecognizer) {
        
        if let imageView = sender.view as? UIImageView {
            
            // Tag is Frame no of the image
            
//            print(imageView.tag)
            
            // Accessibility Label is the image info
            // Contains image id , post id , author image id
            
//            print(imageView.accessibilityLabel!)
            
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
                    
                    refVote.child("Users").child(self.uid!).child("post_voted").observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.hasChild(postID) {
                            self.showAlertController(message: "You already voted for this post.", title: "Done")
                        }  else {
                            
                            // Create a Dictionary for votes node
                            //
                            let voteDictionary = ["\(self.uid!)": true]
                            
                            var max = 0
                            var arrOfVotes = [Int]()
                            
                            // Insert to the database
                            
                            let timestamp = NSDate().timeIntervalSince1970 * 1000
                            
                            refVote.child("Posts").child(postID).updateChildValues(["timestamp":0 - timestamp])
                            
                            refVote.child("Vote_Post").child(imageID).updateChildValues(voteDictionary)
                            
                            refVote.child("Users").child(self.uid!).child("post_voted").updateChildValues(["\(postID)": "\(imageView.tag + 1)"])
                            
                            refVote.child("Vote_Post").child(imageID).observeSingleEvent(of: .value, with: {(snapshot) in
                                let voteCount = snapshot.childrenCount
                                let rootView = imageView.viewWithTag(0) as! UIView
                                let label = rootView.viewWithTag(1) as! UILabel

                                label.text = "\(voteCount)"
                                

                                
                                arrOfVotes.append(voteCount.hashValue)
                                
                            })
                            refVote.removeAllObservers()
                            
                            let root: UIStackView
                            
                            
                            
                            if frameType.contains("TWO") || frameType.contains("THREE") {
                                root = imageView.superview as! UIStackView
//                                print(String(describing: root))
                                for imageViewHolder in root.subviews {
                                    //let imageViewHolder = root.subviews[i] as! UIImageView
                                    if imageViewHolder.tag != imageView.tag {
                                        
                                        
                                        let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
                                        let imageID = imageInfo?[0]
                                        
//                                        print(imageInfo!)
//                                        print(String(describing: imageViewHolder))
                                        
                                        
                                        
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
                                            
                                                label.text = voteString
                                            //}
                                        })
                                        
                                    }
                                }
                            } else {
                                root = imageView.superview?.superview as! UIStackView
                                
//                                print(String(describing: root))
                                
                                for stackviews in root.subviews {
                                    for imageViewHolder in stackviews.subviews {
                                        if imageViewHolder.tag != imageView.tag {
                                            let imageInfo = imageViewHolder.accessibilityLabel?.components(separatedBy: ",")
                                            let imageID = imageInfo?[0]
                                            
//                                            print(imageInfo!)
//                                            print(String(describing: imageViewHolder))
                                            
                                            refVote.child("Vote_Post").child(imageID!).observe(.value, with: {(snapshot) in
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
                    })
                    
                    
                }
                
            })
            
            
        }
    }
    
    func showAlertController(message: String , title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }

}

