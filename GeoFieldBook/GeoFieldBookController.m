//
//  GeoFieldBookController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFieldBookController.h"
#import "GeoFieldBookControllerSegue.h"
#import "FormationFolderTableViewController.h"
#import "DataMapSegmentViewController.h"

#import "RecordTableViewController.h"
#import "FolderTableViewController.h"

#import "ModelGroupNotificationNames.h"
#import "RecordTableViewControllerDelegate.h"
#import "RecordViewController.h"

@interface GeoFieldBookController() <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *popoverVCButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dataMapSwitch;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

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

#pragma mark - Target-Action Handlers

- (IBAction)presentPopoverViewController:(UIButton *)popoverVCButtonCustomView 
{
    [self.popoverViewController presentPopoverFromBarButtonItem:self.popoverVCButton 
                                       permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                       animated:YES];
    
    //Dismiss the formation folder popover if it's visible
    if (self.formationFolderPopoverController.isPopoverVisible)
        [self.formationFolderPopoverController dismissPopoverAnimated:NO];
}

- (IBAction)formationButtonPressed:(UIButton *)sender {
    //Segue to the formation folder popover
    [self performSegueWithIdentifier:@"Show Formation Folders" sender:self.formationButton];
}

- (IBAction)importExportButtonPressed:(UIButton *)sender {
    //Show UIActionSheet with import/export options
    UIActionSheet *importExportActionSheet=[[UIActionSheet alloc] initWithTitle:@"Import/Export" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import Records",@"Export Records",@"Import Formations",@"Export Formations", nil];
    [importExportActionSheet showInView:self.contentView];
    
    //Dismiss all the popovers
    if (self.popoverViewController.isPopoverVisible)
        [self.popoverViewController dismissPopoverAnimated:YES];
    if (self.formationFolderPopoverController.isPopoverVisible)
        [self.formationFolderPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)dataMapSwitchValueChanged:(UISegmentedControl *)sender {
    //Notify the data map segment controller of the change
    int segmentIndex=sender.selectedSegmentIndex;
    DataMapSegmentViewController *dataMapSegmentVC=(DataMapSegmentViewController *)self.viewGroupController;
    [dataMapSegmentVC segmentController:sender indexDidChangeTo:segmentIndex];
}

#pragma mark - UINavigationViewControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated
{
}

#pragma mark - Model Group Notifcation Handlers

- (void)modelGroupFolderDatabaseDidUpdate:(NSNotification *)notification {
    NSLog(@"Folder Database Did Update!");
}

- (void)modelGroupRecordDatabaseDidUpdate:(NSNotification *)notification {
    NSLog(@"Record Database Did Update!");
}

- (void)modelGroupDidCreateNewRecord:(NSNotification *)notification {
    NSLog(@"Created New Record!");
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
        else if ([segue.identifier isEqualToString:@"viewGroupController"])
            self.viewGroupController=[self.storyboard instantiateViewControllerWithIdentifier:@"viewGroupController"];
    }
        
    //Formation folder segue
    if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        NSLog(@"Showing formation folders!");
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
    UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMasterPopover:)];
    [self.contentView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Get the data map segment controller
    DataMapSegmentViewController *dataMapSegmentVC=(DataMapSegmentViewController *)self.viewGroupController;
    
    //Setup the view controller hierachy
    [self addChildViewController:dataMapSegmentVC];
    [self.viewGroupController willMoveToParentViewController:self];
    
    //Adjust the frame of the specified view controller's view
    dataMapSegmentVC.view.frame=self.contentView.bounds;
    
    //Add the view of the data map segment
    [self.contentView addSubview:dataMapSegmentVC.view];
    [dataMapSegmentVC didMoveToParentViewController:self];
    
    //Put up the initial view
    if (!dataMapSegmentVC.topViewController)
        [dataMapSegmentVC swapToViewControllerAtSegmentIndex:0];
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

//- (UIAlertView *)autosaveAlertForValidationOfRecordInfo:(NSDictionary *)recordInfo {
//    UIAlertView *autosaveAlert=nil;
//    
//    //If the record info passes the validations, show the alert; otherwise, show an alert with no confirm button
//    NSArray *failedKeyNames=[Record validatesMandatoryPresenceOfRecordInfo:recordInfo];
//    if (![failedKeyNames count]) {
//        //If the name of the record is not nil
//        NSString *message=@"You are navigating away. Do you want to save the record you were editing?";
//        
//        //Put up an alert to ask the user whether he/she wants to save
//        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave" 
//                                                              message:message 
//                                                             delegate:self 
//                                                    cancelButtonTitle:@"Don't Save" 
//                                                    otherButtonTitles:@"Save", nil];
//    } else {
//        //Show the autosave fail alert with all the missing record info
//        NSMutableArray *failedNames=[NSMutableArray array];
//        for (NSString *failedKey in failedKeyNames)
//            [failedNames addObject:[Record nameForDictionaryKey:failedKey]];
//        NSString *message=[NSString stringWithFormat:@"Record could not be saved because the following information was missing: %@",[failedNames componentsJoinedByString:@", "]];
//        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave Failed!" 
//                                                                  message:message 
//                                                                 delegate:nil 
//                                                        cancelButtonTitle:@"Dismiss" 
//                                                        otherButtonTitles:nil];
//    }
//    
//    return autosaveAlert;
//}
//
//- (void)autosaveRecord:(Record *)record 
//     withNewRecordInfo:(NSDictionary *)recordInfo 
//{
//    //Save the recordInfo dictionary in a temporary property
//    self.recordModifiedInfo=recordInfo;
//    
//    //Save the record in a temporary property
//    self.modifiedRecord=record;
//    
//    //Get and show the appropriate alert
//    UIAlertView *autosaveAlert=[self autosaveAlertForValidationOfRecordInfo:recordInfo];
//    [autosaveAlert show];
//}

@end
