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

class VPAccordionAnimationViewController: UIViewController, VPAccordionAnimationProtocol {
    
    // Default tableView instance
    fileprivate var tableView: UITableView!
    
    // Expanded indexPath for storing the selected cell
    var expandedIndexPaths : [IndexPath] = []
    
    // Default value for animation
    var closeAnimationDuration: TimeInterval = 0.4
    var openAnimationDuration: TimeInterval = 0.4
    
    // Default value for disabling multiple expanding of cells
    var multipleCellExpansionEnabled: Bool = false {
        didSet {
            // Check if expandAll is set. If yes, and if allowMultipleCellExpansion is false, then forcefully set allowMultipleCellExpansion to true
            if cellDefaultState == DefaultState.expandedAll && multipleCellExpansionEnabled == false {
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    // Default value for disabling scrolling when expanded
    var tableViewScrollEnabledWhenExpanded: Bool = false
    
    // Default value for disabling scrolling when collapsed
    var tableViewScrollEnabledWhenCollapsed: Bool = true
    
    // Default value for enabling selection for expanding or collapsing
    var allowTableViewSelection: Bool = true
    
    // Default value for collapsed state by deafult
    var cellDefaultState: DefaultState = DefaultState.collapsedAll {
        didSet {
            if cellDefaultState == DefaultState.expandedAll {
                // Forcefully set allowMultipleCellExpansion to true, since all cells are expanded. So multiple cell expansion should be true
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    // Default value for clockwise rotation while expanding and anticlockwise while collapsing
    var arrowRotationDirection: ArrowRotation = ArrowRotation.clockWise
    
    // Default value to enable the shadow
    var requiresShadow: Bool = true
    
    // IndexPathsData for storing view or viewController instances
    fileprivate var indexPathsData : [IndexPath : AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Public Helper functions
    /// Helper function for populating the indexPathsData to store view or view controller's data. Defaults to section 0 with row index from 0 to viewCount - 1
    func createAccordionDataForIndexPaths(withViewOrControllerData viewData : [AnyObject], forTableView tableView : UITableView) {
        self.tableView = tableView
        
        // For default cells
        self.tableView.register(UINib(nibName: String(describing: VPAccordionTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: VPAccordionTableViewCell.self))
        
        for (index, view) in viewData.enumerated() {
            indexPathsData[IndexPath(row: index, section: 0)] = view
        }
    }
    
    /// Helper function for populating the indexPathsData to store view or view controller's data based on indexPaths
    func createAccordionDataForIndexPaths(_ indexPaths : [IndexPath], withViewOrControllerData viewData : [AnyObject], forTableView tableView : UITableView) {
        assert(indexPaths.count == viewData.count, "IndexPaths count should be equal to viewData count")
        
        self.tableView = tableView
        
        // For default cells
        self.tableView.register(UINib(nibName: String(describing: VPAccordionTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: VPAccordionTableViewCell.self))
        
        for (index, indexPath) in indexPaths.enumerated() {
            indexPathsData[indexPath] = viewData[index]
        }
    }
    
    /// Helper method for addding four sided constraints for necessary view w.r.t to super view
    func addFourSidedConstraintForView(_ view : UIView, withSuperView superView : UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        superView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    /// Helper method to check if indexPath is already expanded or not
    func isIndexPathExpanded(_ indexPath : IndexPath) -> Bool {
        return expandedIndexPaths.contains(indexPath)
    }
    
    /// Helper method for returning removed view or view Controller instance
    func getRemovedViewOrControllerForIndexPath(_ indexPath : IndexPath) -> AnyObject {
        return indexPathsData[indexPath]!
    }
}

/// Default DataSource and Delegate values
extension VPAccordionAnimationViewController : UITableViewDataSource, UITableViewDelegate {
    //MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexPathsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VPAccordionTableViewCell.self)) as! VPAccordionTableViewCell
        cell.displayLabel?.text = "Row \((indexPath as NSIndexPath).row + 1)"
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isIndexPathExpanded(indexPath) {
            return UIScreen.main.bounds.size.height
        }
        else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    /// This method reinitializes arrow image position if needed. If arrow animation is needed and subclasses want this delegate method to be implemented, then subclasses has to call this method using super. Else animation won't work as needed
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
