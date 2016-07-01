//
//  ViewController.swift
//  AccordionAnimation
//
//  Created by Varun on 23/06/16.
//  Copyright © 2016 YMediaLabs. All rights reserved.
//

import UIKit

class ViewController: AccordionAnimationViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableFooterView = UIView()
        edgesForExtendedLayout = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getNumberOfSectionsInTableView() -> Int {
        return 1
    }
    
    override func getNumberOfRowsInTableViewForSection(section : Int) -> Int {
        return 50
    }
    
    override func createViewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("sampleVCId")
        
        return viewController
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCellId") as! CustomTableViewCell
        cell.displayLabel?.text = "Row \(indexPath.row + 1)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isIndexPathExpanded(indexPath) {
            return 340
        }
        else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if isIndexPathExpanded(indexPath) {
            self.hideViewOrController(inTableView: tableView, forIndexPath: indexPath, callBack: nil)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("sampleVCId")
            self.showViewController(viewController, inTableView: tableView, forIndexPath: indexPath, callBack: nil)
        }
    }
}