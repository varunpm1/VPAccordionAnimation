//
//  AccordianAnimationProtocol.swift
//  AccordianAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

typealias AccordianAnimationCompletionBlock = (() -> ())

@objc protocol AccordianAnimationProtocol : class {
    /// Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing
    var selectedIndexPath : NSIndexPath? {get set}
    
    /// Data source for expanded cell height
    var expandedCellHeight : CGFloat {get set}
    
    /// Data source for collapsed cell height
    var unexpandedCellHeight : CGFloat {get set}
    
    /// Defines the animation duration to be used for expanding or collapsing. Defaults to 0.4
    optional var animationDuration : NSTimeInterval {get set}
}

extension AccordianAnimationProtocol where Self : UIViewController {
    //MARK: Public functions
    /// Animate the showing of view controller with an expanding animation inside a tableView
    func showViewController(viewController : UIViewController, inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) {
        // If any cell is expanded, then collapse it first
        if let selectedIndexPath = selectedIndexPath {
            self.hideViewController(inTableView: tableView, forIndexPath: selectedIndexPath, callBack: {
                // After hiding all other cells, expand the current cell
                self.showViewController(viewController, tableView: tableView, indexPath: indexPath, callBack: callBack)
            })
        }
        else {
            // If no cell is expanded, then simply expand the cell
            self.showViewController(viewController, tableView: tableView, indexPath: indexPath, callBack: callBack)
        }
    }
    
    /// Animate the collapsing of view controller with collapsing animation inside a tableView
    func hideViewController(inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) {
        // If the previous selectedIndexPath and indexPath are same, then collpase the cell.
        if let selectedIndexPath = selectedIndexPath {
            // Remove all unnecessary data
            self.selectedIndexPath = nil
            tableView.scrollEnabled = true
            
            // Take the necessary screenshot to make the UI ready for aniamtion
            let animationBlock = createScreenshotUI(tableView, indexPath: selectedIndexPath, callBack: callBack)
            
            if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? AccrodianTableViewCell {
                // Remove the view that was added as a subView
                for subview in cell.detailsView.subviews {
                    subview.removeFromSuperview()
                }
                
                // Remove the view controller that was added as a child view controller
                self.childViewControllers.last!.removeFromParentViewController()
                
                // Reload the tableView content
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                
                // Animate the collapsing of tableView
                animationBlock()
            }
        }
    }
    
    //MARK: Private helper functions
    private func showViewController(viewController : UIViewController, tableView : UITableView, indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) {
        // Since expanding, set the necessary variables
        self.selectedIndexPath = indexPath
        tableView.scrollEnabled = false
        
        // Add the view controller as a child view controller
        self.addChildViewController(viewController)
        
        // Take the necessary screenshot to make the UI ready for aniamtion
        let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
        
        // Reload the tableView content
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        // Get the new instance of the cell at the selectedIndexPath
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccrodianTableViewCell {
            // Add the view controller's view as a subview to details view
            cell.detailsView.addSubview(viewController.view)
            
            // Add necessary constraints
            addFourSidedConstraintForView(viewController.view, withSuperView: cell.detailsView)
            
            // Animate the expanding of tableView
            animationBlock()
        }
    }
    
    /// Get the screenshot based on the rect size and origin.
    private func getScreenShot(aView : UIScrollView, forRect rect : CGRect) -> UIImage {
        // Preserve the previous frame and contentOffset of the scrollView (tableView)
        let frame = aView.frame
        let offset = aView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        
        // Move the frame for the screenshot starting position
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), rect.origin.x, -rect.origin.y);
        
        // Set the new frame for the view. An extra height is added for scrolling purpose. i.e., if bottom image is scrolled upwards, then empty image is seen and vice-versa
        aView.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height + rect.origin.y)
        aView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Reset the previous frame and contentOffset
        aView.frame = frame
        aView.contentOffset = offset
        
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
    
    /// Take the necessary screenshot to make the UI ready for aniamtion
    private func createScreenshotUI(tableView : UITableView, indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) -> AccordianAnimationCompletionBlock {
        // Get the frame of the selectedIndexPath and the current contentOffset
        let rect = tableView.rectForRowAtIndexPath(indexPath)
        let offset = tableView.contentOffset.y
        
        // Create the necessary frame for top and bottom image size
        let topImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect) - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let bottomImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect), width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        
        // Create the top and bottom screenshot for showing the animation
        let topImage = self.getScreenShot(tableView, forRect: topImageRect)
        let bottomImage = self.getScreenShot(tableView, forRect: bottomImageRect)
        
        // Create the top and bottom image views for showing the animation
        let topImageView = UIImageView(image: topImage)
        let topOffSet = topImageRect.origin.y - tableView.contentOffset.y
        topImageView.frame = CGRect(x: topImageRect.origin.x, y: topOffSet, width: topImageRect.size.width, height: topImageRect.size.height)
        
        let bottomImageView = UIImageView(image: bottomImage)
        let bottomOffSet = bottomImageRect.origin.y - tableView.contentOffset.y
        bottomImageView.frame = CGRect(x: bottomImageRect.origin.x, y: bottomOffSet, width: bottomImageRect.size.width, height: bottomImageRect.size.height)
        
        // Add the image views on top of self
        self.view.addSubview(topImageView)
        self.view.addSubview(bottomImageView)
        
        var animationDuration = self.animationDuration
        if animationDuration == nil {
            animationDuration = 0.4
        }
        
        let callBack = {
            // Animate the expansion/collapsing of table cells
            UIView.animateWithDuration(animationDuration!, animations: {
                // Scroll the tableView to middle if needed
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
                
                // Get the new frame for the selected indexPath
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                
                // Calculate the frame change of tableView
                let offsetChange = offset - tableView.contentOffset.y
                
                // Set the topImageView and bottomImageView frame
                topImageView.frame.origin.y += offsetChange
                bottomImageView.frame.origin.y = CGRectGetMaxY(rect) - tableView.contentOffset.y
                
                }, completion: { (isSuccess) in
                    // On completion, remove the imageViews
                    topImageView.removeFromSuperview()
                    bottomImageView.removeFromSuperview()
                    
                    // On successful animation, call callBack to indicate the animation completion
                    if let callBack = callBack {
                        callBack()
                    }
            })
        }
        
        return callBack
    }
}