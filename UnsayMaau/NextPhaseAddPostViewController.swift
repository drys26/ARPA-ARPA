//
//  NextPhaseAddPostViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 04/07/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase

class NextPhaseAddPostViewController: UIViewController {
    
    @IBOutlet weak var rootImageStackView: UIStackView!
    @IBOutlet weak var rootTextFieldsStackView: UIStackView!
    
    @IBOutlet weak var statusSegmentControl: UISegmentedControl!
    
    
    var imageData: [Data] = []
    
    var images: [UIImage] = []
    
    var imageViews: [UIImageView] = []
    
    var textfieldDescriptions: [UITextField] = []
    
    var imageIDS: [String] = []
    
    var typeOfFrame: String!
    
    var ref: DatabaseReference!
    
    var postID: String = ""
    
    var user: User!
    
    var uid = Auth.auth().currentUser?.uid
    
    var frames: [Int] = []
    
    var postsDictionary = [String:Any]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        frames = [1,2,3,4]
        
        switch typeOfFrame {
        case "TWO_HORIZONTAL":
            print("two_horizontal")
            rootImageStackView.axis = .horizontal
            setupStackViews(count: 2)
            break
        case "FOUR_CROSS":
            rootImageStackView.axis = .vertical
            print("four_cross")
            fourCrossFrames()
            break
        case "TWO_VERTICAL":
            rootImageStackView.axis = .vertical
            setupStackViews(count: 2)
            break
        case "THREE_VERTICAL":
            rootImageStackView.axis = .vertical
            setupStackViews(count: 3)
            break
        case "THREE_HORIZONTAL":
            rootImageStackView.axis = .horizontal
            setupStackViews(count: 3)
            break
        default:
            print("nothing")
            break
        }
        
        ref = Database.database().reference()
        
        getUserData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.postAction))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateArray(count: Int) {
        for i in 0..<count {
            imageIDS.append(ref.childByAutoId().key)
        }
    }
    
    func getUserData(){
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            self.user = User(snap: snapshot)
            //this code is just to show the UserClass was populated.
            print(self.user.email)
        })
    }

    
    func postAction() {
        print("Post Action")
        
        postID = ref.child("Posts").childByAutoId().key
        
        var status: Bool!
        
        if statusSegmentControl.selectedSegmentIndex == 0 {
            status = false
        } else {
            status = true
        }
        
        let postDescription = rootTextFieldsStackView.subviews.last as! UITextView
        
        if typeOfFrame == "TWO_VERTICAL" || typeOfFrame == "TWO_HORIZONTAL" {
            populateArray(count: 2)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"post_description":postDescription.text,"frame_type":typeOfFrame,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        } else if typeOfFrame == "FOUR_CROSS" {
            populateArray(count: 4)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"frame_three": imageIDS[2],"frame_four":imageIDS[3],"post_description":postDescription.text,"frame_type":typeOfFrame ,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        } else if typeOfFrame == "THREE_VERTICAL" || typeOfFrame == "THREE_HORIZONTAL" {
            populateArray(count: 3)
            postsDictionary = ["frame_one": imageIDS[0],"frame_two": imageIDS[1],"frame_three": imageIDS[2],"post_description":postDescription.text,"frame_type":typeOfFrame ,"author_info": "\(user.displayName),\(user.email),\(user.photoUrl),\(uid!)","private_status":status] as [String : Any]
        }
        postsDictionary["timestamp"] = 0 - (NSDate().timeIntervalSince1970 * 1000)
        postsDictionary["finished"] = false
        
        uploadImage(datas: imageData)
    }
    
    func uploadImage(datas: [Data]) {
        
        var stopper = 0
        
        if typeOfFrame == "TWO_VERTICAL" || typeOfFrame == "TWO_HORIZONTAL" {
            stopper = 1
        } else if typeOfFrame == "THREE_VERTICAL" || typeOfFrame == "THREE_HORIZONTAL" {
            stopper = 2
        } else if typeOfFrame == "FOUR_CROSS" {
            stopper = 3
        }
        
        for i in 0...stopper {
            let storageRef = Storage.storage().reference(withPath: "Post_Images/\(imageIDS[i])")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "images/jpeg"
//            print("Image Data \(imageData.count)")
//            print("Image Description \(imageDescription.count)")
//            print("Image Frames \(frames.count)")
            print(i)
            let uploadTask = storageRef.putData(imageData[i], metadata: uploadMetaData, completion: { (metadata,error) in
                if(error != nil){
                    print("I received an error! \(error?.localizedDescription ?? "null")")
                } else {
                    let downloadUrl = metadata!.downloadURL()?.absoluteString
                    print("Upload complete! Heres some metadata!! \(String(describing: metadata))")
                    print("Here's your download url \(downloadUrl!)")
                    let imageDescription = self.textfieldDescriptions[i] as! UITextField
                    let imageDict = ["image_url": downloadUrl!,"image_description": imageDescription.text!,"frame_no": self.frames[i]] as [String : Any]
                    self.updateImagesDictionary(count: i,temporaryImagesDictionary: imageDict)
                }
            })
        }
        // End Adding Post
        navigationController?.popToRootViewController(animated: true)
    }
    
    func updateImagesDictionary(count: Int, temporaryImagesDictionary: [String : Any]) {
        ref.child("Images").child(postID).child(imageIDS[count]).setValue(temporaryImagesDictionary)
        ref.child("Images").child(postID).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount.hashValue == self.imageIDS.count {
                self.ref.child("Posts").child(self.postID).setValue(self.postsDictionary)
                self.ref.child("Users_Posts").child(self.user.userId).updateChildValues([self.postID:true])
            }
            print(snapshot.childrenCount)
            print(snapshot.children.allObjects.count)
            print(snapshot.childrenCount.hashValue)
        })
    }
    
    
    func setupStackViews(count: Int){
    
        for i in 0..<count {
            let imageView = UIImageView(image: images[i])
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageViews.append(imageView)
            rootImageStackView.addArrangedSubview(imageView)
            
            let textfield = UITextField()
            textfield.borderStyle = .roundedRect
            
            textfield.placeholder = "Enter image \(i + 1) description"
            
            textfieldDescriptions.append(textfield)
            
            rootTextFieldsStackView.addArrangedSubview(textfield)
        }
        
        rootTextFieldsStackView.addArrangedSubview(returnTextView())
        
    }
    
    func returnTextView() -> UITextView {
        
        let postTextField = UITextView(frame: CGRect(x: 0, y: 0, width: rootTextFieldsStackView.frame.size.width, height: 30))
        
        postTextField.layer.borderWidth = 0.5
        postTextField.layer.borderColor = UIColor.blue.cgColor
        postTextField.isScrollEnabled = false
        
        postTextField.sizeToFit()
        postTextField.layoutIfNeeded()
        let height = postTextField.sizeThatFits(CGSize(width: postTextField.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        postTextField.contentSize.height = height
        
        return postTextField
    }
    
    func fourCrossFrames(){
        
        // Root Stack View Axis == .horizontal
       // rootImageStackView.axis = .vertical
        
        // Create 2 Stackviews
        
        let upper = UIStackView()
        let lower = UIStackView()
        
        // set the children stackviews properties
        
        upper.distribution = .fillEqually
        upper.axis = .horizontal
        
        lower.distribution = .fillEqually
        lower.axis = .horizontal
        
        for i in 0..<4 {
            let imageView = UIImageView(image: images[i])
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageViews.append(imageView)
            rootImageStackView.addArrangedSubview(imageView)
            
            let textfield = UITextField()
            textfield.borderStyle = .roundedRect
            
            textfield.placeholder = "Enter image \(i + 1) description"
            
            textfieldDescriptions.append(textfield)
            
            rootTextFieldsStackView.addArrangedSubview(textfield)
        }
        
        
        rootTextFieldsStackView.addArrangedSubview(returnTextView())
        
//        // Create an UIImageView Object
//        
//        let firstImageView = UIImageView(image: images[0])
//        let secondImageView = UIImageView(image: images[1])
//        let thirdImageView = UIImageView(image: images[2])
//        let fourthImageView = UIImageView(image: images[3])
//        
//        // Set the properties to clip to bounds and content mode
//        
//        firstImageView.contentMode = .scaleAspectFill
//        secondImageView.contentMode = .scaleAspectFill
//        thirdImageView.contentMode = .scaleAspectFill
//        fourthImageView.contentMode = .scaleAspectFill
//        
//        firstImageView.clipsToBounds = true
//        secondImageView.clipsToBounds = true
//        thirdImageView.clipsToBounds = true
//        fourthImageView.clipsToBounds = true
        
        // Add to the array of image views
        
//        imageViews.append(firstImageView)
//        imageViews.append(secondImageView)
//        imageViews.append(thirdImageView)
//        imageViews.append(fourthImageView)
        
        // add view to upper and lower stackviews
        
        upper.addArrangedSubview(imageViews[0])
        upper.addArrangedSubview(imageViews[1])
        
        lower.addArrangedSubview(imageViews[2])
        lower.addArrangedSubview(imageViews[3])
        
        // Add to the root stack view
        rootImageStackView.addArrangedSubview(upper)
        rootImageStackView.addArrangedSubview(lower)
        
        
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
