//
//  VPAccordionAnimationOptions.swift
//  VPAccordionAnimation
//
//  Created by Varun P M on 13/06/18.
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

public enum DefaultState {
    case expandedAll
    case collapsedAll
}

public enum ArrowDirection: Int {
    case left
    case up
    case right
    case down
    
    func getOrientationWithDefaultOrientation(_ defaultOrientation: ArrowDirection) -> UIImageOrientation {
        let displacement = rawValue - defaultOrientation.rawValue
        
        switch displacement {
        case 0:
            // Set the default direction of the image
            return UIImageOrientation.up
        case 1, -3:
            // Rotate by 90 degress to Clock wise direction
            return UIImageOrientation.right
        case 2, -2:
            // Rotate by 180 degress to Clock wise direction
            return UIImageOrientation.down
        default:
            // Rotate by 90 degress to Anti-Clock wise direction
            return UIImageOrientation.left
        }
    }
}

public enum ArrowRotation {
    case clockWise
    case antiClockWise
}

public struct VPAccordionAnimationOptions {
    /// Use this variable for preparing the cell's height while expanding or collapsing. If set, then animation will be expanding. If not collpasing. Each value will be expanded index path. Used when scrolling is enabled.
    var expandedIndexPaths: [IndexPath]
    
    /// Defines the animation duration to be used for expanding. Defaults to 0.4
    var openAnimationDuration: TimeInterval
    
    /// Defines the animation duration to be used for collapsing. Defaults to 0.4
    var closeAnimationDuration: TimeInterval
    
    /// Enum value that specifies the state of all the cells. All the cells can be expanded or collapsed. Defaults to CollapsedAll
    var cellDefaultState: DefaultState {
        didSet {
            if cellDefaultState == DefaultState.expandedAll {
                // Forcefully set allowMultipleCellExpansion to true, since all cells are expanded. So multiple cell expansion should be true
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    /// Bool variable that is used to allow or disallow the expansion of multiple cells at a time. This variable will always be set to true if `cellDefaultState` is set to `ExpandedAll`. Defaults to false
    var multipleCellExpansionEnabled: Bool {
        didSet {
            // Check if expandAll is set. If yes, and if allowMultipleCellExpansion is false, then forcefully set allowMultipleCellExpansion to true
            if cellDefaultState == DefaultState.expandedAll && multipleCellExpansionEnabled == false {
                multipleCellExpansionEnabled = true
            }
        }
    }
    
    /// Bool variable that allow or disallow tableView scrolling when expanded. If allowMultipleCellExpansion is set to false, then this will be set to false. Defaults to false.
    var tableViewScrollEnabledWhenExpanded: Bool
    
    /// Bool variable that allow or disallow tableView scrolling when collapsed. Defaults to true.
    var tableViewScrollEnabledWhenCollapsed: Bool
    
    /// Bool variable that determines whether expansion/collapsing should be done. If set, then expanding or collapsing is done. Else does nothing. Defaults to true
    var allowTableViewSelection: Bool
    
    /// Defines the rotation direction for the arrowView if present. Defaults to clockWise direction for expansion and antiClockWise direction for collapsing.
    var arrowRotationDirection: ArrowRotation
    
    /// Specify if shadow is required or not. Shadow is used for top and bottom screenshot to display the detailsView as emerging from inside of tableView. Defaults to true.
    var requiresShadow: Bool
    
    init(expandedIndexPaths: [IndexPath] = [], openAnimationDuration: TimeInterval = 0.4, closeAnimationDuration: TimeInterval = 0.4, cellDefaultState: DefaultState = .collapsedAll, multipleCellExpansionEnabled: Bool = false, tableViewScrollEnabledWhenExpanded: Bool = false, tableViewScrollEnabledWhenCollapsed: Bool = true, allowTableViewSelection: Bool = true, arrowRotationDirection: ArrowRotation = .clockWise, requiresShadow: Bool = true) {
        self.expandedIndexPaths = expandedIndexPaths
        self.openAnimationDuration = openAnimationDuration
        self.closeAnimationDuration = closeAnimationDuration
        self.cellDefaultState = cellDefaultState
        self.multipleCellExpansionEnabled = multipleCellExpansionEnabled
        self.tableViewScrollEnabledWhenExpanded = tableViewScrollEnabledWhenExpanded
        self.tableViewScrollEnabledWhenCollapsed = tableViewScrollEnabledWhenCollapsed
        self.allowTableViewSelection = allowTableViewSelection
        self.arrowRotationDirection = arrowRotationDirection
        self.requiresShadow = requiresShadow
    }
}
