//
//  VPAccordionAnimationProtocol.swift
//  VPAccordionAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 VPM. All rights reserved.
//

//  The MIT License (MIT)
//
//  Copyright (c) 2016 Varun P M
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

typealias VPAccordionAnimationCompletionBlock = (() -> ())

enum DefaultState {
    case ExpandedAll
    case CollapsedAll
}

enum ArrowRotation {
    case ClockWise
    case AntiClockWise
}

protocol VPAccordionAnimationProtocol : class {
    //MARK: Protocol Variables
    /// Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing. Each value will be expanded index path. Used when scrolling is enabled.
    var expandedIndexPaths : [NSIndexPath] {get set}
    
    /// Defines the animation duration to be used for expanding. Defaults to 0.4
    var closeAnimationDuration : NSTimeInterval {get set}
    
    /// Defines the animation duration to be used for collapsing. Defaults to 0.4
    var openAnimationDuration : NSTimeInterval {get set}
    
    /// Enum value that specifies the state of all the cells. All the cells can be expanded or collapsed. Defaults to CollapsedAll
    var cellDefaultState : DefaultState {get set}
    
    /// Bool variable that is used to allow or disallow the expansion of multiple cells at a time. This variable will always be set to true if `cellDefaultState` is set to `ExpandedAll`. Defaults to false
    var multipleCellExpansionEnabled : Bool {get set}
    
    /// Bool variable that allow or disallow tableView scrolling when expanded. If allowMultipleCellExpansion is set to false, then this will be set to false. Defaults to false.
    var tableViewScrollEnabledWhenExpanded : Bool {get set}
    
    /// Bool variable that determines whether expansion/collapsing should be done. If set, then expanding or collapsing is done. Else does nothing. Defaults to true
    var allowTableViewSelection : Bool {get set}
    
    /// Defines the rotation direction for the arrowView if present. Defaults to clockWise direction for expansion and antiClockWise direction for collapsing.
    var arrowRotationDirection : ArrowRotation {get set}
    
    /// Specify if shadow is required or not. Shadow is used for top and bottom screenshot to display the detailsView as emerging from inside of tableView. Defaults to true.
    var requiresShadow : Bool {get set}
}

extension VPAccordionAnimationProtocol where Self : VPAccordionAnimationViewController {
    //MARK: Public functions
    /// Animate the showing of view controller with an expanding animation inside a tableView
    func showViewController(viewController : UIViewController, inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If any cell is expanded, then collapse it first
        if expandedIndexPaths.count > 0 {
            if !multipleCellExpansionEnabled {
                hideViewOrController(inTableView: tableView, forIndexPath: expandedIndexPaths.first!, callBack: { [weak self] in
                    if self == nil {
                        return
                    }
                    
                    // After hiding all other cells, expand the current cell
                    self!.showViewController(viewController, tableView: tableView, indexPath: indexPath, callBack: callBack)
                })
                
                return
            }
        }
        
        // If no cell is expanded or multiple expansion is allowed, then simply expand the cell
        showViewController(viewController, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    /// Animate the showing of view with an expanding animation inside a tableView
    func showView(view : UIView, inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If any cell is expanded, then collapse it first
        if expandedIndexPaths.count > 0 {
            if !multipleCellExpansionEnabled {
                hideViewOrController(inTableView: tableView, forIndexPath: expandedIndexPaths.first!, callBack: { [weak self] in
                    if self == nil {
                        return
                    }
                    
                    // After hiding all other cells, expand the current cell
                    self!.showView(view, tableView: tableView, indexPath: indexPath, callBack: callBack)
                })
                
                return
            }
        }
        
        // If no cell is expanded or multiple expansion is allowed, then simply expand the cell
        showView(view, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    /// Animate the collapsing of view controller or view with collapsing animation inside a tableView
    func hideViewOrController(inTableView tableView : UITableView, forIndexPath indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If the previous expandedIndexPath and indexPath are same, then collpase the cell.
        if isIndexPathExpanded(indexPath) {
            // Remove all unnecessary data
            expandedIndexPaths.removeAtIndex(expandedIndexPaths.indexOf(indexPath)!)
            let removedView = getRemovedViewOrControllerForIndexPath(indexPath)
            
            // Scrolling will be disabled if allowTableViewScrollingWhenExpanded is set to false. So set it to true when hiding all cells.
            if (!tableViewScrollEnabledWhenExpanded && expandedIndexPaths.count == 0) {
                tableView.scrollEnabled = true
            }
            
            // Take the necessary screenshot to make the UI ready for aniamtion
            if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
                
                // Remove the view controller that was added as a child view controller
                removeControllerForView(removedView)
                
                // Reload the tableView content
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                
                // Animate the collapsing of tableView
                animationBlock()
            }
            else {
                // Remove the view controller that was added as a child view controller
                removeControllerForView(removedView)
                
                // Reload the tableView content
                let offset = tableView.contentOffset.y
                tableView.reloadData()
                
                // Restore proper content offset. +1 since cell's contentView and (infoView + detailsView) has a difference of 1 pixel
                tableView.contentOffset.y = max(0, offset - removedView.bounds.size.height + 1)
                
                // Allow for loading of cells' data. Call in main queue to load all data before showing another animation if needed. Else arrow rotation issue is found
                dispatch_async(dispatch_get_main_queue(), {
                    if let callBack = callBack {
                        callBack()
                    }
                })
            }
        }
    }
}

private extension VPAccordionAnimationProtocol where Self : VPAccordionAnimationViewController {
    //MARK: Private helper functions
    func showViewController(viewController : UIViewController, tableView : UITableView, indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Update the data source for storing the data
        updateDataSource(viewController.view, tableView: tableView, indexPath: indexPath)
        
        // Add the view controller as a child view controller
        addChildViewController(viewController)
        
        // Show viewControlller's view with animation
        animateMovementOfView(viewController.view, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    /// Animate the expansion of view
    func showView(view : UIView, tableView : UITableView, indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Update the data source for storing the data
        updateDataSource(view, tableView: tableView, indexPath: indexPath)
        
        // Show view with animation
        animateMovementOfView(view, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    func updateDataSource(view : UIView, tableView : UITableView, indexPath : NSIndexPath) {
        // Since expanding, set the necessary variables
        
        // If indexPath is already present, then do nothing
        if isIndexPathExpanded(indexPath) {
            return
        }
        
        // Block scrolling only if allowTableViewScrollingWhenExpanded is set to false. Else, scrolling will be enabled by default
        if !tableViewScrollEnabledWhenExpanded {
            tableView.scrollEnabled = false
        }
        
        // Store the view with indexPath expanded
        expandedIndexPaths.append(indexPath)
    }
    
    func animateMovementOfView(view : UIView, tableView : UITableView, indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Take the necessary screenshot to make the UI ready for aniamtion
        let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
        
        // Reload the tableView content
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        // Get the new instance of the cell at the expandedIndexPath
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VPAccordionTableViewCell {
            // Add the view controller's view as a subview to details view
            cell.detailsView.addSubview(view)
            
            // Add necessary constraints
            addFourSidedConstraintForView(view, withSuperView: cell.detailsView)
            
            // Animate the expanding of tableView
            animationBlock()
        }
    }
    
    /// Remove the controller from parentViewController after collapsing
    func removeControllerForView(removedView : AnyObject) {
        // Remove the view controller that was added as a child view controller
        let removedIndex = childViewControllers.indexOf({ (viewController) -> Bool in
            if viewController == removedView as? UIViewController {
                return true
            }
            
            if viewController.view == removedView as? UIView {
                return true
            }
            
            return false
        })
        
        if let removedIndex = removedIndex {
            let removedViewController = childViewControllers[removedIndex]
            removedViewController.removeFromParentViewController()
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
        
        // Set the new size for the view
        aView.frame.size = rect.size
        
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
    
    /// Take the necessary screenshot to make the UI ready for aniamtion
    func createScreenshotUI(tableView : UITableView, indexPath : NSIndexPath, callBack : VPAccordionAnimationCompletionBlock?) -> VPAccordionAnimationCompletionBlock {
        // Get the frame of the expandedIndexPath and the current contentOffset
        let rect = tableView.rectForRowAtIndexPath(indexPath)
        let offset = tableView.contentOffset.y
        
        // A full table height + current cell height is added for safety purpose. An extra height is added for scrolling purpose. i.e., if bottom image is scrolled upwards, then empty image will be seen and vice-versa. To avoid this, rendering remaining bottom/top view so that image will not be empty
        let topImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMinY(rect) - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height + rect.size.height)
        let bottomImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect), width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        
        // Get the instance of arrowView if animation needed for rotating the arrow
        var arrowView : UIView?
        
        // Bool for identifying whether cell is expanding or collapsing
        var isExpanding = false
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VPAccordionTableViewCell {
            if cell.arrowView != nil {
                // Get the screenshot of the arrowImage
                let arrowImage = getScreenShot(cell.arrowView, forRect: cell.arrowView.bounds)
                arrowView = UIImageView(image: arrowImage)
                arrowView?.frame = CGRect(x: cell.arrowView.frame.origin.x, y: rect.origin.y - CGRectGetMinY(topImageRect) + cell.arrowView.frame.origin.y, width: cell.arrowView.frame.size.width, height: cell.arrowView.frame.size.height)
                
                // Hide the arrow View before taking a screenshot. Unhide after animation
                cell.arrowView.hidden = true
                
                // Check if the cell is collapsing or not
                var image : UIImage?
                
                // Get the current image from imageView or buttonView
                if let imageView = cell.arrowView as? UIImageView {
                    image = imageView.image
                }
                else if let buttonView = cell.arrowView as? UIButton {
                    image = buttonView.currentImage
                }
                
                if let image = image where image.imageOrientation == .Up {
                    isExpanding = true
                }
            }
        }
        
        // Create the top and bottom screenshot for showing the animation
        let topImageView = addScreenshotView(tableView, forFrame: topImageRect)
        let bottomImageView = addScreenshotView(tableView, forFrame: bottomImageRect)
        
        // Conatiner view for holding the screenshot image views
        let containerView = UIView(frame: tableView.frame)
        containerView.backgroundColor = UIColor.clearColor()
        containerView.clipsToBounds = true
        
        // Add the image views on top of self
        containerView.addSubview(topImageView)
        containerView.addSubview(bottomImageView)
        
        // Add shadow path for the detailsView's bottomImageView view if needed
        if requiresShadow {
            createShadowPathForView(bottomImageView)
        }
        
        // Check if arrow view is added. If yes, then add it to the added screenshot
        if let arrowView = arrowView {
            topImageView.addSubview(arrowView)
        }
        
        view.addSubview(containerView)
        
        let callBack = { [weak self] in
            if self == nil {
                return
            }
            
            // Animate the rotation of the arrow view if outlet is set
            if let arrowView = arrowView {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VPAccordionTableViewCell {
                    self!.rotateArrowViewForCell(cell, arrowView: arrowView, isExpanding: isExpanding)
                }
            }
            
            // Animate the expansion/collapsing of table cells
            UIView.animateWithDuration(isExpanding ? self!.openAnimationDuration : self!.closeAnimationDuration, animations: {
                // Scroll the tableView to middle if needed
                if isExpanding {
                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
                }
                else {
                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
                }
                
                // Get the new frame for the selected indexPath
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                
                // Calculate the frame change of tableView
                let offsetChange = offset - tableView.contentOffset.y
                
                // Set the topImageView and bottomImageView frame
                topImageView.frame.origin.y += offsetChange
                bottomImageView.frame.origin.y = CGRectGetMaxY(rect) - tableView.contentOffset.y
                
                }, completion: { (isSuccess) in
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VPAccordionTableViewCell {
                        cell.arrowView?.hidden = false
                    }
                    
                    // Remove all animations after completion
                    arrowView?.layer.removeAllAnimations()
                    arrowView = nil
                    
                    // On completion, remove the imageViews
                    topImageView.removeFromSuperview()
                    bottomImageView.removeFromSuperview()
                    containerView.removeFromSuperview()
                    
                    // On successful animation, call callBack to indicate the animation completion
                    // Use dispatch_async to reload the cells and then execute further processing. Issue with arrow when show is called immediately after hide
                    dispatch_async(dispatch_get_main_queue(), {
                        if let callBack = callBack {
                            callBack()
                        }
                    })
            })
        }
        
        return callBack
    }
    
    // Helper function for animating the rotation of arrowView
    func rotateArrowViewForCell(cell : VPAccordionTableViewCell, arrowView : UIView, isExpanding : Bool) {
        let rotateArrowAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotateArrowAnimation.duration = isExpanding ? openAnimationDuration : closeAnimationDuration
        rotateArrowAnimation.values = [0, getRotationAngleForArrowForCell(cell, isExpanding: isExpanding)]
        rotateArrowAnimation.keyTimes = [0, 1]
        rotateArrowAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)]
        rotateArrowAnimation.fillMode = kCAFillModeForwards
        rotateArrowAnimation.removedOnCompletion = false
        
        arrowView.layer.addAnimation(rotateArrowAnimation, forKey: "rotateAnimation")
    }
    
    // Helper function to retreive the screenshot inside a imageView
    func addScreenshotView(tableView : UITableView, forFrame screenshotRect : CGRect) -> UIImageView {
        let screenshotImage = getScreenShot(tableView, forRect: screenshotRect)
        
        // Create the top and bottom image views for showing the animation
        let imageView = UIImageView(image: screenshotImage)
        let topOffSet = screenshotRect.origin.y - tableView.contentOffset.y
        imageView.frame = CGRect(x: screenshotRect.origin.x, y: topOffSet, width: screenshotRect.size.width, height: screenshotRect.size.height)
        
        return imageView
    }
    
    // Helper function for calcaulation the angle needed to rotate the arrow view
    func getRotationAngleForArrowForCell(cell : VPAccordionTableViewCell, isExpanding : Bool) -> CGFloat {
        // Here 4 is the total number of directions available
        var rotationConstant = 0
        
        if (arrowRotationDirection == ArrowRotation.ClockWise) {
            rotationConstant = (4 + cell.arrowImageFinalDirection.rawValue - cell.arrowImageInitialDirection.rawValue) % 4
        }
        else {
            rotationConstant = (cell.arrowImageFinalDirection.rawValue - cell.arrowImageInitialDirection.rawValue - 4) % 4
        }
        
        let midPiValue = 3.141593 / 2
        rotationConstant = rotationConstant * (isExpanding ? 1 : -1)
        
        return CGFloat(Double(rotationConstant) * midPiValue)
    }
    
    // Helper function to add the shadow to a view
    func createShadowPathForView(aView : UIView) {
        aView.layer.shadowColor = UIColor.blackColor().CGColor
        aView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        aView.layer.shadowOpacity = 0.5
        aView.layer.shadowPath = CGPathCreateWithRect(aView.bounds, nil)
    }
}