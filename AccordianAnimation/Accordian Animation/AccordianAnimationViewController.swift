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
    var expandedIndexPathsData : [NSIndexPath : UIView] = [:]
    
    // Default value for animation
    var animationDuration: NSTimeInterval = 0.4
    
    // Default value for disabling multiple expanding of cells
    var allowMultipleCellExpansion: Bool = false
    
    // Default value for disabling scrolling when expanded
    var allowTableViewScrollingWhenExpanded: Bool = true
    
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
                if isIndexPathExpanded(indexPath) {
                    // Set required direction for the selected indexPath
                    cell.updateImageForView(arrowView, currentDirection: cell.arrowImageFinalDirection)
                    
                    // Add the view back if needed. When scrolling is enabled
                    cell.detailsView.addSubview(expandedIndexPathsData[indexPath]!)
                    addFourSidedConstraintForView(expandedIndexPathsData[indexPath]!, withSuperView: cell.detailsView)
                }
                else {
                    // Set "Up" direction to reset the image's default position
                    cell.updateImageForView(arrowView, currentDirection: cell.arrowImageInitialDirection)
                }
            }
        }
    }
    
    /// Helper method for addding four sided constraints for necessary view w.r.t to super view
    func addFourSidedConstraintForView(view : UIView, withSuperView superView : UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        superView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    /// Check if indexPath is already expanded or not
    func isIndexPathExpanded(indexPath : NSIndexPath) -> Bool {
        return expandedIndexPathsData.keys.contains(indexPath)
    }
}
