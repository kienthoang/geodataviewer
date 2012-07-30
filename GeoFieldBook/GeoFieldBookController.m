//
//  GeoFieldBookController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFieldBookController.h"
#import "GeoFieldBookControllerSegue.h"

#import "RecordTableViewController.h"
#import "FolderTableViewController.h"
#import "FormationFolderTableViewController.h"

#import "ImportTableViewController.h"
#import "RecordImportTVC.h"

#import "DataMapSegmentViewController.h"
#import "RecordViewController.h"

#import "RecordViewControllerDelegate.h"
#import "DataMapSegmentControllerDelegate.h"

#import "ModelGroupNotificationNames.h"
#import "IEEngineNotificationNames.h"
#import "IEConflictHandlerNotificationNames.h"

#import "Record+Modification.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Record+State.h"

#import "GeoDatabaseManager.h"
#import "SettingManager.h"

@interface GeoFieldBookController() <UINavigationControllerDelegate,DataMapSegmentControllerDelegate,RecordViewControllerDelegate,UIAlertViewDelegate,RecordMapViewControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *popoverVCButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataMapSwitch;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSDictionary *recordModifiedInfo;
@property (nonatomic, strong) Record *modifiedRecord;

#pragma mark - Temporary Popover Controllers

@property (nonatomic, strong) UIPopoverController *importPopover;
@property (nonatomic, strong) UIPopoverController *exportPopover;
@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;

@end

@implementation GeoFieldBookController

@synthesize contentView = _contentView;
@synthesize formationButton = _formationButton;
@synthesize importExportButton = _importExportButton;
@synthesize popoverVCButton = _popoverVCButton;
@synthesize settingButton = _settingButton;
@synthesize dataMapSwitch = _dataMapSwitch;
@synthesize toolbar = _toolbar;

@synthesize importExportSpinner=_importExportSpinner;
@synthesize importExportSpinnerBarButtonItem=_importExportSpinnerBarButtonItem;

@synthesize popoverViewController=_popoverViewController;
@synthesize viewGroupController=_viewGroupController;

@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize modifiedRecord=_modifiedRecord;

@synthesize importPopover=_importPopover;
@synthesize exportPopover=_exportPopover;

- (DataMapSegmentViewController *)dataMapSegmentViewController {
    id dataMapSegmentViewController=self.viewGroupController;
    
    if (![dataMapSegmentViewController isKindOfClass:[DataMapSegmentViewController class]])
        dataMapSegmentViewController=nil;
    
    return dataMapSegmentViewController;
}

- (void)swapToSegmentIndex:(int)segmentIndex {
    //if the segment index is not the given index, swap
    if (self.dataMapSwitch.selectedSegmentIndex!=segmentIndex) {
        //Swap to show the view controller at the given segment index
        DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
        [dataMapSegmentVC swapToViewControllerAtSegmentIndex:segmentIndex];
        
        //Make sure the data map switch stays consistent with the view controller showed in the view MVC group
        [self.dataMapSwitch setSelectedSegmentIndex:segmentIndex];
    }
}

- (void)dismissAllVisiblePopoversAnimated:(BOOL)animated {
    [self.formationFolderPopoverController dismissPopoverAnimated:NO];
    [self.popoverViewController dismissPopoverAnimated:NO];
    [self.importPopover dismissPopoverAnimated:NO];
    self.importPopover=nil;
    [self.exportPopover dismissPopoverAnimated:NO];
    self.exportPopover=nil;
}

#pragma mark - Model MVC Group Manipulators

#pragma mark - View MVC Group Manipulators

- (void)pushInitialViewControllerOnScreen {
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC pushInitialViewController];
    if (!dataMapSegmentVC.topViewController)
        [self swapToSegmentIndex:0];
}

- (void)pushRecordViewControllerOnScreen {
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC pushRecordViewController];
    if (!dataMapSegmentVC.topViewController)
        [self swapToSegmentIndex:0];
}

#pragma mark - UIActionSheetDelegate Protocol methods

- (void)presentRecordImportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UINavigationController *recordImportTVC=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.importPopover=[[UIPopoverController alloc] initWithContentViewController:recordImportTVC];
    
    //Present it
    [self.importPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)presentFormationImportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UINavigationController *formationImportTVC=[self.storyboard instantiateViewControllerWithIdentifier:FORMATION_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.importPopover=[[UIPopoverController alloc] initWithContentViewController:formationImportTVC];
    
    //Present it
    [self.importPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)presentRecordExportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UINavigationController *recordExportTVC=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_EXPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.exportPopover=[[UIPopoverController alloc] initWithContentViewController:recordExportTVC];
    
    //Present it
    [self.exportPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)presentFormationExportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UINavigationController *formationExportTVC=[self.storyboard instantiateViewControllerWithIdentifier:FORMATION_EXPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.exportPopover=[[UIPopoverController alloc] initWithContentViewController:formationExportTVC];
    
    //Present it
    [self.exportPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the given action sheet is the import/export action sheet
    if ([actionSheet.title isEqualToString:IMPORT_EXPORT_ACTION_SHEET_TITLE]) {
        if (buttonIndex<actionSheet.numberOfButtons) {
            //If user clicked import records
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Import Records"])
                [self presentRecordImportPopover];
            
            //If user clicked import formations
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Import Formations"])
                [self presentFormationImportPopover];
            
            //If user clicked export records
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Export Records"]) {
                [self presentRecordExportPopover];
            }
            
            //If user clicked export formations
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Export Formations"]) {
                [self presentFormationExportPopover];
            }
        }
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)presentPopoverViewController:(UIButton *)popoverVCButtonCustomView 
{
    //Dismiss the keyboard in the view side
    [[self dataMapSegmentViewController] dismissKeyboardInDataSideView];
    
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Present
    [self.popoverViewController presentPopoverFromBarButtonItem:self.popoverVCButton 
                                       permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                       animated:YES];
}

- (IBAction)formationButtonPressed:(UIButton *)sender {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Segue to the formation folder popover
    [self performSegueWithIdentifier:@"Show Formation Folders" sender:self.formationButton];
}

- (IBAction)importExportButtonPressed:(UIButton *)sender {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Show UIActionSheet with import/export options
    UIActionSheet *importExportActionSheet=[[UIActionSheet alloc] initWithTitle:IMPORT_EXPORT_ACTION_SHEET_TITLE 
                                                                       delegate:self 
                                                              cancelButtonTitle:@"Cancel" 
                                                         destructiveButtonTitle:nil 
                                                              otherButtonTitles:@"Import Records",@"Export Records",@"Import Formations",@"Export Formations", nil];
    [importExportActionSheet showInView:self.contentView];
}

- (IBAction)dataMapSwitchValueChanged:(UISegmentedControl *)sender {
    //Notify the data map segment controller of the change
    int segmentIndex=sender.selectedSegmentIndex;
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC segmentController:sender indexDidChangeTo:segmentIndex];
}

- (IBAction)settingButtonPressed:(UIButton *)sender {
    //Segue to the settings view controller
    [self performSegueWithIdentifier:@"Settings" sender:nil];
}

#pragma mark - UINavigationViewControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated
{
    //If the calling navigation controller controls the model MVC group and the new view controller is being pushed onto the navigation stack
    if (navigationController==self.popoverViewController.contentViewController) {
        DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
        
        //If the recently pushed view controller is a folder tvc, swap the view MVC group to show the initial view
        if ([viewController isKindOfClass:[FolderTableViewController class]])
            [self pushInitialViewControllerOnScreen];
        
        //Update the map view
        [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup] forceUpdate:NO updateRegion:YES];
        [dataMapSegmentVC setMapSelectedRecord:nil];  
        
        //If switching to the record tvc and the map is on screen, show the checkboxes in the record tvc
        RecordTableViewController *recordTVC=[self recordTableViewController];
        if (recordTVC) {
            DataMapSegmentViewController *dataMapSegmentVC=(DataMapSegmentViewController *)self.viewGroupController;
            if ([dataMapSegmentVC.topViewController isKindOfClass:[RecordMapViewController class]])
                recordTVC.willShowCheckboxes=YES;
            else
                recordTVC.willShowCheckboxes=NO;
        }
    }
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[GeoFieldBookControllerSegue class]]) {
        //popover view controller setup
        if ([segue.identifier isEqualToString:@"popoverViewController"]) {
            UIViewController *popoverContent=[self.storyboard instantiateViewControllerWithIdentifier:@"folderRecordModelGroup"];
            self.popoverViewController=[[UIPopoverController alloc] initWithContentViewController:popoverContent];
            [(UINavigationController *)self.popoverViewController.contentViewController setDelegate:self];
        }
        
        //view group controller setup
        else if ([segue.identifier isEqualToString:@"viewGroupController"]) {
            self.viewGroupController=[self.storyboard instantiateViewControllerWithIdentifier:@"viewGroupController"];
            DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
            [dataMapSegmentVC setDelegate:self];
            
            //Setup for the map view controller
            if ([[dataMapSegmentVC.viewControllers lastObject] isKindOfClass:[RecordMapViewController class]])
                [dataMapSegmentVC setMapViewDelegate:self];
        }
    }
        
    //Formation folder segue
    if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        //Dismiss the master popover if it's visible on the screen
        if (self.popoverViewController.isPopoverVisible)
            [self.popoverViewController dismissPopoverAnimated:NO];
        
        //Dismiss the old popover if its still visible
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Save the popover
        self.formationFolderPopoverController=[(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

#pragma mark - KVO/NSNotification Managers

- (void)modelGroupFolderDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:YES];
}

- (void)modelGroupRecordDatabaseDidChange:(NSNotification *)notification {
    //Update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:YES];
    
    //Pop the detail record vc (if the chosen record got deleted)
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (!recordTVC.chosenRecord) {
        [dataMapSegmentVC pushInitialViewController];
        if (!dataMapSegmentVC.topViewController)
            [self swapToSegmentIndex:0];
    }
}

- (void)modelGroupRecordDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:NO];
    
    //Pop the detail record vc (if the chosen record got deleted)
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (!recordTVC.chosenRecord) {
        [dataMapSegmentVC pushInitialViewController];
        if (!dataMapSegmentVC.topViewController)
            [self swapToSegmentIndex:0];
    }
}

- (void)modelGroupDidCreateNewRecord:(NSNotification *)notification {
    //If the data side of the data map segment controller is not a record view controller, push rvc
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    if (![dataMapSegmentVC.detailSideViewController isKindOfClass:[RecordViewController class]])
        [self pushRecordViewControllerOnScreen];
    
    //Switch to the data side
    [self swapToSegmentIndex:0];
    
    //Dismiss the popover
    [self.popoverViewController dismissPopoverAnimated:NO];
    
    //Put the record view controller in editing mode
    [dataMapSegmentVC putRecordViewControllerIntoEditingMode];
}

- (void)modelGroupFormationDatabaseDidChange:(NSNotification *)notification {
    //Force update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC reloadMapAnnotationViews];
}

- (void)putImportExportButtonBack {
    //Hide spinner and put up the import button
    __weak GeoFieldBookController *weakSelf=self;
    NSMutableArray *toolbarItems=self.toolbar.items.mutableCopy;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Hide the spinner
        [weakSelf.importExportSpinner stopAnimating];
        int index=[toolbarItems indexOfObject:weakSelf.importExportSpinnerBarButtonItem];
        [toolbarItems removeObject:weakSelf.importExportSpinnerBarButtonItem];
        [toolbarItems insertObject:weakSelf.importExportButton atIndex:index];
        weakSelf.toolbar.items=toolbarItems.copy;
    });
}

- (void)importingDidStart:(NSNotification *)notification {
    //Put up a spinner for the import button
    __weak GeoFieldBookController *weakSelf=self;
    NSMutableArray *toolbarItems=self.toolbar.items.mutableCopy;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *spinnerBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
        [spinner startAnimating];
        int index=[toolbarItems indexOfObject:weakSelf.importExportButton];
        [toolbarItems removeObject:weakSelf.importExportButton];
        [toolbarItems insertObject:spinnerBarButtonItem atIndex:index];
        weakSelf.toolbar.items=toolbarItems.copy;
        
        weakSelf.importExportSpinner=spinner;
        weakSelf.importExportSpinnerBarButtonItem=spinnerBarButtonItem; 
    });
}

- (void)recordImportingDidStart:(NSNotification *)notification {
    [self importingDidStart:notification];
    UINavigationController *modelNav=(UINavigationController *)self.popoverViewController.contentViewController;
    [modelNav popToRootViewControllerAnimated:NO];
}

- (void)formationImportingDidStart:(NSNotification *)notification {
    [self importingDidStart:notification];
}

- (void)importingWasCanceled:(NSNotification *)notification {
    //Put the import export button back
    [self putImportExportButtonBack];
}

- (void)importingDidEnd:(NSNotification *)notification {
    //Hide spinner and put up the import button
    [self putImportExportButtonBack];
    
    //Show done alert in the main queue (UI stuff)
    dispatch_async(dispatch_get_main_queue(), ^{
        //Put up an alert
        UIAlertView *doneAlert=[[UIAlertView alloc] initWithTitle:@"Finished Importing" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [doneAlert show];
        
        //Tell the folder tvc to reload its data
        FolderTableViewController *folderTVC=[self folderTableViewController];
        [folderTVC reloadVisibleCells];
    });
}

- (void)exportingDidEnd:(NSNotification *)notification {
    //Put up alert in the main queue (UI stuff)
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *doneAlert=[[UIAlertView alloc] initWithTitle:@"Exporting Finished" message:@"" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [doneAlert show];
    });
}

- (void)handleValidationErrors:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        //Put the import export button back again
        [self putImportExportButtonBack];
    });
}

- (void)longPressGestureSettingDidChange:(NSNotification *)notification {
    //Reset 
    [self setupLongPressGestureRecognizer];
}

- (void)feedbackTimeout:(NSNotification *)notification {
    //Put up the question feedback modal
    [self performSegueWithIdentifier:@"Questions" sender:nil];
    
    //Reset the feedback counter
    SettingManager *settingManager=[SettingManager standardSettingManager];
    settingManager.feedbackCounter=[NSNumber numberWithInt:0];
}

- (void)registerForModelGroupNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupFolderDatabaseDidUpdate:) 
                               name:GeoNotificationModelGroupFolderDatabaseDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupRecordDatabaseDidChange:) 
                               name:GeoNotificationModelGroupRecordDatabaseDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupRecordDatabaseDidUpdate:) 
                               name:GeoNotificationModelGroupRecordDatabaseDidUpdate 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupFormationDatabaseDidChange:) 
                               name:GeoNotificationModelGroupFormationDatabaseDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupDidCreateNewRecord:) 
                               name:GeoNotificationModelGroupDidCreateNewRecord 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingDidEnd:) 
                               name:GeoNotificationConflictHandlerImportingDidEnd 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingWasCanceled:) 
                               name:GeoNotificationConflictHandlerImportingWasCanceled
                             object:nil];
    
    [notificationCenter addObserver:self 
                           selector:@selector(recordImportingDidStart:) 
                               name:GeoNotificationIEEngineRecordImportingDidStart
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(formationImportingDidStart:) 
                               name:GeoNotificationIEEngineFormationImportingDidStart
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(exportingDidEnd:) 
                               name:GeoNotificationIEEngineExportingDidEnd
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(handleValidationErrors:) 
                               name:GeoNotificationConflictHandlerValidationErrorsOccur 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(longPressGestureSettingDidChange:) 
                               name:SettingManagerUserPreferencesDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(feedbackTimeout:) 
                               name:SettingManagerFeedbackTimeout 
                             object:nil];
}

#pragma mark - Gesture Setups

- (void)removeLongPressGestureRecogizer {
    for (UIGestureRecognizer *gestureRecognizer in self.contentView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [self.contentView removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)setupLongPressGestureRecognizer {
    //Remove long press gestures
    [self removeLongPressGestureRecogizer];
    
    //Add long press if specified by settings
    BOOL longPressEnabled=[SettingManager standardSettingManager].longGestureEnabled;
    if (longPressEnabled) {
        UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentPopoverViewController:)];
        [self.contentView addGestureRecognizer:longPressGestureRecognizer];
    }
}

- (void)setupGestureRecognizers {
    //Setup the long press gesture recognizer
    [self setupLongPressGestureRecognizer];
}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Instantiate the popover view controller
    [self performSegueWithIdentifier:@"popoverViewController" sender:nil];
    
    //Instantiate the view group view controlelr
    [self performSegueWithIdentifier:@"viewGroupController" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    //Register to receive notifications from the model group
    [self registerForModelGroupNotifications];

    //Change the look of the master presenter
    UIButton *popoverVCButtonCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [popoverVCButtonCustomView setImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
    popoverVCButtonCustomView.frame=CGRectMake(0, 0, 32, 32);
    [popoverVCButtonCustomView addTarget:self action:@selector(presentPopoverViewController:) forControlEvents:UIControlEventTouchUpInside];
    popoverVCButtonCustomView.showsTouchWhenHighlighted=YES;
    self.popoverVCButton.customView=popoverVCButtonCustomView;
    
    //Change the look of the import/export button
    UIButton *importExportCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [importExportCustomView setImage:[UIImage imageNamed:@"import_export.png"] forState:UIControlStateNormal];
    importExportCustomView.frame=CGRectMake(0, 0, 24, 24);
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
    
    //Change the look of the setting button
    UIButton *settingButtonCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [settingButtonCustomView setImage:[UIImage imageNamed:@"gear2.png"] forState:UIControlStateNormal];
    settingButtonCustomView.frame=CGRectMake(0, 0, 30, 30);
    [settingButtonCustomView addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    settingButtonCustomView.showsTouchWhenHighlighted=YES;
    self.settingButton.customView=settingButtonCustomView;
    
    //[self.toolbar setBackgroundImage:[UIImage imageNamed:@"stone-textures.jpeg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //Setup gesture recognizers
    [self setupGestureRecognizers];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Get the data map segment controller
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    
    //Adjust the frame of the specified view controller's view
    dataMapSegmentVC.view.frame=self.contentView.bounds;
    
    //Setup the view controller hierachy
    [self addChildViewController:dataMapSegmentVC];
    [self.viewGroupController willMoveToParentViewController:self];
    
    //Add the view of the data map segment
    [self.contentView addSubview:dataMapSegmentVC.view];
    [dataMapSegmentVC didMoveToParentViewController:self];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setFormationButton:nil];
    [self setImportExportButton:nil];
    [self setPopoverVCButton:nil];
    [self setSettingButton:nil];
    [self setDataMapSwitch:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}

#pragma mark - Autosave Controller

- (UIAlertView *)autosaveAlertForValidationOfRecordInfo:(NSDictionary *)recordInfo {
    UIAlertView *autosaveAlert=nil;
    
    //If the record info passes the validations, show the alert; otherwise, show an alert with no confirm button
    NSArray *failedKeyNames=[self.modifiedRecord validatesMandatoryPresenceOfRecordInfo:recordInfo];
    if (!failedKeyNames.count) {
        //If the name of the record is not nil
        NSString *message=@"You navigated away. Do you want to save the record you were editing?";
        
        //Put up an alert to ask the user whether he/she wants to save
        autosaveAlert=[[UIAlertView alloc] initWithTitle:AUTOSAVE_ALERT_TITLE 
                                                 message:message 
                                                delegate:self 
                                       cancelButtonTitle:@"Don't Save" 
                                       otherButtonTitles:@"Save", nil];
    } else {
        //Show the autosave fail alert with all the missing record info
        NSMutableArray *failedNames=[NSMutableArray array];
        for (NSString *failedKey in failedKeyNames)
            [failedNames addObject:[Record nameForDictionaryKey:failedKey]];
        NSString *message=[NSString stringWithFormat:@"Record could not be saved because the following information was missing: %@",[failedNames componentsJoinedByString:@", "]];
        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Saving Failed!" 
                                                 message:message 
                                                delegate:nil 
                                       cancelButtonTitle:@"Dismiss" 
                                       otherButtonTitles:nil];
        
        //Delete the record if it's "fresh" (newly created and has not been modified)
        Record *record=self.modifiedRecord;
        if (record.recordState==RecordStateNew)
            [record.managedObjectContext deleteObject:record];
    }
    
    return autosaveAlert;
}

- (void)autosaveRecord:(Record *)record 
     withNewRecordInfo:(NSDictionary *)recordInfo 
{
    //Save the recordInfo dictionary in a temporary property
    self.recordModifiedInfo=recordInfo;
    
    //Save the record in a temporary property
    self.modifiedRecord=record;
    
    //Get and show the appropriate alert
    UIAlertView *autosaveAlert=[self autosaveAlertForValidationOfRecordInfo:recordInfo];
    [autosaveAlert show];
}

#pragma mark - UI Management Methods

- (void)removeButtonWithTitle:(NSString *)title {
    //Remove the button with the given title
    NSMutableArray *toolbarItems=self.toolbar.items.mutableCopy;
    for (int index=0;index<toolbarItems.count;index++) {
        UIBarButtonItem *barButtonItem=[toolbarItems objectAtIndex:index];
        if (barButtonItem.title.length && [barButtonItem.title caseInsensitiveCompare:title]==NSOrderedSame)
            [toolbarItems removeObject:barButtonItem];               
    }
    
    //Set the tolbar
    self.toolbar.items=[toolbarItems copy];
}

- (void)removeButtonsWithTitles:(NSArray *)titles {
    //Remove all buttons that hastitle in the given array
    for (NSString *title in titles)
        [self removeButtonWithTitle:title];
}

- (void)putUpButton:(UIBarButtonItem *)button atIndex:(int)index {
    //Put the given button up if its not already in the toolbar
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    if (![toolbarItems containsObject:button])
        [toolbarItems insertObject:button atIndex:index];
    
    //Set the tolbar
    self.toolbar.items=[toolbarItems copy];
}

- (void)setupCancelButtonForViewController:(UIViewController *)viewController {
    //If the swapped in view controller is the record view controller put up the cancel button
    if ([viewController isKindOfClass:[RecordViewController class]]) {
        RecordViewController *recordDetail=(RecordViewController *)viewController;
        [self putUpButton:recordDetail.cancelButton atIndex:self.toolbar.items.count-1];
    }
    
    //If the edit button is on the toolbar, take it off
    else
        [self removeButtonWithTitle:@"Cancel"];
}

- (void)setupEditButtonForViewController:(UIViewController *)viewController {
    //If the swapped in view controller is the record view controller put up the edit button
    if ([viewController isKindOfClass:[RecordViewController class]]) {
        RecordViewController *recordDetail=(RecordViewController *)viewController;
        [self putUpButton:recordDetail.editButton atIndex:self.toolbar.items.count];
    }
    
    //If the edit button is on the toolbar, take it off (its title should either be "Done" or "Edit")
    else
        [self removeButtonsWithTitles:[NSArray arrayWithObjects:@"Edit",@"Done", nil]];
}

- (void)setupButtonsForViewSideController:(UIViewController *)viewController {
    //Setup the tracking button
    [self setupTrackingButtonForViewController:viewController];
    
    //Setup the buttons for the record view controller (if the given view controller is one)
    [self setupEditButtonForViewController:viewController];
}

- (void)setupTrackingButtonForViewController:(UIViewController *)viewController {
    //If switched to the map, put up the tracking button
    NSMutableArray *toolbarItems=self.toolbar.items.mutableCopy;
    if ([viewController isKindOfClass:[RecordMapViewController class]]) {
        RecordMapViewController *mapDetail=(RecordMapViewController *)viewController;
        UIBarButtonItem *trackingButton=[[MKUserTrackingBarButtonItem alloc] initWithMapView:mapDetail.mapView];
        [toolbarItems insertObject:trackingButton atIndex:[toolbarItems count]-1];
    }
    
    //Else get rid of that button
    else {
        for (int index=0;index<[toolbarItems count];index++) {
            UIBarButtonItem *item=[toolbarItems objectAtIndex:index];
            if ([item isKindOfClass:[MKUserTrackingBarButtonItem class]])
                [toolbarItems removeObject:item];
        }
    }
    
    //Set the tolbar
    self.toolbar.items=toolbarItems.copy;
}

#pragma mark - DataMapSegmentViewControllerDelegate protocol methods

- (void)dataMapSegmentController:(DataMapSegmentViewController *)sender 
     isSwitchingToViewController:(UIViewController *)viewController
{
    //Setup the buttons
    [self setupButtonsForViewSideController:viewController];
    
    //Setup delegate for the record view controller
    if ([viewController isKindOfClass:[RecordViewController class]])
        [sender setRecordViewControllerDelegate:self];
    
    //If switching to the map, show the checkboxes (allow filter by folder) in the folder ;
    FolderTableViewController *folderTVC=[[(UINavigationController *)self.popoverViewController.contentViewController viewControllers] objectAtIndex:0];
    if (folderTVC) {
        if ([viewController isKindOfClass:[RecordMapViewController class]])
            folderTVC.willFilterByFolder=YES;
        else
            folderTVC.willFilterByFolder=NO;
    }
    
    //If switching to the map, show the checkboxes in the record tvc
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (recordTVC) {
        if ([viewController isKindOfClass:[RecordMapViewController class]])
            recordTVC.willShowCheckboxes=YES;
        else
            recordTVC.willShowCheckboxes=NO;
    }
}

#pragma mark - RecordViewControllerDelegate protocol methods

- (RecordTableViewController *)recordTableViewController {
    UINavigationController *navController=(UINavigationController *)self.popoverViewController.contentViewController;
    id topViewController=navController.topViewController;
    if (![topViewController isKindOfClass:[RecordTableViewController class]])
        topViewController=nil;
    
    return topViewController;
}

- (FolderTableViewController *)folderTableViewController {
    UINavigationController *navController=(UINavigationController *)self.popoverViewController.contentViewController;
    id topViewController=navController.topViewController;
    if (![topViewController isKindOfClass:[FolderTableViewController class]])
        topViewController=nil;
    
    return topViewController;
}

- (void)recordViewController:(RecordViewController *)sender 
         userDidModifyRecord:(Record *)record 
           withNewRecordInfo:(NSDictionary *)recordInfo 
{
    //Call the record table view controller to update the given record with the given record info
    [[self recordTableViewController] modifyRecord:record withNewInfo:recordInfo];
}

- (void)userDidNavigateAwayFrom:(RecordViewController *)sender 
           whileModifyingRecord:(Record *)record
                    withNewInfo:(NSDictionary *)newInfo
{
    //If the given record has not been deleted yet, show the autosave alert
    if (!record.isDeleted) {
        //Put up the autosave alert
        [self autosaveRecord:record withNewRecordInfo:newInfo]; 
    }
}

- (void)replaceWithEditButtonOfRecordViewController:(RecordViewController *)recordVC {
    //Remove the old edit button (its title should either be "Edit" or "Done")
    [self removeButtonsWithTitles:[NSArray arrayWithObjects:@"Edit",@"Done", nil]];
    
    //Put up the new one
    [self setupEditButtonForViewController:recordVC];
}

- (void)swipeWithTransitionAnimation:(TransionAnimationOption)animationOption forward:(BOOL)forward {
    //Switch record
    __weak GeoFieldBookController *weakSelf=self;
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC pushRecordViewControllerWithTransitionAnimation:animationOption setup:^(){
        //Set the delegate of the new record vc
        [dataMapSegmentVC setRecordViewControllerDelegate:weakSelf];
        
        //Move the next record
        RecordTableViewController *recordTVC=[weakSelf recordTableViewController];
        if (recordTVC) {
            //If switching to the next record
            if (forward)
                [recordTVC forwardToNextRecord];
            else
                [recordTVC backToPrevRecord];
        }
    } completion:^{
        //Replace the old edit button with the new one
        RecordViewController *newRecordVC=(RecordViewController *)dataMapSegmentVC.topViewController;
        [self replaceWithEditButtonOfRecordViewController:newRecordVC];
    }];
}

- (void)userDidSwipeUpInRecordViewController:(RecordViewController *)sender {
    //Switch to the next record
    RecordTableViewController *recordVC=[self recordTableViewController];
    if (recordVC && [recordVC hasNextRecord])
        [self swipeWithTransitionAnimation:TransitionAnimationCurlUp forward:YES];
}

- (void)userDidSwipeDownInRecordViewController:(RecordViewController *)sender {
    //Switch to the prev record
    RecordTableViewController *recordVC=[self recordTableViewController];
    if (recordVC && [recordVC hasPrevRecord])
        [self swipeWithTransitionAnimation:TransitionAnimationCurlDown forward:NO];
}

- (void)userDidCancelEditingMode:(RecordViewController *)sender {
    //Remove the cancel button
    [self removeButtonWithTitle:@"Cancel"];    
}

- (void)userWantsToCancelEditingMode:(RecordViewController *)sender {
    //Cancel immediately if the record info has not changed
    //Record *record=sender.record;
    if (NO) {
        
    } 
    
    //else put up an alert to make sure user wants to cancel
    else {
        //Put up an alert
        UIAlertView *cancelAlert=[[UIAlertView alloc] initWithTitle:CANCEL_ALERT_TITLE 
                                                            message:@"Are you sure you want to cancel? All the changes you made will be lost." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Go Back" 
                                                  otherButtonTitles:@"Confirm", nil];
        [cancelAlert show];
    }
}

- (void)userDidStartEditingMode:(RecordViewController *)sender {
    //Put up the cancel button
    [self setupCancelButtonForViewController:sender];   
}

#pragma mark - RecordMapViewControllerDelegate protocol methods

- (NSArray *)recordsFromModelGroup {
    //If the current TVC in the model group is the record table view controller
    id modelGroupTopVC=[self recordTableViewController];
    if (modelGroupTopVC) {
        return [(RecordTableViewController *)modelGroupTopVC records];
    }
    
    //Else if the current TVC in the model group is the folder table view controller
    modelGroupTopVC=[self folderTableViewController];
    if (modelGroupTopVC) {
        NSMutableArray *records=[NSMutableArray array];
        NSArray *selectedFolders=[(FolderTableViewController *)modelGroupTopVC selectedFolders];
        UIManagedDocument *database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
        for (NSString *folder in selectedFolders) {
            NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
            request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",folder];
            request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            NSArray *results=[database.managedObjectContext executeFetchRequest:request error:NULL];
            [records addObjectsFromArray:results];
        }
                
        return records.copy;
    }
    
    return nil;
}

- (NSArray *)recordsForMapViewController:(RecordMapViewController *)mapViewController {
    return [self recordsFromModelGroup];
}

- (void)mapViewController:(RecordMapViewController *)mapVC userDidSelectAnnotationForRecord:(Record *)record switchToDataView:(BOOL)willSwitchToDataView 
{
    //Update the data side (push if it's not on screen somewhere)
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    if (![dataMapSegmentVC.detailSideViewController isKindOfClass:[RecordViewController class]])
        [self pushRecordViewControllerOnScreen];
    [dataMapSegmentVC updateRecordDetailViewWithRecord:record];
    
    //Update the model group to reflect the changes
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (recordTVC)
        [(RecordTableViewController *)recordTVC setChosenRecord:record];
    else if ([self folderTableViewController]) {
        FolderTableViewController *folderTVC=[self folderTableViewController];
        [folderTVC performSegueWithIdentifier:@"Show Records" sender:record];
    }
    
    //Switch to data view if desired
    if (willSwitchToDataView)
        [self swapToSegmentIndex:0];
}

- (void)userDidChooseToDisplayRecordTypes:(NSArray *)selectedRecordTypes {
    //Update the record tvc
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (recordTVC)
        recordTVC.selectedRecordTypes=selectedRecordTypes;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    
    //If the alert is the autosave alert
    if ([alertView.title isEqualToString:AUTOSAVE_ALERT_TITLE]) {
        if ([buttonTitle isEqualToString:@"Save"]) {
            //Save the record info
            [self.modifiedRecord updateWithNewRecordInfo:self.recordModifiedInfo]; 
            
            //Nillify the temporary record modified data
            self.modifiedRecord=nil;
            self.recordModifiedInfo=nil;
        }
    }
    
    //If the alert is the cancel alert (from RecordViewController)
    else if ([alertView.title isEqualToString:CANCEL_ALERT_TITLE]) {
        //If user click "Continue", cancel the editing mode of the record view controller
        if ([buttonTitle isEqualToString:@"Confirm"]) {
            //Cancel editing mode
            DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
            [dataMapSegmentVC cancelRecordViewControllerEditingMode];
            
            //Delete the record if it's "fresh" (newly created and has not been modified)
            RecordTableViewController *recordTVC=[self recordTableViewController];
            Record *record=recordTVC.chosenRecord;
            if (record.recordState==RecordStateNew)
                [record.managedObjectContext deleteObject:record];
            
            //Push the initial view on screen
            [self pushInitialViewControllerOnScreen];
        }
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    //Nillify the temporary record modified data
    self.modifiedRecord=nil;
    self.recordModifiedInfo=nil;
}

@end
