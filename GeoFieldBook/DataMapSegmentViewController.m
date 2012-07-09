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
#import "ModelGroupNotificationNames.h"

@interface DataMapSegmentViewController()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataMapSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize dataMapSwitch = _dataMapSwitch;
@synthesize importExportButton = _importExportButton;
@synthesize formationButton = _formationButton;
@synthesize settingButton = _settingButton;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (UIViewController *)detailSideViewController {
    return [self.viewControllers objectAtIndex:0];
}

#pragma mark - Data Forward Mechanisms

- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate {
    //Set the delegate of the record detail vc if it's in the view controller array
    id recordDetail=[self.viewControllers objectAtIndex:0];
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setDelegate:delegate];
}

- (void)setMapViewDelegate:(id<RecordMapViewControllerDelegate>)mapDelegate {
    //Set the map delegate of the map vc
    id mapDetail=[self.viewControllers lastObject];
    if ([mapDetail isKindOfClass:[RecordMapViewController class]])
        [(RecordMapViewController *)mapDetail setMapDelegate:mapDelegate];
}

- (void)updateMapWithRecords:(NSArray *)records {
    //Set the records of the record map view controller if it's in the view controller array
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    recordMap.records=records;
}

- (void)setMapSelectedRecord:(Record *)selectedRecord {
    if ([self.viewControllers.lastObject isKindOfClass:[RecordMapViewController class]]) {
        RecordMapViewController *mapDetail=(RecordMapViewController *)self.viewControllers.lastObject;
        mapDetail.selectedRecord=selectedRecord;
    }
}

- (void)updateRecordDetailViewWithRecord:(Record *)record {
    //Set the record of the record detail vc
    id recordDetail=self.detailSideViewController;
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setRecord:record];
}

- (void)putRecordViewControllerIntoEditingMode {
    //Swap to the record view controller if it's not the current view controller
    if (self.topViewController!=[self.viewControllers objectAtIndex:0])
        [self swapToViewControllerAtSegmentIndex:0];
    
    //Put the record view controller into edit mode
    RecordViewController *recordDetail=(RecordViewController *)self.topViewController;
    [recordDetail setEditing:YES animated:YES];
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //Allow the delegate (the big controller) to jump in
    [self.delegate dataMapSegmentController:self isSwitchingToViewController:[self.viewControllers objectAtIndex:segmentIndex]];
}

- (void)pushRecordViewController {
    [self performSegueWithIdentifier:@"Record View Controller" sender:nil];
}

- (void)pushInitialViewController {    
    [self performSegueWithIdentifier:@"Initial View Controller" sender:nil];
}

#pragma mark - KVO/NSNotification Managers

- (void)modelGroupUserDidSelectRecord:(NSNotification *)notification {
    //Get the selected record
    Record *selectedRecord=[notification.userInfo objectForKey:GeoNotificationKeyModelGroupSelectedRecord];
    
    //Push the detail view if it's not in the array of view controllers yet
    if (![self.detailSideViewController isKindOfClass:[RecordViewController class]]) {
        [self pushRecordViewController];
        
        //Swap to the record view controller if no view controller is currently taking the screen
        if (!self.topViewController)
            [self swapToViewControllerAtSegmentIndex:0];
    }
    
    //Update the detail side
    [self updateRecordDetailViewWithRecord:selectedRecord];
    
    //Update the map
    [self setMapSelectedRecord:selectedRecord];
}

- (void)registerForModelGroupNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupUserDidSelectRecord:) 
                               name:GeoNotificationModelGroupDidSelectRecord 
                             object:nil];
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSMutableArray *viewControllers=[self.viewControllers mutableCopy];
    UIViewController *newViewController=nil;
    int index=0;
    if ([segue.identifier isEqualToString:@"Initial View Controller"]) {
        //Instantiate the initial view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    }
    
    else if ([segue.identifier isEqualToString:@"Map View Controller"]) {
        //Instantiate the record map view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER];
        index=1;
    }
    
    else if ([segue.identifier isEqualToString:@"Record View Controller"]) {
        //Instantiate the record map view controller
        newViewController=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
    }
    
    if ([viewControllers count]<index+1) {
        [viewControllers addObject:newViewController];
        self.viewControllers=[viewControllers copy];
    }
    else if ([viewControllers objectAtIndex:index])
        [self replaceViewControllerAtSegmentIndex:index withViewController:newViewController];
    else {
        [viewControllers insertObject:newViewController atIndex:index];
        self.viewControllers=[viewControllers copy];
    }
    
    NSLog(@"View Controllers: %@",self.viewControllers);
}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Instantiate the intial and map view controllers
    [self performSegueWithIdentifier:@"Initial View Controller" sender:nil];
    [self performSegueWithIdentifier:@"Map View Controller" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Show the initial view
    [self swapToViewControllerAtSegmentIndex:0];
    
    //Subscribe to Model Group
    [self registerForModelGroupNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setDataMapSwitch:nil];
    [self setSettingButton:nil];
    [super viewDidUnload];
    
    //Remove self as observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
