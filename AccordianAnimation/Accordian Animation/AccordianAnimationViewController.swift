//
//  AccordianAnimationViewController.swift
//  AccordianAnimation
//
//  Created by Varun on 28/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

class AccordianAnimationViewController: UIViewController, AccordianAnimationProtocol {
    
    var expandedIndexPath : NSIndexPath?
    var animationCompletionBlock: AccordianAnimationCompletionBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
