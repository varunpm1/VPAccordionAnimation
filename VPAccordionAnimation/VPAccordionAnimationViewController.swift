//
//  VPAccordionAnimationViewController.swift
//  VPAccordionAnimation
//
//  Created by Varun on 28/06/16.
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

class VPAccordionAnimationViewController: UIViewController {
    
    // Expanded indexPath for storing the selected cell
    var expandedIndexPathsData : [NSIndexPath : UIView] = [:]
    
    // Default value for animation
    var closeAnimationDuration: NSTimeInterval = 0.4
    var openAnimationDuration: NSTimeInterval = 0.4
    
    // Default value for disabling multiple expanding of cells
    var multipleCellExpansionEnabled: Bool = false {
        didSet {
            // Check if expandAll is set. If yes, and if allowMultipleCellExpansion is false, then forcefully set allowMultipleCellExpansion to true
            if cellDefaultState == DefaultState.ExpandedAll && multipleCellExpansionEnabled == false {
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    // Default value for disabling scrolling when expanded
    var tableViewScrollEnabledWhenExpanded: Bool = false
    
    // Default value for enabling selection for expanding or collapsing
    var allowTableViewSelection: Bool = true
    
    // Default value for collapsed state by deafult
    var cellDefaultState: DefaultState = DefaultState.CollapsedAll {
        didSet {
            if cellDefaultState == DefaultState.ExpandedAll {
                populateExpandedIndexPathsData()
                
                // Forcefully set allowMultipleCellExpansion to true, since all cells are expanded. So multiple cell expansion should be true
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    // Default value for clockwise rotation while expanding and anticlockwise while collapsing
    var arrowRotationDirection: ArrowRotation = ArrowRotation.ClockWise
    
    // Default value to enable the shadow
    var requiresShadow: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Public Helper functions
    /// Helper method for addding four sided constraints for necessary view w.r.t to super view
    func addFourSidedConstraintForView(view : UIView, withSuperView superView : UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        superView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    /// Helper method to check if indexPath is already expanded or not
    func isIndexPathExpanded(indexPath : NSIndexPath) -> Bool {
        return expandedIndexPathsData.keys.contains(indexPath)
    }
    
    //MARK: Private Helper functions
    // Populate the expanded indexPaths data
    private func populateExpandedIndexPathsData() {
        let sections = self.getNumberOfSectionsInTableView()
        for sectionIndex in 0.stride(to: sections, by: 1) {
            let rows = self.getNumberOfRowsInTableViewForSection(sectionIndex)
            
            for rowIndex in 0.stride(to: rows, by: 1) {
                let indexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                
                if let viewController = createViewControllerForIndexPath(indexPath) {
                    expandedIndexPathsData[indexPath] = viewController.view
                    addChildViewController(viewController)
                }
                else if let view = createViewForIndexPath(indexPath) {
                    expandedIndexPathsData[indexPath] = view
                }
            }
        }
    }
}

/// Implement the protocol methods in extension. Else the override in subclass won't work.
extension VPAccordionAnimationViewController : VPAccordionAnimationProtocol {
    func getNumberOfSectionsInTableView() -> Int {
        return 0
    }
    
    func getNumberOfRowsInTableViewForSection(section: Int) -> Int {
        return 0
    }
    
    func createViewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        return nil
    }
    
    func createViewForIndexPath(indexPath: NSIndexPath) -> UIView? {
        return nil
    }
}

extension VPAccordionAnimationViewController {
    /// This method reinitializes arrow image position if needed. If arrow animation is needed and subclasses want this delegate method to be implemented, then subclasses has to call this method using super. Else animation won't work as needed
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // If the expandedIndexPath is the same as the cell's indexPath, then set the arrow image (if present) to final state, else in initial state
        if let cell = cell as? VPAccordionTableViewCell {
            if isIndexPathExpanded(indexPath) {
                // Set required direction for the selected indexPath
                cell.updateImageForViewWithCurrentDirection(cell.arrowImageFinalDirection)
                
                // Add the view back if needed. When scrolling is enabled
                cell.detailsView.addSubview(expandedIndexPathsData[indexPath]!)
                addFourSidedConstraintForView(expandedIndexPathsData[indexPath]!, withSuperView: cell.detailsView)
            }
            else {
                // Set "Up" direction to reset the image's default position
                cell.updateImageForViewWithCurrentDirection(cell.arrowImageInitialDirection)
            }
        }
    }
}