//
//  AccordianAnimationProtocol.swift
//  AccordianAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

typealias AccordianAnimationCompletionBlock = (() -> ())

protocol AccordianAnimationProtocol : class {
    /// Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing
    var expandedIndexPath : NSIndexPath? {get set}
    
    /// Defines the animation duration to be used for expanding or collapsing. Defaults to 0.4
    var animationDuration : NSTimeInterval {get set}
}

extension AccordianAnimationProtocol where Self : AccordianAnimationViewController {
    //MARK: Public functions
    /// Animate the showing of view controller with an expanding animation inside a tableView
    func showViewController(viewController : UIViewController, inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) {
        // If any cell is expanded, then collapse it first
        if let expandedIndexPath = expandedIndexPath {
            self.hideViewController(inTableView: tableView, forIndexPath: expandedIndexPath, callBack: {
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
        // If the previous expandedIndexPath and indexPath are same, then collpase the cell.
        if let expandedIndexPath = expandedIndexPath {
            // Remove all unnecessary data
            self.expandedIndexPath = nil
            tableView.scrollEnabled = true
            
            // Take the necessary screenshot to make the UI ready for aniamtion
            let animationBlock = createScreenshotUI(tableView, indexPath: expandedIndexPath, callBack: callBack)
            
            if let cell = tableView.cellForRowAtIndexPath(expandedIndexPath) as? AccordianTableViewCell {
                // Remove the view that was added as a subView
                for subview in cell.detailsView.subviews {
                    subview.removeFromSuperview()
                }
                
                // Remove the view controller that was added as a child view controller
                self.childViewControllers.last!.removeFromParentViewController()
                
                // Reload the tableView content
                tableView.reloadRowsAtIndexPaths([expandedIndexPath], withRowAnimation: .None)
                
                // Animate the collapsing of tableView
                animationBlock()
            }
        }
    }
}

private extension AccordianAnimationProtocol where Self : UIViewController {
    //MARK: Private helper functions
    func showViewController(viewController : UIViewController, tableView : UITableView, indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) {
        // Since expanding, set the necessary variables
        self.expandedIndexPath = indexPath
        tableView.scrollEnabled = false
        
        // Add the view controller as a child view controller
        self.addChildViewController(viewController)
        
        // Take the necessary screenshot to make the UI ready for aniamtion
        let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
        
        // Reload the tableView content
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        // Get the new instance of the cell at the expandedIndexPath
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccordianTableViewCell {
            // Add the view controller's view as a subview to details view
            cell.detailsView.addSubview(viewController.view)
            
            // Add necessary constraints
            addFourSidedConstraintForView(viewController.view, withSuperView: cell.detailsView)
            
            // Animate the expanding of tableView
            animationBlock()
        }
    }
    
    /// Get the screenshot based on the rect size and origin.
    func getScreenShot(aView : UIView, forRect rect : CGRect) -> UIImage {
        // Preserve the previous frame and contentOffset of the scrollView (tableView)
        let frame = aView.frame
        var offset : CGPoint?
        
        // Get offset only if view is scrollView
        if let aView = aView as? UIScrollView {
            offset = aView.contentOffset
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        
        // Move the frame for the screenshot starting position
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), rect.origin.x, -rect.origin.y);
        
        // Set the new contentOffset for the view only if it's a scrollView
        if let aView = aView as? UIScrollView {
            aView.contentOffset.y = rect.origin.y
        }
        
        aView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Reset the previous frame
        aView.frame = frame
        
        // Reset offset only if view is scrollView
        if let aView = aView as? UIScrollView {
            aView.contentOffset = offset!
        }
        
        return image
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
    
    /// Take the necessary screenshot to make the UI ready for aniamtion
    func createScreenshotUI(tableView : UITableView, indexPath : NSIndexPath, callBack : AccordianAnimationCompletionBlock?) -> AccordianAnimationCompletionBlock {
        // Get the frame of the expandedIndexPath and the current contentOffset
        let rect = tableView.rectForRowAtIndexPath(indexPath)
        let offset = tableView.contentOffset.y
        
        // A full table height is added for safety purpose. An extra height is added for scrolling purpose. i.e., if bottom image is scrolled upwards, then empty image will be seen and vice-versa. To avoid this, rendering remaining bottom/top view so that image will not be empty
        let topImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect) - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let bottomImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect), width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        
        // Get the instance of arrowView if animation needed for rotating the arrow
        var arrowView : UIView?
        
        // Bool for identifying whether cell is expanding or collapsing
        var isCollapsing = false
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccordianTableViewCell {
            if cell.arrowView != nil {
                // Get the screenshot of the arrowImage
                let arrowImage = getScreenShot(cell.arrowView, forRect: cell.arrowView.bounds)
                arrowView = UIImageView(image: arrowImage)
                arrowView?.frame = CGRect(x: cell.arrowView.frame.origin.x, y: rect.origin.y - CGRectGetMinY(topImageRect) + cell.arrowView.frame.origin.y, width: cell.arrowView.frame.size.width, height: cell.arrowView.frame.size.height)
                
                // Hide the arrow View before taking a screenshot. Unhide after animation
                cell.arrowView.hidden = true
                
                //FIXME: direction
                if (cell.arrowView as! UIImageView).image!.imageOrientation == .Right {
                    isCollapsing = true
                }
            }
        }
        
        // Create the top and bottom screenshot for showing the animation
        let topImageView = self.addScreenshotView(tableView, forFrame: topImageRect)
        let bottomImageView = self.addScreenshotView(tableView, forFrame: bottomImageRect)
        
        // Add the image views on top of self
        self.view.addSubview(topImageView)
        self.view.addSubview(bottomImageView)
        
        // Check if arrow view is added. If yes, then add it to the added screenshot
        if let arrowView = arrowView {
            topImageView.addSubview(arrowView)
        }
        
        let callBack = { [weak self] in
            if self == nil {
                return
            }
            
            // Animate the expansion/collapsing of table cells
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccordianTableViewCell {
                UIView.animateWithDuration(self!.animationDuration, animations: {
                    // Animate the rotation of the arrow view if outlet is set
                    if let arrowView = arrowView {
                        arrowView.transform = CGAffineTransformRotate(arrowView.transform, (isCollapsing ? -1 : 1) * self!.getRotationAngleForArrowForCell(cell))
                    }
                    
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
                        cell.arrowView?.hidden = false
                        arrowView = nil
                        
                        // On completion, remove the imageViews
                        topImageView.removeFromSuperview()
                        bottomImageView.removeFromSuperview()
                        
                        // On successful animation, call callBack to indicate the animation completion
                        if let callBack = callBack {
                            callBack()
                        }
                })
            }
        }
        
        return callBack
    }
    
    // Helper function to retreive the screenshot inside a imageView
    func addScreenshotView(tableView : UITableView, forFrame screenshotRect : CGRect) -> UIImageView {
        let screenshotImage = self.getScreenShot(tableView, forRect: screenshotRect)
        
        // Create the top and bottom image views for showing the animation
        let imageView = UIImageView(image: screenshotImage)
        let topOffSet = screenshotRect.origin.y - tableView.contentOffset.y
        imageView.frame = CGRect(x: screenshotRect.origin.x, y: topOffSet, width: screenshotRect.size.width, height: screenshotRect.size.height)
        
        return imageView
    }
    
    // Helper function for calcaulation the angle needed to rotate the arrow view
    func getRotationAngleForArrowForCell(cell : AccordianTableViewCell) -> CGFloat {
        let rotationConstant = cell.arrowImageFinalDirection.rawValue - cell.arrowImageCurrentDirection.rawValue
        
        return CGFloat(Double(rotationConstant) * M_PI_2)
    }
}