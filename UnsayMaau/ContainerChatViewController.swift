//
//  ContainerChatViewController.swift
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

class ContainerChatViewController: JSQMessagesViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate, JSQMessagesCollectionViewCellDelegate {
    
    // MARK: Properties
    var messages = [JSQMessage]()
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    private var newMessageRefHandle: DatabaseHandle?
    
    private var updatedMessageRefHandle: DatabaseHandle?
    
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://unsaymaau.appspot.com/")
    
    var uid: String = (Auth.auth().currentUser?.uid)!
    
    var isStarting: Bool = true
    
    var groupRef: DatabaseReference!
    var databaseRef: DatabaseReference!
    var group: Group! {
        didSet {
            title = group?.groupName
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreenImage" {
            if let photo = sender as? UIImage {
                let fullscreen = segue.destination as! FullScreenImageController
                fullscreen.photo = photo
                fullscreen.newSize = photo.size
            }
        }
    }
    
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell!) {
        print("tapped avatar")
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {
        print("tapped cell")
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell!) {
//        if let test = self.getImage(indexPath: IndexPath(row: cell.tag, section: 0) {
//            selectedImage = test
//            self.performSegue(withIdentifier: "showMedia", sender: self)
//        }
        
        print("\(IndexPath(row: cell.tag, section: 0))")
        
        let indexPath = IndexPath(row: cell.tag, section: 0)
        
        let message = self.messages[indexPath.row]
        
        if message.isMediaMessage {
            if let photo = message.media as? JSQPhotoMediaItem{
                print("tapped photo")
//                let photoMessage = self.photoMessageMap["photo_url"] as! String
//                print(photoMessage)
                print(photo.image)
                print(photo.image.size)
                self.performSegue(withIdentifier: "goToFullScreenImage", sender: photo.image)
                print("\(message.senderDisplayName)")
                
                
            }
            else if let video = message.media as? JSQVideoMediaItem{
                print("tapped video")
                
            }
            else if let audio = message.media as? JSQAudioMediaItem{
                print("tapped audio")
            }
        }
        else{
            print("tapped is text")
        }
        
        
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell!, didPerformAction action: Selector!, withSender sender: Any!) {
        
    }
    
    private var messageRef: DatabaseReference!
    
    private let imageURLNotSetKey = "NOTSET"
    
    private var usersTypingQuery: DatabaseQuery!
    
    private var userIsTypingRef: DatabaseReference!
    
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 0, height: 0)
        databaseRef = Database.database().reference()
        messageRef = self.databaseRef.child("Group_Messages").child(group.groupId)
        observeMessages()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        usersTypingQuery = group.groupRef.child("typing_indicator").queryOrderedByValue().queryEqual(toValue: true)
        userIsTypingRef = self.databaseRef.child("Groups").child(group.groupId).child("typing_indicator")
        observeTyping()
        print("View Will Appear")
    }
    
    // Helper methods to use outgoing or incoming bubble
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // Get the message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    // Count the messages to display
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    // For avatar images function
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        //return nil
        
        
        
        let placeHolderImage = UIImage(named:"no_image")
        //       let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "DL", backgroundColor: UIColor.jsq_messageBubbleGreen(), textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        let avatarImage = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeHolderImage)
        
        
        let message = messages[indexPath.item]
        
        
        if avatarImage?.avatarImage == nil {
            avatarImage?.avatarImage = SDImageCache.shared().imageFromDiskCache(forKey: message.senderId)
        }
        
        if let messageID = message.senderId {
            databaseRef.child("Users").child(messageID).observe(.value, with: { (snapshot) in
                if let profileURL = (snapshot.value as AnyObject!)!["photo_url"] as! String! {
                    let profileNSURL: NSURL = NSURL(string: profileURL)!
                    let manager: SDWebImageManager = SDWebImageManager.shared()
                    manager.imageDownloader?.downloadImage(with: profileNSURL as URL, options: [], progress: nil, completed: {(image , error , cached , url) in
                        if image != nil {
                            manager.imageCache?.store(image, forKey: message.senderId)
                            DispatchQueue.main.async{
                                avatarImage!.avatarImage = image
                                avatarImage!.avatarHighlightedImage = image
                            }
                        }
                        //avatarImage?.avatarImage = image
                    })
                }
            })
        }
        
        return avatarImage
        
    }
    
    // Setting the bubble if user or not
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2
        cell.avatarImageView.clipsToBounds = true
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
    
    // Add Messages
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    // Press Send Button
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "sender_id": senderId!,
            "sender_name": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        group.groupRef.updateChildValues(["timestamp": 0 - (NSDate().timeIntervalSince1970 * 1000)])
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        
        isTyping = false
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }

    
    private func observeMessages() {
        
        //messageRef = groupRef!.child("messages")
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            
            if let id = messageData["sender_id"] as String!, let name = messageData["sender_name"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                // 5
                self.finishReceivingMessage()
            }  else if let id = messageData["sender_id"] as String!,
                let photoURL = messageData["photo_url"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                   //  4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        if self.isStarting != true {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
        }
        self.isStarting = false
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photo_url"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photo_url": imageURLNotSetKey,
            "sender_id": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(Auth.auth().currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photo_url": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            // 3
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                // 4
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.sd_animatedGIF(with: data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = group!.groupRef.child("typing_indicator")

        //typingIndicatorRef?.child(senderId).setValue(isTyping)
        
        userIsTypingRef = typingIndicatorRef.child(senderId)
        
        userIsTypingRef.setValue(isTyping)
        
        // 1
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    // If Deinitialized
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
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
