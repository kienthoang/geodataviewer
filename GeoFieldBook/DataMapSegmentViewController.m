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
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataMapSwitch;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter=_masterPresenter;
@synthesize dataMapSwitch = _dataMapSwitch;

@synthesize masterPopoverController=_masterPopoverController;

#pragma mark - Getters and Setters

- (UIViewController *)detailSideViewController {
    return [self.viewControllers objectAtIndex:0];
}

#pragma mark - Data Forward Mechanisms

- (void)setRecordMapViewControllerMapDelegate:(id<GeoMapAnnotationProvider>)mapDelegate {
    //Set the map delegate of the record map view controller
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.mapDelegate=mapDelegate;
}

- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate {
    //Set the delegate of the record detail vc if it's in the view controller array
    id recordDetail=[self.viewControllers objectAtIndex:0];
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setDelegate:delegate];
}

- (void)updateMapWithRecords:(NSArray *)records {
    //Set the records of the record map view controller if it's in the view controller array
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.records=records;
}

- (void)updateRecordDetailViewWithRecord:(Record *)record {
    //Set the record of the record detail vc
    id recordDetail=[self.viewControllers objectAtIndex:0];
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setRecord:record];
}

- (void)putRecordViewControllerIntoEditingMode {
    //Swap to the record view controller if it's not the current view controller
    if (self.topViewController!=[self.viewControllers objectAtIndex:0])
        [self swapToViewControllerAtSegmentIndex:0];
    
    //Change the selected index of the UISegmentControl
    self.dataMapSwitch.selectedSegmentIndex=0; 
    
    //Put the record view controller into edit mode
    RecordViewController *recordDetail=(RecordViewController *)self.topViewController;
    [recordDetail setEditing:YES animated:YES];
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //If the swapped in view controller is the record view controller put up the edit button
    id dataDetail=[self.viewControllers objectAtIndex:0];
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    if ([dataDetail isKindOfClass:[RecordViewController class]]) {
        RecordViewController *recordDetail=(RecordViewController *)dataDetail;
        
        if (!segmentIndex)
            [toolbarItems addObject:recordDetail.editButton];
        else
            [toolbarItems removeObject:recordDetail.editButton];
    }
    
    //If the button on the rightmost of the toolbar is the edit button, take it off
    else {
        UIBarButtonItem *rightMostButton=[toolbarItems lastObject];
        if ([rightMostButton.title isEqualToString:@"Edit"] || [rightMostButton.title isEqualToString:@"Done"])
            [toolbarItems removeObject:rightMostButton];
    }
    
    //Set the tolbar
    self.toolbar.items=[toolbarItems copy];  
}

- (void)pushRecordViewController {
    //Replace the current data view controller with the record view controller
    RecordViewController *recordDetail=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    [self replaceViewControllerAtSegmentIndex:0 withViewController:recordDetail];
}

- (void)pushInitialViewController {
    //
    
    InitialDetailViewController *initialDetail=[self.storyboard instantiateViewControllerWithIdentifier:INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    [self replaceViewControllerAtSegmentIndex:0 withViewController:initialDetail];
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

- (void)viewDidUnload {
    [self setDataMapSwitch:nil];
    [super viewDidUnload];
}
@end
