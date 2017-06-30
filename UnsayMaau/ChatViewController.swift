//
//  ChatViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 29/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import SDWebImage
import Photos

class ChatViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    var name: String?
    
    var userUID = Auth.auth().currentUser?.uid
    
    var group: Group!
    
    private lazy var containerChatView: ContainerChatViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ContainerChatView") as! ContainerChatViewController
        
//        viewController.senderDisplayName = "Sample"
//        viewController.senderId = self.userUID
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    // MARK: Properties
//    var messages = [JSQMessage]()
//    private var photoMessageMap = [String: JSQPhotoMediaItem]()
//    
//    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
//    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
//    
//    var groupRef: DatabaseReference!
//    var databaseRef: DatabaseReference!
////    var group: Group? {
////        didSet {
////            title = group?.groupName
////        }
////    }
//    
//    
//
//    // Helper methods to use outgoing or incoming bubble
//    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
//        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//    }
//    
//    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
//        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("View Did Appear")
//       // observeTyping()
//    }
//    
//    // Get the message
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
//        return messages[indexPath.item]
//    }
//    // Count the messages to display
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    
//    // For avatar images function
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        return nil
//    }
//    
//    // Setting the bubble if user or not
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
//        let message = messages[indexPath.item] // 1
//        if message.senderId == senderId { // 2
//            return outgoingBubbleImageView
//        } else { // 3
//            return incomingBubbleImageView
//        }
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        let message = messages[indexPath.item]
//        
//        if message.senderId == senderId {
//            cell.textView?.textColor = UIColor.white
//        } else {
//            cell.textView?.textColor = UIColor.black
//        }
//        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2
//        cell.avatarImageView.clipsToBounds = true
//        return cell
//    }
//    
//    private func addMessage(withId id: String, name: String, text: String) {
//        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
//            messages.append(message)
//        }
//    }
    
//    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        let itemRef = messageRef.childByAutoId() // 1
//        let messageItem = [ // 2
//            "senderId": senderId!,
//            "senderName": senderDisplayName!,
//            "text": text!,
//            ]
//        
//        itemRef.setValue(messageItem) // 3
//        
//        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
//        
//        finishSendingMessage() // 5
//        
//        isTyping = false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        
        //add(asChildViewController: containerChatView)

        // Do any additional setup after loading the view.
//        print(senderDisplayName)
//        print(senderId)
       // print(name!)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToContainerChatView" {
            let ccvc = segue.destination as! ContainerChatViewController
            ccvc.senderDisplayName = "Sample Name"
            ccvc.senderId = self.userUID
            ccvc.group = group
            ccvc.groupRef = group.groupRef
        }
    }
    

}
