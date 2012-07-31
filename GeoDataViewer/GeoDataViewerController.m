//
//  GeoDataViewerController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoDataViewerController.h"
#import "GeoDataViewerControllerSegue.h"

#import "RecordTableViewController.h"
#import "FolderTableViewController.h"
#import "FormationFolderTableViewController.h"

#import "ImportTableViewController.h"
#import "RecordImportTVC.h"

#import "ModelGroupNotificationNames.h"
#import "IEEngineNotificationNames.h"
#import "IEConflictHandlerNotificationNames.h"

#import "Record+Modification.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Record+State.h"

#import "GeoDatabaseManager.h"
#import "SettingManager.h"

@interface GeoDataViewerController() <UINavigationControllerDelegate,RecordMapViewControllerDelegate,UIActionSheetDelegate>

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

@implementation GeoDataViewerController

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
@synthesize mapViewController=_viewGroupController;

@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize modifiedRecord=_modifiedRecord;

@synthesize importPopover=_importPopover;
@synthesize exportPopover=_exportPopover;

- (void)dismissAllVisiblePopoversAnimated:(BOOL)animated {
    [self.formationFolderPopoverController dismissPopoverAnimated:NO];
    [self.popoverViewController dismissPopoverAnimated:NO];
    [self.importPopover dismissPopoverAnimated:NO];
    self.importPopover=nil;
    [self.exportPopover dismissPopoverAnimated:NO];
    self.exportPopover=nil;
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
        //Update the map view
        
    }
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[GeoDataViewerControllerSegue class]]) {
        //popover view controller setup
        if ([segue.identifier isEqualToString:@"popoverViewController"]) {
            UIViewController *popoverContent=[self.storyboard instantiateViewControllerWithIdentifier:@"folderRecordModelGroup"];
            self.popoverViewController=[[UIPopoverController alloc] initWithContentViewController:popoverContent];
            [(UINavigationController *)self.popoverViewController.contentViewController setDelegate:self];
        }
        
        //view group controller setup
        else if ([segue.identifier isEqualToString:@"mapViewController"]) {
            self.mapViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
            self.mapViewController.mapDelegate=self;
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

#pragma mark - Model MVC Group Manipulators

- (FolderTableViewController *)folderTableViewController {
    UINavigationController *modelMVCNav=(UINavigationController *)self.popoverViewController.contentViewController;
    FolderTableViewController *folderTVC=nil;
    if ([modelMVCNav.topViewController isKindOfClass:[FolderTableViewController class]])
        folderTVC=(FolderTableViewController *)modelMVCNav.topViewController;
    
    return folderTVC;
}

- (RecordTableViewController *)recordTableViewController {
    UINavigationController *modelMVCNav=(UINavigationController *)self.popoverViewController.contentViewController;
    RecordTableViewController *recordTVC=nil;
    if ([modelMVCNav.topViewController isKindOfClass:[RecordTableViewController class]])
        recordTVC=(RecordTableViewController *)modelMVCNav.topViewController;
    
    return recordTVC;
}

#pragma mark - KVO/NSNotification Managers

- (void)modelGroupFolderDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    [self.mapViewController updateRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:YES];
}

- (void)modelGroupRecordDatabaseDidChange:(NSNotification *)notification {
    //Update the map
    [self.mapViewController updateRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:YES];
}

- (void)modelGroupRecordDatabaseDidUpdate:(NSNotification *)notification {
    //Update the map
    [self.mapViewController updateRecords:[self recordsFromModelGroup] forceUpdate:YES updateRegion:NO];
}

- (void)modelGroupFormationDatabaseDidChange:(NSNotification *)notification {
    //Force update the map
    [self.mapViewController reloadAnnotationViews];
}

- (void)putImportExportButtonBack {
    //Hide spinner and put up the import button
    __weak GeoDataViewerController *weakSelf=self;
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
    __weak GeoDataViewerController *weakSelf=self;
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
    [self performSegueWithIdentifier:@"mapViewController" sender:nil];
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
    
    //Get the map vc
    RecordMapViewController *mapVC=self.mapViewController;
    
    //Adjust the frame of the specified view controller's view
    mapVC.view.frame=self.contentView.bounds;
    
    //Setup the view controller hierachy
    [self addChildViewController:mapVC];
    [self.mapViewController willMoveToParentViewController:self];
    
    //Add the view of the data map segment
    [self.contentView addSubview:mapVC.view];
    [mapVC didMoveToParentViewController:self];    
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
        UIManagedDocument *database=[GeoDatabaseManager standardDatabaseManager].geoDataViewerDatabase;
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

- (void)userDidChooseToDisplayRecordTypes:(NSArray *)selectedRecordTypes {
    //Update the record tvc
    RecordTableViewController *recordTVC=[self recordTableViewController];
    if (recordTVC)
        recordTVC.selectedRecordTypes=selectedRecordTypes;
}

@end
