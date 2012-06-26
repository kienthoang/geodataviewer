//
//  HomeMasterViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "HomeMasterViewController.h"
#import "HomeViewController.h"
#import "FolderTableViewController.h"
#import "UISplitViewBarButtonPresenter.h"

@interface HomeMasterViewController() <HomeViewControllerDelegate>

@end

@implementation HomeMasterViewController

#pragma mark - HomeViewController delegate methods

- (void)homeViewController:(HomeViewController *)sender 
             userDidSelect:(NSString *)mode 
{
    //If user selected G-mode, segue to G mode
    if ([mode isEqualToString:G_MODE])
        [self performSegueWithIdentifier:@"G mode" sender:self];
    
    //If user selected S-mode, segue to S-mode
    else if ([mode isEqualToString:S_MODE])
        [self performSegueWithIdentifier:@"S mode" sender:self];
}
#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set self as the delegate of the split view
    id detailvc=[self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[HomeViewController class]]) {
        HomeViewController *detail=detailvc;
        detail.delegate=self;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
