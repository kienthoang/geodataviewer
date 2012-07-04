//
//  GeoSegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoSegmentViewController.h"

@interface GeoSegmentViewController()

@property (nonatomic,strong) UIViewController *currentViewController;

@end

@implementation GeoSegmentViewController

@synthesize contentView=_contentView;
@synthesize viewControllers=_viewControllers;
@synthesize currentViewController=_currentViewController;

#pragma mark - Getters and Setters

- (UIViewController *)topViewController {
    return self.currentViewController;
}

- (NSArray *)viewControllers {
    if (!_viewControllers)
        _viewControllers=[NSArray array];
    
    return _viewControllers;
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)showViewController:(UIViewController *)viewController {
    //Adjust the frame of the specified view controller's view
    viewController.view.frame=self.contentView.bounds;
    
    //Add the view of the specified view controller to self's view hierachy with parent-child vc relationship callbacks
    [self addChildViewController:viewController];

    //Remove the view of the current view controller from the view hierachy
    [self.currentViewController.view removeFromSuperview];
    
    //Add the view of the new vc to the hierachy and set it as the current view controller
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentViewController=viewController;
}

- (void)segmentController:(UISegmentedControl *)segmentController indexDidChangeTo:(int)newIndex {    
    //Swap the current view controller's view with the new view controller's view
    [self swapToViewControllerAtSegmentIndex:newIndex];
}

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {    
    //Get the view controller at the new segment index
    UIViewController *viewController=[self.viewControllers objectAtIndex:segmentIndex];
    
    //Show the view of the new view controller
    [self showViewController:viewController];
}

- (void)popViewControllerAtSegmentIndex:(int)segmentIndex {
    //Remove the view controller at the specified segment index from the array of view controllers
    
}

- (void)pushViewController:(UIViewController *)viewController {
    //Add the specified view controller at the end of the view controller array
    [self insertViewController:viewController atSegmentIndex:[self.viewControllers count]];
}

- (void)insertViewController:(UIViewController *)viewController atSegmentIndex:(int)segmentIndex {
    //Insert the specified view controller at the specified index in the view controller array
    
}

- (void)replaceViewControllerAtSegmentIndex:(int)segmentIndex withViewController:(UIViewController *)viewController {
    //Pop the view controller at the specified segment index
    [self popViewControllerAtSegmentIndex:segmentIndex];
    
    //Insert the new view controller at that index
    [self insertViewController:viewController atSegmentIndex:segmentIndex];
}

#pragma mark - View Controller Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
