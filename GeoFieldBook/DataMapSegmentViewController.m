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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter=_masterPresenter;
@synthesize dataMapSwitch = _dataMapSwitch;
@synthesize importExportButton = _importExportButton;
@synthesize formationButton = _formationButton;

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

- (void)selectRecordInMap:(Record *)record {
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.selectedRecord=record;
}

#pragma mark - UISplitViewBarButtonPresenter protocol methods

- (void)presentMasterPopover {
    [self.masterPopoverController presentPopoverFromBarButtonItem:self.masterPresenter permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    
    //Be sure the UISegmentControl show the correct segment index
    self.dataMapSwitch.selectedSegmentIndex=segmentIndex;
}

- (void)pushRecordViewController {
    //Replace the current data view controller with the record view controller
    RecordViewController *recordDetail=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    [self replaceViewControllerAtSegmentIndex:0 withViewController:recordDetail];
}

- (void)pushInitialViewController {    
    InitialDetailViewController *initialDetail=[self.storyboard instantiateViewControllerWithIdentifier:INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    [self replaceViewControllerAtSegmentIndex:0 withViewController:initialDetail];
}

#pragma mark - Target-Action Handlers

- (IBAction)presentMaster:(UIButton *)sender {
    if (self.masterPopoverController) {
        //Dismiss the formation folder popover if it's visible on screen
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Present the master popover
        [self.masterPopoverController presentPopoverFromBarButtonItem:self.masterPresenter permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
}

- (IBAction)formationButtonPressed:(UIButton *)sender {
    //Segue to the formation folder popover
    [self performSegueWithIdentifier:@"Show Formation Folders" sender:self.formationButton];
}

- (IBAction)importExportButtonPressed:(UIButton *)sender {
    //Show UIActionSheet with import/export options
    UIActionSheet *importExportActionSheet=[[UIActionSheet alloc] initWithTitle:@"Import/Export" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import Records",@"Export Records",@"Import Formations",@"Export Formations", nil];
    [importExportActionSheet showInView:self.contentView];
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
    
    //Change the look of the master presenter
    UIButton *masterPresenterCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [masterPresenterCustomView setImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
    masterPresenterCustomView.frame=CGRectMake(0, 0, 32, 32);
    [masterPresenterCustomView addTarget:self action:@selector(presentMaster:) forControlEvents:UIControlEventTouchUpInside];
    masterPresenterCustomView.showsTouchWhenHighlighted=YES;
    self.masterPresenter.customView=masterPresenterCustomView;
    
    //Change the look of the import/export button
    UIButton *importExportCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [importExportCustomView setImage:[UIImage imageNamed:@"import-export.png"] forState:UIControlStateNormal];
    importExportCustomView.frame=CGRectMake(0, 0, 25, 25);
    [importExportCustomView addTarget:self action:@selector(importExportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    importExportCustomView.showsTouchWhenHighlighted=YES;
    self.importExportButton.customView=importExportCustomView; 
    
    //Change the look of the formation button
    UIButton *formationButtonCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [formationButtonCustomView setImage:[UIImage imageNamed:@"formation.png"] forState:UIControlStateNormal];
    formationButtonCustomView.frame=CGRectMake(0, 0, 32, 32);
    [formationButtonCustomView addTarget:self action:@selector(formationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    formationButtonCustomView.showsTouchWhenHighlighted=YES;
    self.formationButton.customView=formationButtonCustomView;
    
    //Show the initial detail view controller
    [self swapToViewControllerAtSegmentIndex:0];
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
