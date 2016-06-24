//
//  AccordianAnimationProtocol.swift
//  AccordianAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

private var topImageView : UIImageView?
private var bottomImageView : UIImageView?
private var topContentOffset : CGPoint?

protocol AccordianAnimationProtocol : class {
    // Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing
    var selectedIndexPath : NSIndexPath? {get set}
    var expandedCellHeight : CGFloat {get set}
    var unexpandedCellHeight : CGFloat {get set}
}

extension AccordianAnimationProtocol where Self : UIViewController {
    /// Animate the showing of view controller with an expanding and collapsing animation inside a tableView
    func showViewController(viewController : UIViewController, inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath) {
        // If the previous selectedIndexPath and indexPath are same, then collpase the cell. Else expand the cell
        if selectedIndexPath == indexPath {
            // Remove all unnecessary data
            self.selectedIndexPath = nil
            tableView.scrollEnabled = true
            
            if let topImageView = topImageView, bottomImageView = bottomImageView {
                self.view.addSubview(topImageView)
                self.view.addSubview(bottomImageView)
                
                UIView.animateWithDuration(1, animations: {
                    topImageView.frame.origin.y = 0
                    bottomImageView.frame.origin.y = topImageView.frame.size.height
                    }, completion: { (isSuccess) in
                        tableView.reloadData()
                        
                        if let topContentOffset = topContentOffset {
                            tableView.contentOffset = topContentOffset
                        }
                        
                        topImageView.removeFromSuperview()
                        bottomImageView.removeFromSuperview()
                })
            }
            
            topImageView = nil
            bottomImageView = nil
        }
        else {
            // If expanding, then disable scrolling and set the necessary variable
            selectedIndexPath = indexPath
            tableView.scrollEnabled = false
            topContentOffset = tableView.contentOffset
            
            // Add the view controller as a child view controller
            self.addChildViewController(viewController)
            
            if let _ = selectedIndexPath {
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                
                // Create the necessary frame for top and bottom image size
                let topImageRect = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.bounds.size.width, height: CGRectGetMaxY(rect))
                let bottomImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect), width: tableView.bounds.size.width, height: tableView.contentSize.height - CGRectGetMaxY(rect))
                
                // Create the top and bottom screenshot for showing the animation
                let topImage = self.getScreenShot(tableView, forRect: topImageRect)
                let bottomImage = self.getScreenShot(tableView, forRect: bottomImageRect)
                
                // Create the top and bottom image views for showing the animation
                topImageView = UIImageView(image: topImage)
                topImageView?.frame = topImageRect
                
                bottomImageView = UIImageView(image: bottomImage)
                bottomImageView?.frame = bottomImageRect
                
                // Add the image views on top of self
                self.view.addSubview(topImageView!)
                self.view.addSubview(bottomImageView!)
                
                // Reload the tableView and scroll the row to middle of the tableView, if needed
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
                
                // Get the new instance of the cell at the selectedIndexPath
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccrodianTableViewCell {
                    // Add the view controller's view as a subview to details view
                    cell.detailsView.addSubview(viewController.view)
                    
                    // Add necessary constraints
                    addFourSidedConstraintForView(viewController.view, withSuperView: cell.detailsView)
                    
                    // Animate the movement of image view to have an effect of table expanding
                    UIView.animateWithDuration(1, animations: {
                        // Set the top of image view to negative value to move it out of the screen
                        topImageView?.frame.origin.y = -(tableView.contentOffset.y)
                        
                        // Set the bottom of image view to positive value to move it out of the screen. Calculate the increase in cell height and move it w.r.t to rect of selectedIndexPath
                        bottomImageView?.frame.origin.y = (tableView.contentOffset.y + cell.bounds.size.height)
                        }, completion: { (isSuccess) in
                            topImageView?.removeFromSuperview()
                            bottomImageView?.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    /// Get the screenshot based on the rect size and origin. If origin is 0, then top screenshot is created. Else the bottom screenshot is created.
    private func getScreenShot(aView : UIView, forRect rect : CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -rect.origin.y);
        aView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// Helper method for addding four sided constraints for necessary view w.r.t to super view
    private func addFourSidedConstraintForView(view : UIView, withSuperView superView : UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        superView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}