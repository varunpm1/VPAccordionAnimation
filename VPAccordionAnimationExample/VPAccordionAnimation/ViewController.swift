//
//  ViewController.swift
//  VPAccordionAnimationExample
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 VPM. All rights reserved.
//

import UIKit

class ViewController: VPAccordionAnimationViewController {
    
    @IBOutlet weak var sampleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        edgesForExtendedLayout = UIRectEdge()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController1 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController2 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController3 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController4 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController5 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController6 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController7 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        let viewController8 = storyboard.instantiateViewController(withIdentifier: "sampleVCId")
        
        createAccordionDataForIndexPaths(withViewOrControllerData: [viewController1, viewController2, viewController3, viewController4, viewController5, viewController6, viewController7, viewController8], forTableView: sampleTableView)
        
        sampleTableView.register(UINib(nibName: "SampleTableViewCell", bundle: nil), forCellReuseIdentifier: "SampleTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override necessary delegate or datasource as needed. Else default functionality will be implemented.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SampleTableViewCell") as! SampleTableViewCell
        cell.displayLabel?.text = "Row \((indexPath as NSIndexPath).row + 1)"
        
        return cell
    }
}
