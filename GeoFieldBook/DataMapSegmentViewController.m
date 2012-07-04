//
//  DataMapSegmentViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DataMapSegmentViewController.h"
#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"

@interface DataMapSegmentViewController()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *masterPresenter;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter=_masterPresenter;

@synthesize masterPopoverController=_masterPopoverController;

- (void)setRecordMapViewControllerMapDelegate:(id<GeoMapAnnotationProvider>)mapDelegate {
    //Set the map delegate of the record map view controller
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.mapDelegate=mapDelegate;
}

- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate {
    //Set the delegate of the record detail vc
    RecordViewController *recordDetail=[self.viewControllers objectAtIndex:0];
    recordDetail.delegate=delegate;
}

- (void)updateMapWithRecords:(NSArray *)records {
    //Set the records of the record map view controller
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.records=records;
}

- (void)updateRecordDetailViewWithRecord:(Record *)record {
    //Set the record of the record detail vc
    RecordViewController *recordDetail=[self.viewControllers objectAtIndex:0];
    recordDetail.record=record;
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //If the swapped in view controller is the record view controller put up the edit button
    RecordViewController *recordDetail=[self.viewControllers objectAtIndex:0];
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    if (!segmentIndex)
        [toolbarItems addObject:recordDetail.editButton];
    
    //Else take the edit button off
    else
        [toolbarItems removeObject:recordDetail.editButton];
    
    self.toolbar.items=[toolbarItems copy];    
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
}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Instantiate the initial view controller
    RecordViewController *recordDetail=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    
    //Instantiate the record map view controller
    RecordMapViewController *recordMap=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER];
    
    //Set the view controllers
    self.viewControllers=[NSArray arrayWithObjects:recordDetail,recordMap, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Show the initial detail view controller
    [self swapToViewControllerAtSegmentIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Present the master popover
    [self.masterPopoverController dismissPopoverAnimated:NO];
    [self.masterPopoverController presentPopoverFromBarButtonItem:self.masterPresenter permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
