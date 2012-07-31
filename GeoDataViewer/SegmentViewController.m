//
//  SegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SegmentViewController.h"

@interface SegmentViewController()

@end

@implementation SegmentViewController

@synthesize contentView=_contentView;
@synthesize viewControllers=_viewControllers;
@synthesize currentViewController=_currentViewController;

@synthesize animationOption=_animationOption;

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

- (void)showViewController:(UIViewController *)viewController withTransitionAnimationOption:(TransionAnimationOption)animationOption {
    //Add the view of the specified view controller to self's view hierachy with parent-child vc relationship callbacks
    [self addChildViewController:viewController];
    [viewController willMoveToParentViewController:self];
    
    //Adjust the frame of the specified view controller's view
    viewController.view.frame=self.contentView.bounds;
    
    if (self.currentViewController) {
        if (animationOption==TransitionAnimationFold || animationOption==TransitionAnimationUnfold) {
            MPFoldStyle style=animationOption==TransitionAnimationFold ? MPFoldStyleHorizontal : MPFoldStyleUnfold;
            [MPFoldTransition transitionFromViewController:self.currentViewController toViewController:viewController duration:0.4 style:style completion:^(BOOL finished){
                //Remove the view of the current view controller from the view hierachy
                [self.currentViewController.view removeFromSuperview];
                
                //Add the view of the new vc to the hierachy and set it as the current view controller
                [self.contentView addSubview:viewController.view];
                
                //set the new view as the current view controller
                [viewController didMoveToParentViewController:self];
                self.currentViewController=viewController;
            }];
        }
        else {
            UIViewAnimationOptions option=(animationOption!=TransitionAnimationPushLeft && animationOption!=TransitionAnimationPushRight) ? 1:0;
            if (option) 
                option=animationOption==TransitionAnimationFlipLeft ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
            else if (self.currentViewController) {
                option=UIViewAnimationOptionCurveLinear;
                CATransition *transition=[CATransition animation];
                transition.type=kCATransitionPush;
                transition.subtype=animationOption==TransitionAnimationPushLeft ? kCATransitionFromLeft : kCATransitionFromRight;
                transition.startProgress=0.2;
                [self.contentView.layer addAnimation:transition forKey:@"push-transition"];
            }
            
            [self transitionFromViewController:self.currentViewController toViewController:viewController duration:0.6 options:option animations:^{                
                //Remove the view of the current view controller from the view hierachy
                [self.currentViewController.view removeFromSuperview];
                
            } completion:^(BOOL completed){
                if (completed) {
                    //Add the view of the new vc to the hierachy and set it as the current view controller
                    [self.contentView addSubview:viewController.view];
                    
                    //set the new view as the current view controller
                    [viewController didMoveToParentViewController:self];
                    self.currentViewController=viewController;
                }
            }];
        }
    } 
    else {
        //Some transition animation
        CATransition *transition=[CATransition animation];
        transition.type=kCATransitionFade;
        transition.duration=0.4;
        [self.contentView.layer addAnimation:transition forKey:@"fade-animation"];
        
        //Adjust the frame of the specified view controller's view
        viewController.view.frame=self.contentView.bounds;
        
        //Remove the view of the current view controller from the view hierachy
        [self.currentViewController.view removeFromSuperview];
        
        //Add the view of the new vc to the hierachy and set it as the current view controller
        [self.contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        self.currentViewController=viewController;
    }
}

- (void)segmentController:(UISegmentedControl *)segmentController indexDidChangeTo:(int)newIndex {    
    //Swap the current view controller's view with the new view controller's view
    [self swapToViewControllerAtSegmentIndex:newIndex];
}

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {    
    //Get the view controller at the new segment index
    UIViewController *viewController=[self.viewControllers objectAtIndex:segmentIndex];
    
    //Show the view of the new view controller with custom animation option
    TransionAnimationOption animationOption;
    if (!self.animationOption)
        animationOption=segmentIndex ? TransitionAnimationPushRight : TransitionAnimationPushLeft;
    else
        animationOption=self.animationOption;
    
    [self showViewController:viewController withTransitionAnimationOption:animationOption];
}

- (void)popViewControllerAtSegmentIndex:(int)segmentIndex {
    //If the popped view controller is still on screen, pull it off screen
    UIViewController *viewController=[self.viewControllers objectAtIndex:segmentIndex];
    if (self.currentViewController==viewController) {
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController=nil;
    }
    
    //Remove the view controller at the specified segment index from the array of view controllers
    NSMutableArray *viewControllers=[self.viewControllers mutableCopy];
    [viewControllers removeObjectAtIndex:segmentIndex];
    self.viewControllers=[viewControllers copy];
}

- (void)pushViewController:(UIViewController *)viewController {
    //Add the specified view controller at the end of the view controller array
    [self insertViewController:viewController atSegmentIndex:[self.viewControllers count]];
}

- (void)insertViewController:(UIViewController *)viewController atSegmentIndex:(int)segmentIndex {
    //Insert the specified view controller at the specified index in the view controller array
    NSMutableArray *viewControllers=[self.viewControllers mutableCopy];
    [viewControllers insertObject:viewController atIndex:segmentIndex];
    self.viewControllers=[viewControllers copy];
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
