//
//  CustomSplitViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomSplitViewController.h"

@interface CustomSplitViewController()

@property (nonatomic,strong) IBOutlet UIView *masterView;
@property (nonatomic,strong) IBOutlet UIView *detailView;

@end

@implementation CustomSplitViewController

@synthesize masterViewController=_masterViewController;
@synthesize detailViewController=_detailViewController;

@synthesize masterView=_masterView;
@synthesize detailView=_detailView;

#pragma mark - Prepare for Segues

- (void)prepareMasterSideForViewController:(UIViewController *)viewController {    
    //Connect to the master tvc
    self.masterViewController=viewController;
    if ([self.masterViewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)])
        [(id<CustomSplitViewControllerChildren>)self.masterViewController setCustomSplitViewController:self];
    
    //Add the master table view to the left side view
    UIViewController *masterViewController=self.masterViewController;
    [masterViewController willMoveToParentViewController:self];
    masterViewController.view.frame=self.masterView.bounds;
    [self.masterView addSubview:masterViewController.view];
    [masterViewController didMoveToParentViewController:self];
}

- (void)prepareDetailSideForViewController:(UITableViewController *)viewController {    
    //Connect to the master tvc
    self.detailViewController=viewController;
    if ([viewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)])
        [(id<CustomSplitViewControllerChildren>)viewController setCustomSplitViewController:self];

    //Add the master table view to the left side view
    UIViewController *detailViewController=self.detailViewController;
    [detailViewController willMoveToParentViewController:self];
    detailViewController.view.frame=self.detailView.bounds;
    [self.detailView addSubview:detailViewController.view];
    [detailViewController didMoveToParentViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Custom segues
    if ([segue.identifier isEqualToString:CustomSplitViewControllerMasterSegueIdentifier])
        [self prepareMasterSideForViewController:segue.destinationViewController];
    else if ([segue.identifier isEqualToString:CustomSplitViewControllerDetailSegueIdentifier])
        [self prepareDetailSideForViewController:segue.destinationViewController];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Perform segues to initialize the two view controllers this vc controls
    [self performSegueWithIdentifier:CustomSplitViewControllerMasterSegueIdentifier sender:nil];
    [self performSegueWithIdentifier:CustomSplitViewControllerDetailSegueIdentifier sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
