//
//  HomeViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeMasterViewController.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation HomeViewController
@synthesize toolbar = _toolbar;

@synthesize delegate=_delegate;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    //Get the array of bar button items in the toolbar
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    
    //Remove the old button if it's not nil
    if (self.splitViewBarButtonItem)
        [toolbarItems removeObject:self.splitViewBarButtonItem];
    
    //If the new button is not nil, add it to the toolbar on the leftmost
    if (splitViewBarButtonItem)
        [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    
    //Set the toolbar items
    self.toolbar.items=[toolbarItems copy];
    
    _splitViewBarButtonItem=splitViewBarButtonItem;
}

#pragma mark - Target-Action Handlers

- (IBAction)sModeSelected:(UIButton *)sender {
    [self.delegate homeViewController:self userDidSelect:S_MODE];
}

- (IBAction)gModeSelected:(UIButton *)sender {
    [self.delegate homeViewController:self userDidSelect:G_MODE];
}

#pragma mark - View Controller Lifecycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
