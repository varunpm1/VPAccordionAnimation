//
//  AccordianAnimationViewController.swift
//  AccordianAnimation
//
//  Created by Varun on 28/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

class AccordianAnimationViewController: UIViewController, AccordianAnimationProtocol, UITableViewDelegate {
    
    // Expanded indexPath for storing the selected cell
    var expandedIndexPath : NSIndexPath?
    
    // Default value for animation
    var animationDuration: NSTimeInterval = 0.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// This method reinitializes arrow image position if needed. If arrow animation is needed and subclasses want this delegate method to be implemented, then subclasses has to call this method using super. Else animation won't work as needed
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // If the expandedIndexPath is the same as the cell's indexPath, then set the arrow image (if present) to final state, else in initial state
        if let cell = cell as? AccordianTableViewCell {
            if let arrowView = cell.arrowView {
                if expandedIndexPath == indexPath {
                    //FIXME: image name and direction
                    updateImageForView(arrowView, direction: .Right)
                }
                else {
                    updateImageForView(arrowView, direction: .Up)
                }
            }
        }
    }
    
    // Update the image view to reset the direction of arrowView
    private func updateImageForView(view : UIView, direction : UIImageOrientation) {
        var image : UIImage?
        
        // Get the current image from imageView or buttonView
        if let imageView = view as? UIImageView {
            image = imageView.image
        }
        else if let buttonView = view as? UIButton {
            image = buttonView.currentImage
        }
        
        if let image = image {
            // Reset the image based on the direction
            let cgiImage = UIImage(CGImage: image.CGImage!, scale: UIScreen.mainScreen().scale, orientation: direction)
            
            // Update the rotated image back to view
            if let imageView = view as? UIImageView {
                imageView.image = cgiImage
            }
            else if let buttonView = view as? UIButton {
                buttonView.setImage(cgiImage, forState: .Normal)
            }
        }
    }
}
