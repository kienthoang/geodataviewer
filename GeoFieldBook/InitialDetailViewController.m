//
//  InitialDetailViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "InitialDetailViewController.h"

@interface InitialDetailViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation InitialDetailViewController

@synthesize toolbar=_toolbar;

@synthesize masterPopoverController=_masterPopoverController;

- (IBAction)presentMaster:(UIBarButtonItem *)sender {
    if (self.masterPopoverController)
        [self.masterPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a record view controller
    if ([segue.identifier isEqualToString:@"Show Record Info"]) {
        //Transfer the master popover over
        if (self.masterPopoverController)
            [segue.destinationViewController setMasterPopoverController:self.masterPopoverController];
        
        
    }
}

#pragma mark - View Controller Lifecycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
