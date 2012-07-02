//
//  InitialDetailViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "InitialDetailViewController.h"
#import "RecordViewController.h"
#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"

@interface InitialDetailViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIImageView *geofieldbookLogo;

@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *masterPresenter;

@end

@implementation InitialDetailViewController

@synthesize toolbar=_toolbar;
@synthesize geofieldbookLogo = _geofieldbookLogo;

@synthesize masterPopoverController=_masterPopoverController;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter = _masterPresenter;

- (IBAction)presentMaster:(UIBarButtonItem *)sender {
    if (self.masterPopoverController) {
        //Dismiss the formation folder popover if it's visible on screen
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Present the master popover
        [self.masterPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a record view controller
    if ([segue.identifier isEqualToString:@"Show Record Info"]) {
        if (self.masterPopoverController) 
        {
            //Dismiss the master popover if it's visible on the screen
            if (self.masterPopoverController.isPopoverVisible)
                [self.masterPopoverController dismissPopoverAnimated:NO];
            
            //Transfer the master popover over
            UIPopoverController *masterPopoverController=[[UIPopoverController alloc] initWithContentViewController:self.masterPopoverController.contentViewController];
            masterPopoverController.delegate=nil;
            [segue.destinationViewController setMasterPopoverController:masterPopoverController];
        }
    }
    
    //Seguing to the modal formation folder tvc
    else if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        //Dismiss the master popover if it's visible on the screen
        if (self.masterPopoverController.isPopoverVisible)
            [self.masterPopoverController dismissPopoverAnimated:NO];
        
        //Get the destination view controller
        UINavigationController *navigationController=segue.destinationViewController;
        FormationFolderTableViewController *destinationViewController=(FormationFolderTableViewController *)navigationController.topViewController;
        
        //Dismiss the old popover if its still visible
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Save the popover
        self.formationFolderPopoverController=[(UIStoryboardPopoverSegue *)segue popoverController];
        
        //Get the shared database
        UIManagedDocument *database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
        
        //Open the database if it's still closed
        if (database.documentState==UIDocumentStateClosed) {
            [database openWithCompletionHandler:^(BOOL success){
                destinationViewController.database=database;
            }];
        } else if (database.documentState==UIDocumentStateNormal) {
            destinationViewController.database=database;
        }
    }
}

#pragma mark - View Controller Lifecycles

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Center the geofieldbook logo
    CGRect frame=self.geofieldbookLogo.frame;
    CGFloat centerX=(self.view.bounds.size.width-frame.size.width)/2;
    CGFloat centerY=(self.view.bounds.size.height-frame.size.height)/2;
    self.geofieldbookLogo.frame=CGRectMake(centerX, centerY, frame.size.width, frame.size.height); 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setGeofieldbookLogo:nil];
    [self setMasterPresenter:nil];
    [super viewDidUnload];
}
@end
