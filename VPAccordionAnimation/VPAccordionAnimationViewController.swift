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
    
    // Default tableView instance
    @IBOutlet weak var tableView: UITableView!
    
    // Expanded indexPath for storing the selected cell
    var expandedIndexPaths : [NSIndexPath] = []
    
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
    
    // IndexPathsData for storing view or viewController instances
    private var indexPathsData : [NSIndexPath : AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "VPAccordionTableViewCell", bundle: nil), forCellReuseIdentifier: "VPAccordionTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Public Helper functions
    /// Helper function for populating the indexPathsData to store view or view controller's data
    func populateIndexPathsDataForIndexPath(indexPath : NSIndexPath, isViewControllerNeeded : Bool) {
        if isViewControllerNeeded {
            indexPathsData[indexPath] = createViewControllerForIndexPath(indexPath)
        }
        else {
            indexPathsData[indexPath] = createViewForIndexPath(indexPath)
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
    
    /// Helper method to check if indexPath is already expanded or not
    func isIndexPathExpanded(indexPath : NSIndexPath) -> Bool {
        return expandedIndexPaths.contains(indexPath)
    }
    
    /// Helper method for returning removed view or view Controller instance
    func getRemovedViewOrControllerForIndexPath(indexPath : NSIndexPath) -> AnyObject {
        return indexPathsData[indexPath]!
    }
    
    //MARK: Private Helper functions
    // Populate the expanded indexPaths data
    private func populateExpandedIndexPathsData() {
        let sections = tableView.numberOfSections
        for sectionIndex in 0.stride(to: sections, by: 1) {
            let rows = tableView.numberOfRowsInSection(sectionIndex)
            
            for rowIndex in 0.stride(to: rows, by: 1) {
                let indexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                
                if let viewController = createViewControllerForIndexPath(indexPath) {
                    indexPathsData[indexPath] = viewController.view
                    addChildViewController(viewController)
                }
                else if let view = createViewForIndexPath(indexPath) {
                    indexPathsData[indexPath] = view
                }
                
                expandedIndexPaths.append(indexPath)
            }
        }
    }
}

/// Default DataSource and Delegate values
extension VPAccordionAnimationViewController : UITableViewDataSource, UITableViewDelegate {
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexPathsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VPAccordionTableViewCell") as! VPAccordionTableViewCell
        cell.displayLabel?.text = "Row \(indexPath.row + 1)"
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isIndexPathExpanded(indexPath) {
            return tableView.bounds.size.height
        }
        else {
            return 120
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Check if cell is expanded or not. If expanded, then shrink the cell. Else expand the cell
        if isIndexPathExpanded(indexPath) {
            hideViewOrController(inTableView: tableView, forIndexPath: indexPath, callBack: nil)
        }
        else {
            if let viewController = indexPathsData[indexPath] as? UIViewController {
                showViewController(viewController, inTableView: tableView, forIndexPath: indexPath, callBack: nil)
            }
            else if let view = indexPathsData[indexPath] as? UIView {
                showView(view, inTableView: tableView, forIndexPath: indexPath, callBack: nil)
            }
        }
    }
    
}

/// Implement the protocol methods in extension. Else the override in subclass won't work.
extension VPAccordionAnimationViewController : VPAccordionAnimationProtocol {
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
                if let controller = indexPathsData[indexPath] as? UIViewController {
                    cell.detailsView.addSubview(controller.view)
                    addFourSidedConstraintForView(controller.view, withSuperView: cell.detailsView)
                }
                else if let view = indexPathsData[indexPath] as? UIView {
                    cell.detailsView.addSubview(view)
                    addFourSidedConstraintForView(view, withSuperView: cell.detailsView)
                }
            }
            else {
                // Set "Up" direction to reset the image's default position
                cell.updateImageForViewWithCurrentDirection(cell.arrowImageInitialDirection)
            }
        }
    }
}