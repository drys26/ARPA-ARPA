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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates of the collection to self
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        // Set the Database Reference
        
        ref = Database.database().reference()
        showPost()
        
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "HomeFeedCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HomeFeedCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HomeFeedCell.")
        }
        let post = posts[indexPath.row]
        
        cell.authorDisplayName.text = post.authorDisplayName
        cell.commandButton.setTitle("Follow", for: .normal)
        cell.authorImageView.sd_setImage(with: URL(string: post.authorImageUrl))
        let frameType = post.frameType
        
        // Add the view in the root stack view
        
        if cell.rootView.subviews.count == 0 {
            cell.rootView.addSubview(returnHomeCellStackView(post: post, frameType: frameType, width: cell.rootView.frame.size.width, height: cell.rootView.frame.size.height))
        }
        return cell
    }
    
    func twoHorizontalFrames(post: Post) -> UIStackView {
        
        var returnStackView = UIStackView()
        
        returnStackView.distribution = .fillEqually
        returnStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView()
        let secondImageView = UIImageView()
        
         // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        
        // Array of PostImages 
        
        var postImages = [PostImages]()
        
        for i in 0..<post.frameImagesIDS.count {
            ref.child("Images").child(post.postKey).child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let postImage = PostImages(snap: snapshot)
                imageViews[i].sd_setImage(with: URL(string: postImage.imageUrl))
                postImages.append(postImage)
            })
            print(postImages.count)
        }
        
        
        returnStackView.addArrangedSubview(imageViews[0])
        returnStackView.addArrangedSubview(imageViews[1])
        
        return returnStackView
    }
    
    func threeHorizontalFrames(post: Post) -> UIStackView {
        
        var returnStackView = UIStackView()
        
        
        returnStackView.distribution = .fillEqually
        returnStackView.axis = .horizontal
        
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView()
        let secondImageView = UIImageView()
        let thirdImageView = UIImageView()
        
        var imageViews = [UIImageView]()
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        
        
        
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        
        // Array of PostImages
        
        var postImages = [PostImages]()
        
        for i in 0..<post.frameImagesIDS.count {
            ref.child("Images").child(post.postKey).child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let postImage = PostImages(snap: snapshot)
                imageViews[i].sd_setImage(with: URL(string: postImage.imageUrl))
                postImages.append(postImage)
            })
            print("Print Post Images \(postImages.count)")
        }
        
        returnStackView.addArrangedSubview(imageViews[0])
        returnStackView.addArrangedSubview(imageViews[1])
        returnStackView.addArrangedSubview(imageViews[2])
        
        
        return returnStackView
    }
    
    func twoVerticalFrames(post: Post) -> UIStackView {
        
        var returnStackView = UIStackView()
        
        returnStackView.distribution = .fillEqually
        returnStackView.axis = .vertical
        
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView()
        let secondImageView = UIImageView()
        
        // Array of Image Views
        
        var imageViews = [UIImageView]()
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        
        // Array of PostImages
        
        var postImages = [PostImages]()
        
        for i in 0..<post.frameImagesIDS.count {
            ref.child("Images").child(post.postKey).child(post.frameImagesIDS[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                let postImage = PostImages(snap: snapshot)
                imageViews[i].sd_setImage(with: URL(string: postImage.imageUrl))
                postImages.append(postImage)
            })
            print(postImages.count)
        }
        
        returnStackView.addArrangedSubview(imageViews[0])
        returnStackView.addArrangedSubview(imageViews[1])
        
        
        return returnStackView
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
            
            let voteView = UIView(frame: CGRect(x: 10, y: imgView.frame.maxY, width: 80, height: 30))
            voteView.backgroundColor = UIColor.darkGray
            voteView.layer.cornerRadius = 16
            voteView.alpha = 0.7
            imgView.addSubview(voteView)
            
            let voteLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 90, height: 20))
            voteLabel.text = "10,000"
            voteLabel.font = UIFont(name: voteLabel.font.fontName, size: 12)
            
            voteView.addSubview(voteLabel)
            
            
            
            
            // Create an Long Tap Gesture Recognizer
            
            let tap = UITapGestureRecognizer()
            
            switch i {
            case 0:
                tap.addTarget(self, action: #selector(self.voteFrame1))
                break
            case 1:
                tap.addTarget(self, action: #selector(self.voteFrame2))
                break
            case 2:
                tap.addTarget(self, action: #selector(self.voteFrame3))
                break
            case 3:
                tap.addTarget(self, action: #selector(self.voteFrame4))
                break
            default:
                print("No Target")
                break
            }
            
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
    
    
    func voteFrame1() {
        voteImage(frameNo: 1)
    }
    func voteFrame2() {
        voteImage(frameNo: 2)
    }
    func voteFrame3() {
        voteImage(frameNo: 3)
    }
    func voteFrame4() {
        voteImage(frameNo: 4)
    }
    
    func voteImage(frameNo: Int){
        print(frameNo)
    }
    
    
    
    

}
