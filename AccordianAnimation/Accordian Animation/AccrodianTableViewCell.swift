//
//  AccrodianTableViewCell.swift
//  AccordianAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

class AccrodianTableViewCell: UITableViewCell {
    /** **Important: The Height constraint has to be set for infoView instead of bottom constraint** 
    
    Info view should be the container view holding all the views as subviews that represent the cell in unexpanded state */
    @IBOutlet weak var infoView: UIView!
    
    /// Details view is the container view holding all the views as subviews that represent the cell in expanded state (View controller data)
    var detailsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Check if infoView is set or not. If not do not proceed further
        assert(infoView != nil, "InfoView cannot be nil")
        
        // Create details view
        if detailsView == nil {
            detailsView = UIView(frame: CGRectZero)
            addSubview(detailsView)
            
            // Add necessary constraints
            detailsView.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view" : detailsView])
            let bottomConstraint = NSLayoutConstraint(item: detailsView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
            let topConstraint = NSLayoutConstraint(item: detailsView, attribute: .Top, relatedBy: .Equal, toItem: infoView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
            
            addConstraints(horizontalConstraint)
            addConstraints([bottomConstraint, topConstraint])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove subviews from details view when reusing cells
        for subview in detailsView.subviews {
            subview.removeFromSuperview()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
