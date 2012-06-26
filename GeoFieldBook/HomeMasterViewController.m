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

@interface HomeMasterViewController() <HomeViewControllerDelegate,UISplitViewControllerDelegate>

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

//Get the detail view if it implements the protocol UISplitViewBarButtonPresenter
- (id <UISplitViewBarButtonPresenter>)getBarButtonPresenter {
    id detailvc=[self.splitViewController.viewControllers lastObject];
    
    if (![detailvc conformsToProtocol:@protocol(UISplitViewBarButtonPresenter)])
        detailvc=nil;
    
    return detailvc;
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"G mode"] || [segue.identifier isEqualToString:@"S mode"]) {
        //Change the name of the bar button presenter item
        [self getBarButtonPresenter].splitViewBarButtonItem.title=[segue.destinationViewController navigationItem].title;
        [self getBarButtonPresenter].splitViewBarButtonItem.style=UIBarButtonItemStyleBordered;
        
        //Transfer the bar button item that pops up the controller over to the destination controller
        [segue.destinationViewController setBarButtonItem:[self getBarButtonPresenter].splitViewBarButtonItem];
        self.splitViewController.delegate=segue.destinationViewController;
    }
}

#pragma mark - View Controller Lifecycles

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //set self to be split vc's delegate
    self.splitViewController.delegate=self;
}

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

#pragma mark - UISplitViewControllerDelegate methods

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    //Put the button up
    barButtonItem.style=UIBarButtonItemStylePlain;
    [self getBarButtonPresenter].splitViewBarButtonItem=barButtonItem;
}

@end
