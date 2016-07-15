//
//  ViewController.swift
//  VPAccordionAnimationExample
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 VPM. All rights reserved.
//

import UIKit

class ViewController: VPAccordionAnimationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        edgesForExtendedLayout = .None
        
        
        for row in 0.stride(to: 10, by: 1) {
            populateIndexPathsDataForIndexPath(NSIndexPath(forRow: row, inSection: 0), isViewControllerNeeded: true)
        }
        
        tableView.registerNib(UINib(nibName: "SampleTableViewCell", bundle: nil), forCellReuseIdentifier: "SampleTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func createViewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("sampleVCId")
        
        return viewController
    }
    
    // Override necessary delegate or datasource as needed. Else default functionality will be implemented.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SampleTableViewCell") as! SampleTableViewCell
        cell.displayLabel?.text = "Row \(indexPath.row + 1)"
        
        return cell
    }
}