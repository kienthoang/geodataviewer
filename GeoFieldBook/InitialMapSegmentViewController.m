//
//  InitialMapSegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "InitialMapSegmentViewController.h"
#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"

@interface InitialMapSegmentViewController() 

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *masterPresenter;

@end

@implementation InitialMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter=_masterPresenter;

@synthesize masterPopoverController=_masterPopoverController;

- (void)setRecordMapViewControllerMapDelegate:(id<GeoMapAnnotationProvider>)mapDelegate {    
    //Set the map delegate of the record map view controller
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.mapDelegate=mapDelegate;    
}

- (void)updateMapWithRecords:(NSArray *)records {
    //Set the records of the record map view controller
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.records=records;
}

#pragma mark - Target-Action Handlers

- (IBAction)presentMaster:(UIBarButtonItem *)sender {
    if (self.masterPopoverController) {
        //Dismiss the formation folder popover if it's visible on screen
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Present the master popover
        [self.masterPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
}

- (IBAction)dataMapSegmentIndexDidChange:(UISegmentedControl *)sender {
    //Update the segment index
    [self segmentController:sender indexDidChangeTo:sender.selectedSegmentIndex];
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Seguing to the modal formation folder tvc
    if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
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
    
    //Seguing to the data map segment controller
    else if ([segue.identifier isEqualToString:@"Data Map Segment Controller"]) {
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

}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Instantiate the initial view controller
    InitialDetailViewController *initialDetail=[self.storyboard instantiateViewControllerWithIdentifier:INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    
    //Instantiate the record map view controller
    RecordMapViewController *recordMap=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER];
    
    //Set the view controllers
    self.viewControllers=[NSArray arrayWithObjects:initialDetail,recordMap, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Show the initial detail view controller
    [self swapToViewControllerAtSegmentIndex:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
