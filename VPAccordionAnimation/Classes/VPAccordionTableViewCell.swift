//
//  VPAccordionTableViewCell.swift
//  VPAccordionAnimationExample
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

open class VPAccordionTableViewCell: UITableViewCell {
    /** **Important: The Height constraint has to be set for infoView instead of bottom constraint**
     
     Info view should be the container view holding all the views as subviews that represent the cell in unexpanded state */
    @IBOutlet weak var infoView: UIView!
    
    /// UILabel used to display the text in the cell.
    @IBOutlet weak open var displayLabel: UILabel!
    
    /// This variable holds the arrow view if present which needs rotation animation
    @IBOutlet weak var arrowView: UIView!
    
    /// Details view is the container view holding all the views as subviews that represent the cell in expanded state (View controller data)
    var detailsView: UIView!
    
    /// Set this variable if animation of arrow image is needed. Set the direction for initial and final direction so that rotation is done clockwise direction from current to final direction. Defaults to `Right` to `Down` Clockwise
    public var arrowImageInitialDirection: ArrowDirection = .right
    
    /// Set this variable if animation of arrow image is needed. Set the direction for initial and final direction so that rotation is done clockwise direction from current to final direction. Defaults to `Right` to `Down` Clockwise
    public var arrowImageFinalDirection: ArrowDirection = .down
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        // Check if infoView is set or not. If not do not proceed further
        assert(infoView != nil, "InfoView cannot be nil")
        
        // Check if height constraint is set or not
        let constraintCheck = { [weak self] (constraint: NSLayoutConstraint) -> Bool in
            guard let weakSelf = self else { return false }
            
            if constraint.firstAttribute == .height && constraint.firstItem as? NSObject == weakSelf.infoView {
                return true
            } else {
                return false
            }
        }
        
        var isHeightConstraintAdded = false
        for constraint in infoView.constraints {
            isHeightConstraintAdded = constraintCheck(constraint)
            
            if isHeightConstraintAdded {
                break
            }
        }
        
        assert(isHeightConstraintAdded, "InfoView has to have a height constraint")
        
        // Create details view
        if detailsView == nil {
            detailsView = UIView(frame: CGRect.zero)
            addSubview(detailsView)
            
            // Add necessary constraints
            detailsView.translatesAutoresizingMaskIntoConstraints = false
            
            let infoViewPadding = infoView.frame.origin.x
            
            let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(infoViewPadding)-[view]-\(infoViewPadding)-|", options: [], metrics: nil, views: ["view": detailsView])
            let bottomConstraint = NSLayoutConstraint(item: detailsView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let topConstraint = NSLayoutConstraint(item: detailsView, attribute: .top, relatedBy: .equal, toItem: infoView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            
            addConstraints(horizontalConstraint)
            addConstraints([bottomConstraint, topConstraint])
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        arrowView?.isHidden = false
        
        // Remove subviews from details view when reusing cells
        for subview in detailsView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: Update the cell's arrow image
    /// Update the image view to reset the direction of arrowView
    func updateImageForViewWithCurrentDirection(_ currentDirection: ArrowDirection) {
        var image: UIImage?
        let direction = currentDirection.getOrientationWithDefaultOrientation(arrowImageInitialDirection)
        
        // Get the current image from imageView or buttonView
        if let imageView = arrowView as? UIImageView {
            image = imageView.image
        } else if let buttonView = arrowView as? UIButton {
            image = buttonView.currentImage
        }
        
        if let image = image, let cgImage = image.cgImage {
            // Reset the image based on the direction
            let cgiImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: direction)
            
            // Update the rotated image back to view
            if let imageView = arrowView as? UIImageView {
                imageView.image = cgiImage
            } else if let buttonView = arrowView as? UIButton {
                buttonView.setImage(cgiImage, for: UIControlState())
            }
        }
    }
    
    /// Disable the selection of views that are present inside the detailsView.
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let touch = touch {
            let touchPoint = touch.location(in: detailsView)
            
            // y value will be less than 0 if selection is done on infoView. So call super to call the didSelectRow delegate method automatically. If super isn't called, then didSelectRow delegate method will not be called.
            if touchPoint.y < 0 {
                super.touchesBegan(touches, with: event)
            }
        }
    }
}
