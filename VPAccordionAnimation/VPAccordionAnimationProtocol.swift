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
    case expandedAll
    case collapsedAll
}

enum ArrowRotation {
    case clockWise
    case antiClockWise
}

protocol VPAccordionAnimationProtocol : class {
    //MARK: Protocol Variables
    /// Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing. Each value will be expanded index path. Used when scrolling is enabled.
    var expandedIndexPaths : [IndexPath] {get set}
    
    /// Defines the animation duration to be used for expanding. Defaults to 0.4
    var closeAnimationDuration : TimeInterval {get set}
    
    /// Defines the animation duration to be used for collapsing. Defaults to 0.4
    var openAnimationDuration : TimeInterval {get set}
    
    /// Enum value that specifies the state of all the cells. All the cells can be expanded or collapsed. Defaults to CollapsedAll
    var cellDefaultState : DefaultState {get set}
    
    /// Bool variable that is used to allow or disallow the expansion of multiple cells at a time. This variable will always be set to true if `cellDefaultState` is set to `ExpandedAll`. Defaults to false
    var multipleCellExpansionEnabled : Bool {get set}
    
    /// Bool variable that allow or disallow tableView scrolling when expanded. If allowMultipleCellExpansion is set to false, then this will be set to false. Defaults to false.
    var tableViewScrollEnabledWhenExpanded : Bool {get set}
    
    /// Bool variable that allow or disallow tableView scrolling when collapsed. Defaults to true.
    var tableViewScrollEnabledWhenCollapsed : Bool {get set}
    
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
    func showViewController(_ viewController : UIViewController, inTableView tableView : UITableView, forIndexPath indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If any cell is expanded, then collapse it first
        if expandedIndexPaths.count > 0 {
            if !multipleCellExpansionEnabled {
                hideViewOrController(inTableView: tableView, forIndexPath: expandedIndexPaths.first! as IndexPath, callBack: { [weak self] in
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
    func showView(_ view : UIView, inTableView tableView : UITableView, forIndexPath indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If any cell is expanded, then collapse it first
        if expandedIndexPaths.count > 0 {
            if !multipleCellExpansionEnabled {
                hideViewOrController(inTableView: tableView, forIndexPath: expandedIndexPaths.first! as IndexPath, callBack: { [weak self] in
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
    func hideViewOrController(inTableView tableView : UITableView, forIndexPath indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // If allowTableViewSelection is set to false, then do nothing
        if !allowTableViewSelection {
            return
        }
        
        // If the previous expandedIndexPath and indexPath are same, then collpase the cell.
        if isIndexPathExpanded(indexPath) {
            // Remove all unnecessary data
            expandedIndexPaths.remove(at: expandedIndexPaths.index(of: indexPath)!)
            let removedView = getRemovedViewOrControllerForIndexPath(indexPath)
            
            // Scrolling will be disabled if allowTableViewScrollingWhenExpanded is set to false. So set it to true/false when hiding all cells.
            if (!tableViewScrollEnabledWhenExpanded && expandedIndexPaths.count == 0) {
                tableView.isScrollEnabled = tableViewScrollEnabledWhenCollapsed
            }
            
            // Take the necessary screenshot to make the UI ready for aniamtion
            if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
                
                // Remove the view controller that was added as a child view controller
                removeControllerForView(removedView)
                
                // Get the previous offset. Used for estimated row height issue
                let prevOffset = tableView.contentOffset.y
                
                // Reload the tableView content
                tableView.reloadRows(at: [indexPath], with: .none)
                
                // Set the previous offset back. Used for estimated row height issue
                tableView.contentOffset.y = prevOffset
                
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
                if removedView.isKind(of: UIView.self) {
                    tableView.contentOffset.y = max(0, offset - removedView.bounds.size.height + 1)
                }
                else {
                    tableView.contentOffset.y = max(0, offset - removedView.view.bounds.size.height + 1)
                }
                
                // Allow for loading of cells' data. Call in main queue to load all data before showing another animation if needed. Else arrow rotation issue is found
                DispatchQueue.main.async(execute: {
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
    func showViewController(_ viewController : UIViewController, tableView : UITableView, indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Update the data source for storing the data
        updateDataSource(viewController.view, tableView: tableView, indexPath: indexPath)
        
        // Add the view controller as a child view controller
        addChildViewController(viewController)
        
        // Show viewControlller's view with animation
        animateMovementOfView(viewController.view, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    /// Animate the expansion of view
    func showView(_ view : UIView, tableView : UITableView, indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Update the data source for storing the data
        updateDataSource(view, tableView: tableView, indexPath: indexPath)
        
        // Show view with animation
        animateMovementOfView(view, tableView: tableView, indexPath: indexPath, callBack: callBack)
    }
    
    func updateDataSource(_ view : UIView, tableView : UITableView, indexPath : IndexPath) {
        // Since expanding, set the necessary variables
        
        // If indexPath is already present, then do nothing
        if isIndexPathExpanded(indexPath) {
            return
        }
        
        // Block scrolling only if allowTableViewScrollingWhenExpanded is set to false. Else, scrolling will be enabled by default
        if !tableViewScrollEnabledWhenExpanded {
            tableView.isScrollEnabled = false
        }
        
        // Store the view with indexPath expanded
        expandedIndexPaths.append(indexPath)
    }
    
    func animateMovementOfView(_ view : UIView, tableView : UITableView, indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) {
        // Take the necessary screenshot to make the UI ready for aniamtion
        let animationBlock = createScreenshotUI(tableView, indexPath: indexPath, callBack: callBack)
        
        // Get the previous offset. Used for estimated row height issue
        let prevOffset = tableView.contentOffset.y
        
        // Reload the tableView content
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // Set the previous offset back. Used for estimated row height issue
        tableView.contentOffset.y = prevOffset
        
        // Get the new instance of the cell at the expandedIndexPath
        if let cell = tableView.cellForRow(at: indexPath) as? VPAccordionTableViewCell {
            // Add the view controller's view as a subview to details view
            cell.detailsView.addSubview(view)
            
            // Add necessary constraints
            addFourSidedConstraintForView(view, withSuperView: cell.detailsView)
            
            // Animate the expanding of tableView
            animationBlock()
        }
    }
    
    /// Remove the controller from parentViewController after collapsing
    func removeControllerForView(_ removedView : AnyObject) {
        // Remove the view controller that was added as a child view controller
        let removedIndex = childViewControllers.index(where: { (viewController) -> Bool in
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
    func getScreenShot(_ aView : UIView, forRect rect : CGRect) -> UIImage {
        // Preserve the previous frame and contentOffset of the scrollView (tableView)
        let frame = aView.frame
        var offset : CGPoint?
        
        // Get offset only if view is scrollView
        if let aView = aView as? UIScrollView {
            offset = aView.contentOffset
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        // Move the frame for the screenshot starting position
        UIGraphicsGetCurrentContext()?.translateBy(x: rect.origin.x, y: -rect.origin.y);
        
        // Set the new size for the view
        aView.frame.size = rect.size
        
        // Set the new contentOffset for the view only if it's a scrollView
        if let aView = aView as? UIScrollView {
            aView.contentOffset.y = rect.origin.y
        }
        
        aView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Reset the previous frame
        aView.frame = frame
        
        // Reset offset only if view is scrollView
        if let aView = aView as? UIScrollView {
            aView.contentOffset = offset!
        }
        
        return image!
    }
    
    /// Take the necessary screenshot to make the UI ready for aniamtion
    func createScreenshotUI(_ tableView : UITableView, indexPath : IndexPath, callBack : VPAccordionAnimationCompletionBlock?) -> VPAccordionAnimationCompletionBlock {
        // Get the frame of the expandedIndexPath and the current contentOffset
        let oldRect = tableView.rectForRow(at: indexPath)
        let offset = tableView.contentOffset.y
        
        // A full table height + current cell height is added for safety purpose. An extra height is added for scrolling purpose. i.e., if bottom image is scrolled upwards, then empty image will be seen and vice-versa. To avoid this, rendering remaining bottom/top view so that image will not be empty
        let topImageRect = CGRect(x: tableView.bounds.origin.x, y: oldRect.minY - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height + oldRect.size.height)
        let bottomImageRect = CGRect(x: tableView.bounds.origin.x, y: oldRect.maxY, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        
        // Get the instance of arrowView if animation needed for rotating the arrow
        var arrowView : UIView?
        
        // Bool for identifying whether cell is expanding or collapsing
        var isExpanding = false
        
        // If there is a section footer view, then hide it when taking a screenshot
        if let footerView = tableView.footerView(forSection: indexPath.section) {
            footerView.isHidden = true
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? VPAccordionTableViewCell {
            if cell.arrowView != nil {
                // Get the screenshot of the arrowImage
                let arrowImage = getScreenShot(cell.arrowView, forRect: cell.arrowView.bounds)
                arrowView = UIImageView(image: arrowImage)
                arrowView?.frame = CGRect(x: cell.arrowView.frame.origin.x, y: oldRect.origin.y - topImageRect.minY + cell.arrowView.frame.origin.y, width: cell.arrowView.frame.size.width, height: cell.arrowView.frame.size.height)
                
                // Hide the arrow View before taking a screenshot. Unhide after animation
                cell.arrowView.isHidden = true
                
                // Check if the cell is collapsing or not
                var image : UIImage?
                
                // Get the current image from imageView or buttonView
                if let imageView = cell.arrowView as? UIImageView {
                    image = imageView.image
                }
                else if let buttonView = cell.arrowView as? UIButton {
                    image = buttonView.currentImage
                }
                
                if let image = image , image.imageOrientation == .up {
                    isExpanding = true
                }
            }
        }
        
        // Create the top and bottom screenshot for showing the animation
        let topImageView = addScreenshotView(tableView, forFrame: topImageRect)
        let bottomImageView = addScreenshotView(tableView, forFrame: bottomImageRect)
        
        // Conatiner view for holding the screenshot image views
        let containerView = UIView(frame: tableView.frame)
        containerView.backgroundColor = UIColor.clear
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
        view.bringSubview(toFront: containerView)
        
        // If there is a section footer view, then unhide it after taking a screenshot
        if let footerView = tableView.footerView(forSection: indexPath.section) {
            footerView.isHidden = false
        }
        
        let callBack = { [weak self] in
            if self == nil {
                return
            }
            
            // Animate the rotation of the arrow view if outlet is set
            if let arrowView = arrowView {
                if let cell = tableView.cellForRow(at: indexPath) as? VPAccordionTableViewCell {
                    self!.rotateArrowViewForCell(cell, arrowView: arrowView, isExpanding: isExpanding)
                }
            }
            
            // Scroll the tableView to middle if needed
            if isExpanding {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            }
            else {
                tableView.scrollToRow(at: indexPath, at: .none, animated: false)
                
                // Reload data forcefully since offset wasn't being returned properly when collapsing
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.reloadData()
            }
            
            // Animate the expansion/collapsing of table cells
            UIView.animate(withDuration: isExpanding ? self!.openAnimationDuration : self!.closeAnimationDuration, animations: {
                // Get the new frame for the selected indexPath
                let rect = tableView.rectForRow(at: indexPath)
                
                // Calculate the frame change of tableView
                let offsetChange = offset - tableView.contentOffset.y
                
                // Set the topImageView and bottomImageView frame
                topImageView.frame.origin.y += offsetChange
                bottomImageView.frame.origin.y = rect.maxY - tableView.contentOffset.y
                
            }, completion: { (isSuccess) in
                if let cell = tableView.cellForRow(at: indexPath) as? VPAccordionTableViewCell {
                    cell.arrowView?.isHidden = false
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
                DispatchQueue.main.async(execute: {
                    if let callBack = callBack {
                        callBack()
                    }
                })
            })
        }
        
        return callBack
    }
    
    // Helper function for animating the rotation of arrowView
    func rotateArrowViewForCell(_ cell : VPAccordionTableViewCell, arrowView : UIView, isExpanding : Bool) {
        let rotateArrowAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotateArrowAnimation.duration = isExpanding ? openAnimationDuration : closeAnimationDuration
        rotateArrowAnimation.values = [0, getRotationAngleForArrowForCell(cell, isExpanding: isExpanding)]
        rotateArrowAnimation.keyTimes = [0, 1]
        rotateArrowAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)]
        rotateArrowAnimation.fillMode = kCAFillModeForwards
        rotateArrowAnimation.isRemovedOnCompletion = false
        
        arrowView.layer.add(rotateArrowAnimation, forKey: "rotateAnimation")
    }
    
    // Helper function to retreive the screenshot inside a imageView
    func addScreenshotView(_ tableView : UITableView, forFrame screenshotRect : CGRect) -> UIImageView {
        let screenshotImage = getScreenShot(tableView, forRect: screenshotRect)
        
        // Create the top and bottom image views for showing the animation
        let imageView = UIImageView(image: screenshotImage)
        let topOffSet = screenshotRect.origin.y - tableView.contentOffset.y
        imageView.frame = CGRect(x: screenshotRect.origin.x, y: topOffSet, width: screenshotRect.size.width, height: screenshotRect.size.height)
        
        return imageView
    }
    
    // Helper function for calcaulation the angle needed to rotate the arrow view
    func getRotationAngleForArrowForCell(_ cell : VPAccordionTableViewCell, isExpanding : Bool) -> CGFloat {
        // Here 4 is the total number of directions available
        var rotationConstant = 0
        
        if (arrowRotationDirection == ArrowRotation.clockWise) {
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
    func createShadowPathForView(_ aView : UIView) {
        aView.layer.shadowColor = UIColor.black.cgColor
        aView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        aView.layer.shadowOpacity = 0.5
        aView.layer.shadowPath = CGPath(rect: aView.bounds, transform: nil)
    }
}
