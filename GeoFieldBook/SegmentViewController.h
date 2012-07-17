//
//  SegmentViewController.h
//  GeoFieldBook
//
//  THIS IS A CONTAINER VIEW CONTROLLER
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SegmentViewController : UIViewController

@property (nonatomic,strong) IBOutlet UIView *contentView;
@property (nonatomic,strong) NSArray *viewControllers;
@property (nonatomic,readonly) UIViewController *topViewController;

typedef enum TransitionAnimationOption {TransitionAnimationPushLeft,TransitionAnimationPushRight,TransitionAnimationFlipLeft,TransitionAnimationFlipRight,TransitionAnimationFold,TransitionAnimationUnfold} TransionAnimationOption;

@property (nonatomic) TransionAnimationOption animationOption;

- (void)segmentController:(UISegmentedControl *)segmentController indexDidChangeTo:(int)newIndex;
- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex;
- (void)popViewControllerAtSegmentIndex:(int)segmentIndex;
- (void)pushViewController:(UIViewController *)viewController;
- (void)insertViewController:(UIViewController *)viewController atSegmentIndex:(int)segmentIndex;
- (void)replaceViewControllerAtSegmentIndex:(int)segmentIndex withViewController:(UIViewController *)viewController;

@end
