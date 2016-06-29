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
    var expandedIndexPaths : [NSIndexPath] = []
    
    // Default value for animation
    var animationDuration: NSTimeInterval = 0.4
    
    // Default value for disabling multiple expanding of cells
    var allowMultipleCellExpansion: Bool = false
    
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
                if expandedIndexPaths.contains(indexPath) == true {
                    // Set required direction for the selected indexPath
                    cell.updateImageForView(arrowView, currentDirection: cell.arrowImageFinalDirection)
                }
                else {
                    // Set "Up" direction to reset the image's default position
                    cell.updateImageForView(arrowView, currentDirection: cell.arrowImageCurrentDirection)
                }
            }
        }
    }
}
