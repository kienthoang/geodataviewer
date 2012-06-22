//
//  RecordViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RecordViewController() <UISplitViewControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

@end

@implementation RecordViewController

@synthesize toolbar=_toolbar;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    //Add the button to the toolbar
    NSMutableArray *items=[self.toolbar.items mutableCopy];
    
    //Remove the old button if it exists
    if (self.splitViewBarButtonItem)
        [items removeObject:self.splitViewBarButtonItem];
    
    //Add the new button on the leftmost if it's not nil
    if (splitViewBarButtonItem)
        [items insertObject:splitViewBarButtonItem atIndex:0];
    
    //Set the items to be the toolbar's items
    self.toolbar.items=[items copy];
        
    _splitViewBarButtonItem=splitViewBarButtonItem; 
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)newMaster animated:(BOOL)animated {
    //Change the splitview button's title if it exists
    if (self.splitViewBarButtonItem)
        self.splitViewBarButtonItem.title=newMaster.navigationItem.title;
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view. (automatically added by xcode)
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //Set self to be the split vc's delegate to control the button dance
    self.splitViewController.delegate=self;
    
    //Set self to be the master's navigation controller's delegate to change the button's title when a push segue in master happens
    UINavigationController *masterNavigation=[self.splitViewController.viewControllers objectAtIndex:0];
    masterNavigation.delegate=self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UISplitViewControllerDelegate methods

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)navigation withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    //Get the current master view controller and set the butotn's title to its title
    UIViewController *master=[(UINavigationController *)navigation topViewController];
    barButtonItem.title=master.navigationItem.title;
    
    self.splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

@end
