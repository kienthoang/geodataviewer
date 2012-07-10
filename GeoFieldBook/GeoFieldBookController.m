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
#import "RecordImportTableViewController.h"

#import "DataMapSegmentViewController.h"
#import "RecordViewController.h"

#import "RecordViewControllerDelegate.h"
#import "DataMapSegmentControllerDelegate.h"

#import "ModelGroupNotificationNames.h"

#import "Record+Modification.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"

#import "GeoDatabaseManager.h"

@interface GeoFieldBookController() <UINavigationControllerDelegate,DataMapSegmentControllerDelegate,RecordViewControllerDelegate,UIAlertViewDelegate,RecordMapViewControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *popoverVCButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataMapSwitch;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSDictionary *recordModifiedInfo;
@property (nonatomic, strong) Record *modifiedRecord;

#pragma mark - Temporary Popover Controllers

@property (nonatomic, strong) UIPopoverController *importRecordPopover;
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

@synthesize popoverViewController=_popoverViewController;
@synthesize viewGroupController=_viewGroupController;

@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize modifiedRecord=_modifiedRecord;

@synthesize importRecordPopover=_importRecordPopover;

- (DataMapSegmentViewController *)dataMapSegmentViewController {
    id dataMapSegmentViewController=self.viewGroupController;
    
    if (![dataMapSegmentViewController isKindOfClass:[DataMapSegmentViewController class]])
        dataMapSegmentViewController=nil;
    
    return dataMapSegmentViewController;
}

- (void)swapToSegmentIndex:(int)segmentIndex {
    //Swap to show the view controller at the given segment index
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC swapToViewControllerAtSegmentIndex:segmentIndex];
    
    //Make sure the data map switch stays consistent with the view controller showed in the view MVC group
    [self.dataMapSwitch setSelectedSegmentIndex:segmentIndex];
}

- (void)dismissAllVisiblePopoversAnimated:(BOOL)animated {
    [self.formationFolderPopoverController dismissPopoverAnimated:NO];
    [self.popoverViewController dismissPopoverAnimated:NO];
    [self.importRecordPopover dismissPopoverAnimated:NO];
    self.importRecordPopover=nil;
}

#pragma mark - UIActionSheetDelegate Protocol methods

- (void)presentRecordImportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UIViewController *recordImportTVC=[self.storyboard instantiateViewControllerWithIdentifier:RECORD_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.importRecordPopover=[[UIPopoverController alloc] initWithContentViewController:recordImportTVC];
    
    //Present it
    [self.importRecordPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the given action sheet is the import/export action sheet
    if ([actionSheet.title isEqualToString:IMPORT_EXPORT_ACTION_SHEET_TITLE]) {
        //If user click import records
        if (buttonIndex<actionSheet.numberOfButtons && [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Import Records"])
            [self presentRecordImportPopover];
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)presentPopoverViewController:(UIButton *)popoverVCButtonCustomView 
{
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

#pragma mark - UINavigationViewControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated
{
    //If the calling navigation controller controls the model MVC group and the new view controller is being pushed onto the navigation stack
    if (navigationController==self.popoverViewController.contentViewController) {
        DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
        
        //If the recently pushed view controller is a folder tvc, swap the view MVC group to show the initial view
        if ([viewController isKindOfClass:[FolderTableViewController class]]) {
            [dataMapSegmentVC pushInitialViewController];
            if (!dataMapSegmentVC.topViewController)
                [self swapToSegmentIndex:0];
        }
        
        //Update the map view
        [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup]];
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

#pragma mark - Model Group Notifcation Handlers

- (void)modelGroupFolderDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup]];
}

- (void)modelGroupRecordDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    DataMapSegmentViewController *dataMapSegmentVC=[self dataMapSegmentViewController];
    [dataMapSegmentVC updateMapWithRecords:[self recordsFromModelGroup]];
    
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
        [dataMapSegmentVC pushRecordViewController];
    
    //Serve the newly created record (currently chosen record as well) to the record view controller
    RecordTableViewController *recordTVC=[self recordTableViewController];
    [dataMapSegmentVC updateRecordDetailViewWithRecord:recordTVC.chosenRecord];
    
    //Switch to the data side
    [self swapToSegmentIndex:0];
    
    //Put the record view controller in editing mode
    [dataMapSegmentVC putRecordViewControllerIntoEditingMode];
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

- (void)registerForModelGroupNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupFolderDatabaseDidUpdate:) 
                               name:GeoNotificationModelGroupFolderDatabaseDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupRecordDatabaseDidUpdate:) 
                               name:GeoNotificationModelGroupRecordDatabaseDidChange 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(modelGroupDidCreateNewRecord:) 
                               name:GeoNotificationModelGroupDidCreateNewRecord 
                             object:nil];
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
    //[settingButtonCustomView addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    settingButtonCustomView.showsTouchWhenHighlighted=YES;
    self.settingButton.customView=settingButtonCustomView;
    
    //[self.toolbar setBackgroundImage:[UIImage imageNamed:@"stone-textures.jpeg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //Add gesture to call the master
    UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentPopoverViewController:)];
    [self.contentView addGestureRecognizer:longPressGestureRecognizer];
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
    NSArray *failedKeyNames=[Record validatesMandatoryPresenceOfRecordInfo:recordInfo];
    if (![failedKeyNames count]) {
        //If the name of the record is not nil
        NSString *message=@"You navigated away. Do you want to save the record you were editing?";
        
        //Put up an alert to ask the user whether he/she wants to save
        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave" 
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
        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave Failed!" 
                                                 message:message 
                                                delegate:nil 
                                       cancelButtonTitle:@"Dismiss" 
                                       otherButtonTitles:nil];
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


#pragma mark - DataMapSegmentViewControllerDelegate protocol methods

- (void)setupEditButtonForViewController:(UIViewController *)viewController {
    //If the swapped in view controller is the record view controller put up the edit button
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
    if ([viewController isKindOfClass:[RecordViewController class]]) {
        RecordViewController *recordDetail=(RecordViewController *)viewController;
        [toolbarItems addObject:recordDetail.editButton];
    }
    
    //If the edit button is on the toolbar, take it off
    else {
        for (int index=0;index<[toolbarItems count];index++) {
            UIBarButtonItem *barButtonItem=[toolbarItems objectAtIndex:index];
            if ([barButtonItem.title isEqualToString:@"Edit"] || [barButtonItem.title isEqualToString:@"Done"])
                [toolbarItems removeObject:barButtonItem];
        }
    }
    
    //Set the tolbar
    self.toolbar.items=[toolbarItems copy];
}

- (void)setupTrackingButtonForViewController:(UIViewController *)viewController {
    //If switched to the map, put up the tracking button
    NSMutableArray *toolbarItems=[self.toolbar.items mutableCopy];
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
    self.toolbar.items=[toolbarItems copy];
}

- (void)dataMapSegmentController:(DataMapSegmentViewController *)sender 
     isSwitchingToViewController:(UIViewController *)viewController
{
    //Setup the buttons
    [self setupEditButtonForViewController:viewController];
    [self setupTrackingButtonForViewController:viewController];
    
    //Setup delegate for the record view controller
    if ([viewController isKindOfClass:[RecordViewController class]])
        [sender setRecordViewControllerDelegate:self];
    
    //If switching to the map, show the checkboxes (allow filter by folder) in the folder tvc
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
    //If the chosen record of the record tvc is not nil (meaning it has not been deleted yet), show the autosave alert
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (recordTVC.chosenRecord) {
        //Put up the autosave alert
        [self autosaveRecord:record withNewRecordInfo:newInfo]; 
    }
}

#pragma mark - RecordMapViewControllerDelegate protocol methods

- (NSArray *)recordsFromModelGroup {
    //If the current TVC in the model group is the record table view controller
    id modelGroupTopVC=[self recordTableViewController];
    if (modelGroupTopVC) {
        return [(RecordTableViewController *)modelGroupTopVC selectedRecords];
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
        
        return [records copy];
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
        [dataMapSegmentVC pushRecordViewController];
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
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
        //Save the record info
        [self.modifiedRecord updateWithNewRecordInfo:self.recordModifiedInfo]; 
            
        //Nillify the temporary record modified data
        self.modifiedRecord=nil;
        self.recordModifiedInfo=nil;
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    //Nillify the temporary record modified data
    self.modifiedRecord=nil;
    self.recordModifiedInfo=nil;
}

@end
