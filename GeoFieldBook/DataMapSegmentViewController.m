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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@end

@implementation DataMapSegmentViewController

@synthesize toolbar=_toolbar;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;
@synthesize masterPresenter=_masterPresenter;
@synthesize dataMapSwitch = _dataMapSwitch;
@synthesize importExportButton = _importExportButton;
@synthesize formationButton = _formationButton;
@synthesize settingButton = _settingButton;

@synthesize masterPopoverController=_masterPopoverController;

#pragma mark - Getters and Setters

- (UIViewController *)detailSideViewController {
    return [self.viewControllers objectAtIndex:0];
}

#pragma mark - Data Forward Mechanisms

- (void)setRecordMapViewControllerMapDelegate:(id<GeoMapDelegate>)mapDelegate {
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

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)updateTrackingButtonForSegmentIndex:(int)segmentIndex {
    //If change to map side, put up the tracking button
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    if (segmentIndex) {
        RecordMapViewController *mapDetail=[self.viewControllers lastObject];
        UIBarButtonItem *trackingButton=[[MKUserTrackingBarButtonItem alloc] initWithMapView:mapDetail.mapView];
        [toolbarItems insertObject:trackingButton atIndex:[toolbarItems count]-1];
        self.toolbar.items=[toolbarItems copy];
    }
    
    //Else get rid of that button
    else {
        for (int index=0;index<[toolbarItems count];index++) {
            UIBarButtonItem *item=[toolbarItems objectAtIndex:index];
            if ([item isKindOfClass:[MKUserTrackingBarButtonItem class]])
                [toolbarItems removeObject:item];
        }
        
        self.toolbar.items=[toolbarItems copy];
    }
}

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
        for (int index=0;index<[toolbarItems count];index++) {
            UIBarButtonItem *barButtonItem=[toolbarItems objectAtIndex:index];
            if ([barButtonItem.title isEqualToString:@"Edit"] || [barButtonItem.title isEqualToString:@"Done"])
                [toolbarItems removeObject:barButtonItem];
        }
    }
    
    //Set the tolbar
    self.toolbar.items=[toolbarItems copy];
    
    //Be sure the UISegmentControl show the correct segment index
    self.dataMapSwitch.selectedSegmentIndex=segmentIndex;
    
    //Update the tracking button
    [self updateTrackingButtonForSegmentIndex:segmentIndex];
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

#pragma mark - Gesture Handlers

- (void)showMasterPopover:(UITapGestureRecognizer *)tapGesture {
    [self.masterPopoverController presentPopoverFromBarButtonItem:self.masterPresenter permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setDataMapSwitch:nil];
    [self setSettingButton:nil];
    [super viewDidUnload];
}
@end
