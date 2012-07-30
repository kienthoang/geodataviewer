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

@synthesize animationOption=_animationOption;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (UIViewController *)detailSideViewController {
    return [self.viewControllers objectAtIndex:0];
}

//Determine the type of animation
- (TransionAnimationOption)animationOption {
    return self.currentViewController==self.viewControllers.lastObject ? TransitionAnimationFlipLeft : TransitionAnimationFlipRight;
}

#pragma mark - Record View Controller Data Forward Mechanisms

- (void)dismissKeyboardInDataSideView {
    if ([self.detailSideViewController isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)self.detailSideViewController resignAllTextFieldsAndAreas];
}

- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate {
    //Set the delegate of the record detail vc if it's in the view controller array
    id recordDetail=self.detailSideViewController;
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setDelegate:delegate];
}

- (void)updateRecordDetailViewWithRecord:(Record *)record {
    //Set the record of the record detail vc
    id recordDetail=self.detailSideViewController;
    if ([recordDetail isKindOfClass:[RecordViewController class]])
        [(RecordViewController *)recordDetail setRecord:record];
}

- (void)putRecordViewControllerIntoEditingMode {
    //Put the record view controller into edit mode
    RecordViewController *recordDetail=(RecordViewController *)self.detailSideViewController;
    [recordDetail setEditing:YES animated:YES];
    [recordDetail showKeyboard];
}

- (void)cancelRecordViewControllerEditingMode {
    //Cancel the record view controller's edit mode
    RecordViewController *recordDetail=(RecordViewController *)self.detailSideViewController;
    [recordDetail cancelEditingMode];
}

#pragma mark - Record Map View Controller Data Forward Mechanisms


- (void)setMapViewDelegate:(id<RecordMapViewControllerDelegate>)mapDelegate {
    //Set the map delegate of the map vc
    id mapDetail=[self.viewControllers lastObject];
    if ([mapDetail isKindOfClass:[RecordMapViewController class]])
        [(RecordMapViewController *)mapDetail setMapDelegate:mapDelegate];
}

- (void)updateMapWithRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion {
    //Set the records of the record map view controller if it's in the view controller array
    RecordMapViewController *recordMap=[self.viewControllers lastObject];
    [recordMap updateRecords:records forceUpdate:willForceUpdate updateRegion:willUpdateRegion];
}

- (void)setMapSelectedRecord:(Record *)selectedRecord {
    if ([self.viewControllers.lastObject isKindOfClass:[RecordMapViewController class]]) {
        RecordMapViewController *mapDetail=(RecordMapViewController *)self.viewControllers.lastObject;
        mapDetail.selectedRecord=selectedRecord;
    }
}

- (void)reloadMapAnnotationViews {
    if ([self.viewControllers.lastObject isKindOfClass:[RecordMapViewController class]]) {
        RecordMapViewController *mapDetail=(RecordMapViewController *)self.viewControllers.lastObject;
        [mapDetail reloadAnnotationViews];
    }
}

#pragma mark - View Controller Manipulation (Pushing, Poping, Swapping)

- (void)swapToViewControllerAtSegmentIndex:(int)segmentIndex {
    [super swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //Allow the delegate (the big controller) to jump in
    [self.delegate dataMapSegmentController:self isSwitchingToViewController:[self.viewControllers objectAtIndex:segmentIndex]];
}

- (void)pushRecordViewController {
    [self performSegueWithIdentifier:@"Record View Controller" sender:nil];
    if (!self.topViewController)
        [self swapToViewControllerAtSegmentIndex:0];
}

- (void)pushRecordViewControllerWithTransitionAnimation:(TransionAnimationOption)animationOption 
                                                  setup:(push_completion_handler_t)setupHandler 
                                             completion:(push_completion_handler_t)completionHandler 
{
    //Only proceed if the current view controller is the reocrd view controller
    if ([self.topViewController isKindOfClass:[RecordViewController class]]) {
        //Setup the new record view controller
        RecordViewController *newRecordViewController=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER];
        
        //Replace the old record vc in the view controller array
        NSMutableArray *viewControllers=self.viewControllers.mutableCopy;
        [viewControllers replaceObjectAtIndex:0 withObject:newRecordViewController];
        self.viewControllers=viewControllers.copy;
        
        //Prepare to put the new record vc's view on screen
        [self addChildViewController:newRecordViewController];
        [newRecordViewController willMoveToParentViewController:self];
        
        //Run the setup handler
        setupHandler();
        
        //Animation
        UIViewAnimationOptions option=animationOption==TransitionAnimationCurlDown ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
        
        [self transitionFromViewController:self.currentViewController toViewController:newRecordViewController duration:0.6 options:option animations:^{                
            //Remove the view of the current view controller from the view hierachy
            [self.currentViewController.view removeFromSuperview];
            
        } completion:^(BOOL completed){
            if (completed) {
                //Add the view of the new vc to the hierachy and set it as the current view controller
                [self.contentView addSubview:newRecordViewController.view];
                
                //set the new view as the current view controller
                [newRecordViewController didMoveToParentViewController:self];
                self.currentViewController=newRecordViewController;
                
                //Run the completion handler
                completionHandler();
            }
        }];
    }
}

- (void)pushInitialViewController {    
    [self performSegueWithIdentifier:@"Initial View Controller" sender:nil];
    if (!self.topViewController)
        [self swapToViewControllerAtSegmentIndex:0];
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
