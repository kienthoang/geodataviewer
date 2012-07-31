//
//  UIDoubleTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "UIDoubleTableViewController.h"

@interface UIDoubleTableViewController()

@property (nonatomic,strong) IBOutlet UIView *masterTableView;
@property (nonatomic,strong) IBOutlet UIView *detailTableView;

@end

@implementation UIDoubleTableViewController

@synthesize masterTableViewController=_masterTableViewController;
@synthesize detailTableViewController=_detailTableViewController;

@synthesize masterTableView=_masterTableView;
@synthesize detailTableView=_detailTableView;

#pragma mark - Prepare for Segues

- (void)prepareMasterSideForViewController:(UITableViewController *)viewController {    
    //Connect to the master tvc
    self.masterTableViewController=viewController;
    if ([self.masterTableViewController conformsToProtocol:@protocol(UIDoubleTableViewControllerChildren)])
        [(UITableViewController<UIDoubleTableViewControllerChildren> *) self.masterTableViewController setDoubleTableViewController:self];
    
    //Add the master table view to the left side view
    UITableViewController *masterTableViewController=self.masterTableViewController;
    [masterTableViewController willMoveToParentViewController:self];
    masterTableViewController.tableView.frame=self.masterTableView.bounds;
    [self.masterTableView addSubview:masterTableViewController.tableView];
    [masterTableViewController didMoveToParentViewController:self];
}

- (void)prepareDetailSideForViewController:(UITableViewController *)viewController {    
    //Connect to the master tvc
    self.detailTableViewController=viewController;
    if ([self.detailTableViewController conformsToProtocol:@protocol(UIDoubleTableViewControllerChildren)])
        [(UITableViewController<UIDoubleTableViewControllerChildren> *) self.detailTableViewController setDoubleTableViewController:self];
    
    //Add the master table view to the left side view
    UITableViewController *detailTableViewController=self.detailTableViewController;
    [detailTableViewController willMoveToParentViewController:self];
    detailTableViewController.tableView.frame=self.detailTableView.bounds;
    [self.detailTableView addSubview:detailTableViewController.tableView];
    [detailTableViewController didMoveToParentViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Custom segues
    if ([segue.identifier isEqualToString:DoubleTableViewControllerMasterSegueIdentifier])
        [self prepareMasterSideForViewController:segue.destinationViewController];
    else if ([segue.identifier isEqualToString:DoubleTableViewControllerDetailSegueIdentifier])
        [self prepareDetailSideForViewController:segue.destinationViewController];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Perform segues to initialize the two view controllers this vc controls
    [self performSegueWithIdentifier:DoubleTableViewControllerMasterSegueIdentifier sender:nil];
    [self performSegueWithIdentifier:DoubleTableViewControllerDetailSegueIdentifier sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
