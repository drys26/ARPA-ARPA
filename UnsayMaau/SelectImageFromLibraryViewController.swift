//
//  SelectImageFromLibraryViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 19/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit
import Firebase
import Photos

class SelectImageFromLibraryViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var collectionViewSelector: UICollectionView!
    @IBOutlet weak var rootStackView: UIStackView!
   
    
    //var passArrayDelegate: PassPostDelegate?
    
    var imageData: [Data] = []
    var imageDescription: [String] = []
    var imageViews: [UIImageView] = []
    var imageIDS: [String] = []
    var frames: [Int] = []
    var ref: DatabaseReference = Database.database().reference()
    var postID: String = ""
    var imageClickIndex: Int = 0
    
    var imageTapCount: Int!
    var userImageTapCount: Int = 0
    
    var imageArray = [UIImage]()
    
    var pickImageArray = [UIImage]()
    
    var typeOfFrame: String!
    
    var tappedImageViews = [UIImageView]()
    
    
    var isGroup: Bool!
    
    var group: Group!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        grabPhotos()
        print("grabPhotos")
        
        collectionViewSelector.dataSource = self
        collectionViewSelector.delegate = self
        

        frames = [1,2,3,4]
        
        print(imageTapCount)
        
        // set the root distribution
        
        rootStackView.distribution = .fillEqually
        
        // Set the Done Button in right bar button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(self.nextAction))
        
        switch typeOfFrame {
        case "TWO_HORIZONTAL":
            print("two_horizontal")
            twoHorizontalFrames()
            break
        case "FOUR_CROSS":
            print("four_cross")
            fourCrossFrames()
            break
        case "TWO_VERTICAL":
            twoVerticalFrames()
            break
        case "THREE_VERTICAL":
            threeVerticalFrames()
            break
        case "THREE_HORIZONTAL":
            threeHorizontalFrames()
            break
        default:
            print("nothing")
            break
        }
        

        
        
    }
    
    func nextAction(){
        performSegue(withIdentifier: "goToNextPosting" , sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNextPosting" {
            let nextPhaseVC = segue.destination as! NextPhaseAddPostViewController
            nextPhaseVC.imageData = self.imageData
            nextPhaseVC.images = self.pickImageArray
            nextPhaseVC.typeOfFrame = self.typeOfFrame
            nextPhaseVC.isGroup = self.isGroup
            if isGroup == true {
                nextPhaseVC.group = self.group
            }
        }
    }
    
    func grabPhotos(){
        let imgManager = PHImageManager.default()
        print("imgManager")
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        print("requestOptions")
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        print("fetchOptions")
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult.count > 0 {
        
            for i in 0..<fetchResult.count{
                
                imgManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                    
                    self.imageArray.append(image!)
                    DispatchQueue.main.async {
                        self.collectionViewSelector.reloadData()
                    }
                })
                
            }
        
        }
        else{
            print("no image")
            collectionViewSelector.reloadData()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionViewSelector.frame.width / 3 - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.prepareForReuse()
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        let checkImageView = cell.viewWithTag(2) as! UIImageView
        
        checkImageView.isHidden = checkImageView.isHidden
        
        imageView.image = imageArray[indexPath.row]
        
        
        
        return cell
        
        
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Count how many taps the user has
        
        func action(){
            let cell = collectionView.cellForItem(at: indexPath)
            
            if cell?.viewWithTag(2)?.isHidden == true {
                cell?.viewWithTag(2)?.isHidden = false
            }
            //            else {
            //                cell?.viewWithTag(2)?.isHidden = true
            //            }
            
            if userImageTapCount != tappedImageViews.count {
                
                var i = userImageTapCount
                
                if i != 0 {
                    i -= 1
                }
                
                
                tappedImageViews[0].isHidden = true
                print("Hide image view \(0)")
                self.tappedImageViews.remove(at: 0)
                self.imageData.remove(at: 0)
                self.pickImageArray.remove(at: 0)
                print("is hidded tapped imageViews \(userImageTapCount)")
            }
            
            
            userImageTapCount += 1
            
            let imageView = cell?.viewWithTag(1) as! UIImageView
            
            let checkView = cell?.viewWithTag(2) as! UIImageView
            
            tappedImageViews.append(checkView)
            
            imageViews[userImageTapCount - 1].image = imageView.image
            imageViews[userImageTapCount - 1].contentMode = .scaleAspectFill
            
            var imageData = UIImageJPEGRepresentation(imageView.image!, 0.2)
            
            self.imageData.append(imageData!)
            
            self.pickImageArray.append(imageView.image!)
            
            print("user image tap count \(userImageTapCount)")
            
            print(" tapped image views count \(tappedImageViews.count)")
            
            print(" image data count \(self.imageData.count)")
        }
        
        if userImageTapCount != imageTapCount {
            action()
        } else {
            userImageTapCount = 0
            action()
        }
        
        
        
    }
    

    func twoHorizontalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "add_image"))
        let secondImageView = UIImageView(image: UIImage(named: "add_image"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        
    }
    
    func threeHorizontalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .horizontal
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "add_image"))
        let secondImageView = UIImageView(image: UIImage(named: "add_image"))
        let thirdImageView = UIImageView(image: UIImage(named: "add_image"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        rootStackView.addArrangedSubview(thirdImageView)
    }
    
    func twoVerticalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "add_image"))
        let secondImageView = UIImageView(image: UIImage(named: "add_image"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)

        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        
    }
    
    func threeVerticalFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "add_image"))
        let secondImageView = UIImageView(image: UIImage(named: "add_image"))
        let thirdImageView = UIImageView(image: UIImage(named: "add_image"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(firstImageView)
        rootStackView.addArrangedSubview(secondImageView)
        rootStackView.addArrangedSubview(thirdImageView)
    }
    
    func fourCrossFrames(){
        
        // Root Stack View Axis == .horizontal
        rootStackView.axis = .vertical
        
        // Create 2 Stackviews 
        
        let upper = UIStackView()
        let lower = UIStackView()
        
        // set the children stackviews properties
        
        upper.distribution = .fillEqually
        upper.axis = .horizontal
        
        lower.distribution = .fillEqually
        lower.axis = .horizontal
        
        
        // Create an UIImageView Object
        
        let firstImageView = UIImageView(image: UIImage(named: "add_image"))
        let secondImageView = UIImageView(image: UIImage(named: "add_image"))
        let thirdImageView = UIImageView(image: UIImage(named: "add_image"))
        let fourthImageView = UIImageView(image: UIImage(named: "add_image"))
        
        // Set the properties to clip to bounds and content mode
        
        firstImageView.contentMode = .scaleAspectFit
        secondImageView.contentMode = .scaleAspectFit
        thirdImageView.contentMode = .scaleAspectFit
        fourthImageView.contentMode = .scaleAspectFit
        
        firstImageView.clipsToBounds = true
        secondImageView.clipsToBounds = true
        thirdImageView.clipsToBounds = true
        fourthImageView.clipsToBounds = true
        
        // Add to the array of image views
        
        imageViews.append(firstImageView)
        imageViews.append(secondImageView)
        imageViews.append(thirdImageView)
        imageViews.append(fourthImageView)
        
        // add view to upper and lower stackviews
        
        upper.addArrangedSubview(firstImageView)
        upper.addArrangedSubview(secondImageView)
        
        lower.addArrangedSubview(thirdImageView)
        lower.addArrangedSubview(fourthImageView)
        
        // Add to the root stack view
        rootStackView.addArrangedSubview(upper)
        rootStackView.addArrangedSubview(lower)
        
        
    }
    
}
