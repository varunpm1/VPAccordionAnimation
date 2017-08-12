# VPAccordionAnimation

This is a custom class that provides Accordion Animation for cells expanding and collapsing. i.e., expanding or collapsing of cells with auto adjust to center of view. The expanded cell can contain views data or a complete view controller's data.

## IMP

Now VPAccordionAnimation supports Swift 3.0. It now needs XCode 8 or later to build.

## Requirements

1. iOS 7.0 or later.
2. ARC memory management.

## Usage

1. Add the VPAccordionAnimation folder inside your project folder (Contains 4 files. Cell nib file only if customization is not needed. If you have a cell, which is a subclass of VPAccordionAnimationCell, then this file is not needed.)
2. Change the parent class of the view controller containing tableView to VPAccordionAnimationViewController. If there is a BaseVC, then change the parent of VPAccordionAnimationViewController to BaseVC
3. Call function - 

`createAccordionDataForIndexPaths(withViewOrControllerData viewData: [AnyObject], forTableView tableView : UITableView)`

OR

`createAccordionDataForIndexPaths(indexPaths: [NSIndexPath], withViewOrControllerData viewData: [AnyObject], forTableView tableView : UITableView)`

for populating the view or viewController data in viewDidLoad().

4. Change the parent class of tableView cell to VPAccordionTableViewCell
5. Add a container view inside the tableView cell and connect the outlet to VPAccordionTableViewCell’s infoView outlet
6. Add all the necessary views that are needed inside the tableViewCells, inside the infoView (as subViews to infoView)
7. Add Constraints to infoView - Leading, Trailing, Top and Height - Do not add bottom constraint
8. If an animation is required for arrow view, then connect it to the arrowView outlet in VPAccordionTableViewCell. Set the arrowImageInitialDirection and arrowImageFinalDirection in subclass
9. You can specify the other optional variables for adding extra functionalities like animation duration, arrowView rotation direction, etc.

# ![Screenshot](/VPAccordionAnimation-Screenshot1.png) ![Screenshot](/VPAccordionAnimation-Screenshot2.png)


Here are some of the customizable properties that can be used to handle animations and UI display type.


### AccordionAnimationController subclassed properties

You can define the close and open duration speed using the below properties -

`var closeAnimationDuration : TimeInterval {get set}`
`var openAnimationDuration : TimeInterval {get set}`


You can create the load state for cell on loading using below property - You can either set expanded all or collapsed all. Defaults to collapsed all

`var cellDefaultState : DefaultState {get set}`


If multiple cell expansion is needed, then set below variable to true

`var multipleCellExpansionEnabled : Bool {get set}`


When a cell is expanded, if scrolling of tableView has to be enabled, then use the below property.

`var tableViewScrollEnabledWhenExpanded : Bool {get set}`


You can specify the rotation direction for arrow view (if present, clockwise or anti-clockwise) using the below property

`var arrowRotationDirection : ArrowRotation {get set}`


### AccordionAnimationTableViewCell subclassed properties

If there is an arrow view, you can specify start and end direction of arrow so as to handle the animation by Accordion Animation protocol

`var arrowImageInitialDirection : ArrowDirection = .right`
`var arrowImageFinalDirection : ArrowDirection = .down`



## Contributing
**Type - 1**

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

**Type - 2**

1. Create an issue
2. I'll try to add the necessry feature
3. You can download the update code :P

## History

### Version 2.1.1
Fixed the offset issue which causes slight flicking when collapsing the cells

### Version 2.1.0
Fixed layout issue when using UITablewViewAutomaticDimension for cells

### Version 2.0.0
This version now support Swift 3.0. If you're using XCode lesser than 8, please use the Version 1.3.0 release since this now needs XCode 8 to build and run.

### Version 1.3.0
Removed common code facilitating easier integration of AccordionAnimation. Default cells will be added if no customization is needed. Override UITableViewDataSource or UITableViewDelegate methods if needed (like specifying different cell height while expanded, cells content etc.). Default height is entire view height when expanded.

### Version 1.2.2
Added support for shadow for bottom screenshot, if needed, and code cleaning.

### Version 1.2.1
Code cleaning and added support for disabling cell selection when expanded, if needed.

### Version 1.2.0
Added support for expanding or collapsing of view or view controller's view as needed and code cleaning.

### Version 1.1.0
Added support for multiple cell expansion and enabled scrolling if variable is set.

### Version 1.0.0
Basic Accordion animation classes added and handled arrow view animation.

## License
The MIT License (MIT)

Copyright (c) 2016 Varun P M

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
