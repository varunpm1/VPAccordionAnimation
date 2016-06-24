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
                let topImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect) - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
                let bottomImageRect = CGRect(x: tableView.frame.origin.x, y: CGRectGetMaxY(rect), width: tableView.bounds.size.width, height: tableView.bounds.size.height)
                
                // Create the top and bottom screenshot for showing the animation
                let topImage = self.getScreenShot(tableView, forRect: topImageRect)
                let bottomImage = self.getScreenShot(tableView, forRect: bottomImageRect)
                
                // Reload the tableView and scroll the row to middle of the tableView, if needed
                tableView.reloadData()
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
                
                // Create the top and bottom image views for showing the animation
                topImageView = UIImageView(image: topImage)
                let topOffSet = topImageRect.origin.y - tableView.contentOffset.y
                if (tableView.contentOffset.y + tableView.bounds.size.height) <= (tableView.contentSize.height - tableView.bounds.size.height / 2) {
                    topImageView?.frame = CGRect(x: topImageRect.origin.x, y: topOffSet, width: topImageRect.size.width, height: topImageRect.size.height)
                }
                else {
                    topImageView?.frame = CGRect(x: topImageRect.origin.x, y: topOffSet + expandedCellHeight - unexpandedCellHeight, width: topImageRect.size.width, height: topImageRect.size.height)
                }
                
                bottomImageView = UIImageView(image: bottomImage)
                let bottomOffSet = bottomImageRect.origin.y - tableView.contentOffset.y
                if (tableView.contentOffset.y + tableView.bounds.size.height) <= (tableView.contentSize.height - tableView.bounds.size.height / 2) {
                    bottomImageView?.frame = CGRect(x: bottomImageRect.origin.x, y: bottomOffSet, width: bottomImageRect.size.width, height: bottomImageRect.size.height)
                }
                else {
                    bottomImageView?.frame = CGRect(x: bottomImageRect.origin.x, y: bottomOffSet + expandedCellHeight - unexpandedCellHeight, width: bottomImageRect.size.width, height: bottomImageRect.size.height)
                }
                
                // Add the image views on top of self
                self.view.addSubview(topImageView!)
                self.view.addSubview(bottomImageView!)
                
                // Get the new instance of the cell at the selectedIndexPath
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AccrodianTableViewCell {
                    // Add the view controller's view as a subview to details view
                    cell.detailsView.addSubview(viewController.view)
                    
                    // Add necessary constraints
                    addFourSidedConstraintForView(viewController.view, withSuperView: cell.detailsView)
                    
                    // Animate the movement of image view to have an effect of table expanding
                    UIView.animateWithDuration(1, animations: {
                        if tableView.contentOffset.y > 0 {
                            if (tableView.contentOffset.y + tableView.bounds.size.height) >= (tableView.contentSize.height - tableView.bounds.size.height / 2) {
                                
                            }
                            else {
                                // Move the imageViews to negative so as to have a scroll animation to middle
                                topImageView?.frame.origin.y = -(topImageView!.bounds.size.height - tableView.center.y)
                                bottomImageView?.frame.origin.y = (tableView.center.y)
                            }
                        }
                        }, completion: { (isSuccess) in
                            UIView.animateWithDuration(1, animations: {
                                if tableView.contentOffset.y > 0 {
                                    if (tableView.contentOffset.y + tableView.bounds.size.height) >= (tableView.contentSize.height - tableView.bounds.size.height / 2) {
                                        // Set the top of image view to negative value to move it out of the screen
                                        topImageView?.frame.origin.y -= (self.expandedCellHeight - self.unexpandedCellHeight)
                                    }
                                    else {
                                        // Set the top of image view to negative value to move it out of the screen
                                        topImageView?.frame.origin.y -= (self.expandedCellHeight / 2 - self.unexpandedCellHeight)
                                        
                                        // Set the bottom of image view to positive value to move it out of the screen. Calculate the increase in cell height and move it w.r.t to rect of selectedIndexPath
                                        bottomImageView?.frame.origin.y += (self.expandedCellHeight / 2)
                                    }
                                }
                                else {
                                    // Set the bottom of image view to positive value to move it out of the screen. Calculate the increase in cell height and move it w.r.t to rect of selectedIndexPath
                                    bottomImageView?.frame.origin.y += (self.expandedCellHeight - self.unexpandedCellHeight)
                                }
                                }, completion: { (isSuccess) in
                                    // Remove the image Views
//                                    topImageView?.removeFromSuperview()
//                                    bottomImageView?.removeFromSuperview()
                            })
                    })
                }
            }
        }
    }
    
    /// Get the screenshot based on the rect size and origin. If origin is 0, then top screenshot is created. Else the bottom screenshot is created.
    private func getScreenShot(aView : UIScrollView, forRect rect : CGRect) -> UIImage {
        let frame = aView.frame
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        aView.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height + rect.origin.y)
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), rect.origin.x, -rect.origin.y);
        aView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        aView.frame = frame
        
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