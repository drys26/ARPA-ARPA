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
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    
    var uid = Auth.auth().currentUser?.uid
    
    var user: User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates of the collection to self
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        // Set the Database Reference
        
        ref = Database.database().reference()
        showPost()
        getUserData()
    }
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
            print(self.user.displayName)
            print(self.user.photoUrl)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPost(){
        refHandle = ref.child("Posts").observe(.childAdded, with: {(snapshot) in
            let post = Post(post: snapshot)
            self.posts.append(post)
            print("Post Count \(self.posts.count)")
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("View Did Disapper")
        ref.removeObserver(withHandle: refHandle)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func commandAction(sender: UIButton){
        let post = posts[sender.tag]
        var followerDictionary = [String:Any]()
        var followingDictionary = [String:Any]()
        if sender.titleLabel?.text == "Follow" {
            followingDictionary["following"] = ["\(post.authorImageID)":["user_info":"\(post.authorDisplayName),\(post.authorEmailAddress),\(post.authorImageUrl)"]]
            ref.child("Users").child(uid!).updateChildValues(followingDictionary)
            followerDictionary["followers"] = ["\(uid!)":["user_info":"\(user.displayName),\(user.email),\(user.photoUrl)"]]
            ref.child("Users").child(post.authorImageID).updateChildValues(followerDictionary)
            sender.setTitle("Unfollow", for: .normal)
        } else {
            ref.child("Users").child(uid!).child("following").child(post.authorImageID).removeValue()
            ref.child("Users").child(post.authorImageID).child("followers").child(uid!).removeValue()
            sender.setTitle("Follow", for: .normal)
        }
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
        } else {
            cell.commandButton.setTitle("Follow", for: .normal)
        }
        
        cell.authorImageView.sd_setImage(with: URL(string: post.authorImageUrl))
        let frameType = post.frameType
        
        // Add the view in the root stack view
        
        if cell.rootView.subviews.count == 0 {
            cell.rootView.addSubview(returnHomeCellStackView(post: post, frameType: frameType, width: cell.rootView.frame.size.width, height: cell.rootView.frame.size.height))
        }
        return cell
    }
    
    
    
    
    func returnHomeCellStackView(post: Post , frameType: String , width: CGFloat , height: CGFloat) -> UIStackView {
        
        
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
            imgView.accessibilityLabel = "\(post.frameImagesIDS[i]),\(post.postKey),\(post.authorImageID)"
            imgView.tag = i
            let voteView = UIView(frame: CGRect(x: 10, y: imgView.frame.maxY, width: 80, height: 30))
            voteView.backgroundColor = UIColor.darkGray
            voteView.layer.cornerRadius = 16
            voteView.alpha = 0.7
            imgView.addSubview(voteView)
            
            let voteLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 90, height: 20))
            voteLabel.text = "?"
            voteLabel.font = UIFont(name: voteLabel.font.fontName, size: 12)
            
            voteView.addSubview(voteLabel)
            
            // Create an Long Tap Gesture Recognizer
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.voteImage(sender:)))
            
            
            
            
            
//            switch i {
//            case 0:
//                tap.addTarget(self, action: #selector(self.voteFrame1))
//                break
//            case 1:
//                tap.addTarget(self, action: #selector(self.voteFrame2))
//                break
//            case 2:
//                tap.addTarget(self, action: #selector(self.voteFrame3))
//                break
//            case 3:
//                tap.addTarget(self, action: #selector(self.voteFrame4))
//                break
//            default:
//                print("No Target")
//                break
//            }
            
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
            
            // Create a Dictionary for votes node
            
            let voteDictionary = ["\(voteUserID)": true]
            
            // insert to the database
            
            ref.child("Vote_Post").child(imageID).setValue(voteDictionary)
        }
    }
    
    
    
    

}
