//
//  AccordianAnimationViewController.swift
//  AccordianAnimation
//
//  Created by Varun on 28/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

class AccordianAnimationViewController: UIViewController, AccordianAnimationProtocol {
    
    var selectedIndexPath : NSIndexPath?
    var animationCompletionBlock: AccordianAnimationCompletionBlock?
    
    var arrowImageFinalDirection: ArrowDirection = .Down
    var arrowImageCurrentDirection: ArrowDirection = .Right
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        animationCompletionBlock = { [weak self] in
            if self == nil {
                return
            }
            
            // Swap the arrow direction values for reversing the animation of the cells
            swap(&self!.arrowImageCurrentDirection, &self!.arrowImageFinalDirection)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
