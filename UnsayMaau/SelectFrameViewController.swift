//
//  SelectFrameViewController.swift
//  UnsayMaau
//
//  Created by Nexusbond on 15/06/2017.
//  Copyright © 2017 Nexusbond. All rights reserved.
//

import UIKit

class SelectFrameViewController: UIViewController {
    
    var typeOfFrame: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selectFirstFrame(_ sender: Any) {
        typeOfFrame = "TWO_HORIZONTAL"
        performSegue(withIdentifier: "goToFrames", sender: nil)
    }
    
    @IBAction func selectSecondFrame(_ sender: Any) {
        typeOfFrame = "FOUR_CROSS"
        performSegue(withIdentifier: "goToFrames", sender: nil)
    }
    
    @IBAction func selectThirdFrame(_ sender: Any) {
        typeOfFrame = "TWO_VERTICAL"
        performSegue(withIdentifier: "goToFrames", sender: nil)
    }
    
    @IBAction func selectFourthFrame(_ sender: Any) {
        typeOfFrame = "THREE_VERTICAL"
        performSegue(withIdentifier: "goToFrames", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goToFrames" {
            let sic = segue.destination as! SelectImageFromLibraryViewController
            sic.typeOfFrame = typeOfFrame
        }
    }
    

}
