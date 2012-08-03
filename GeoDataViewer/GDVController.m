//
//  GDVController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVController.h"

@interface GDVController() <ImportTableViewControllerDelegate,UIActionSheetDelegate,GDVStudentGroupTVCDelegate,GDVFolderTVCDelegate,GDVFormationFolderTVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordListButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *formationListButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *feedbackListButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importExportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic, strong) UIPopoverController *importPopover;

@end

@implementation GDVController

@synthesize contentView = _contentView;

@synthesize recordListButton = _recordListButton;
@synthesize formationListButton = _formationListButton;
@synthesize feedbackListButton = _feedbackListButton;
@synthesize importExportButton = _importExportButton;
@synthesize settingsButton = _settingsButton;

@synthesize recordList=_recordList;
@synthesize studentResponseList=_studentResponseList;
@synthesize formationListPopover=_formationListPopover;
@synthesize importPopover=_importPopover;

@synthesize mapViewController=_mapViewController;

#pragma mark - Getters and Setters

- (GDVResourceManager *)resourceManager {
    return [GDVResourceManager defaultResourceManager];
}

#pragma mark - View Manipulators

- (UINavigationController *)recordListNav {
    return (UINavigationController *)self.recordList.contentViewController;
}

- (GDVStudentGroupTVC *)recordListStudentGroupTVC {
    UIViewController *studentGroupTVC=self.recordListNav.topViewController;
    if ([studentGroupTVC isKindOfClass:[GDVStudentGroupTVC class]]) 
        studentGroupTVC=nil;
    
    return (GDVStudentGroupTVC *)studentGroupTVC;
}

- (UINavigationController *)formationListNav {
    return self.formationListPopover.isPopoverVisible ? (UINavigationController *)self.formationListPopover.contentViewController : nil;
}

- (GDVFormationFolderTVC *)formationFolderTVC {
    UIViewController *formationFolderTVC=self.formationListNav.topViewController;
    if ([formationFolderTVC isKindOfClass:[GDVFormationFolderTVC class]]) 
        formationFolderTVC=nil;
    
    return (GDVFormationFolderTVC *)formationFolderTVC;
}

- (UINavigationController *)studentResponseListNav {
    return (UINavigationController *)self.studentResponseList.contentViewController;
}

- (GDVStudentGroupTVC *)studentResponseListStudentGroupTVC {
    UIViewController *studentGroupTVC=self.studentResponseListNav.topViewController;
    if ([studentGroupTVC isKindOfClass:[GDVStudentGroupTVC class]]) 
        studentGroupTVC=nil;
    
    return (GDVStudentGroupTVC *)studentGroupTVC;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Segue to record list
    NSString *segueIdentifier=segue.identifier;
    if ([segueIdentifier isEqualToString:@"Record List"]) {
         UIViewController *recordList=[self.storyboard instantiateViewControllerWithIdentifier:@"Record List"];
        self.recordList=[[UIPopoverController alloc] initWithContentViewController:recordList];
    }
    
    //Segue to Student Response List
    else if ([segueIdentifier isEqualToString:@"Student Response List"]) {
        UIViewController *feedbackList=[self.storyboard instantiateViewControllerWithIdentifier:@"Student Response List"];
        self.studentResponseList=[[UIPopoverController alloc] initWithContentViewController:feedbackList];
    }
    
    //Segue to map view
    else if ([segueIdentifier isEqualToString:@"Map View"]) {
        //Instantiate the map vc
        self.mapViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
        
        //Add map vc as child vc
        RecordMapViewController *mapViewController=self.mapViewController;
        self.mapViewController.view.frame=self.contentView.bounds;
        [mapViewController willMoveToParentViewController:self];
        [self addChildViewController:mapViewController];
        [self.contentView addSubview:mapViewController.mapView];
        [mapViewController didMoveToParentViewController:self];
    }
    
    //Segue to formation list
    else if ([segueIdentifier isEqualToString:@"Formation List"]) {
        //Save the popover
        self.formationListPopover=[(UIStoryboardPopoverSegue *)segue popoverController];
    }
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

- (void)presentStudentResponseImportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the student response import popover
    UINavigationController *studentResponseImportTVC=[self.storyboard instantiateViewControllerWithIdentifier:STUDENT_RESPONSE_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.importPopover=[[UIPopoverController alloc] initWithContentViewController:studentResponseImportTVC];
    
    //Present it
    [self.importPopover presentPopoverFromBarButtonItem:self.importExportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
            
            //If user clicked import student responses
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Import Student Responses"]) {
                [self presentStudentResponseImportPopover];
            }
        }
    }
}

#pragma mark - KVO/NSNotification Managers

- (void)recordDatabaseDidChange:(NSNotification *)notification {
    //Pop record list's nav to root vc
    [self.recordListNav popToRootViewControllerAnimated:YES];
    
    //Show loading screen in the student group vc in record list
    GDVStudentGroupTVC *studentGroupTVC=self.recordListStudentGroupTVC;
    [studentGroupTVC showLoadingScreen];
    
    //Update student groups
    [self.resourceManager fetchStudentGroupsWithCompletionHandler:^(NSArray *studentGroups){
        if (studentGroups)
            studentGroupTVC.studentGroups=studentGroups;
    }];
}

- (void)formationDatabaseDidChange:(NSNotification *)notification {
    //Pop formation list's nav to root vc if the formation list popover is visible (if not, the formationListNav will be nil, and popToRootVCAnimated will have no effect
    [self.formationListNav popToRootViewControllerAnimated:YES];
    
    //Show loading screen in the formation folder vc in formation list
    GDVFormationFolderTVC *formationFolderTVC=self.formationFolderTVC;
    [formationFolderTVC showLoadingScreen];
    
    //Update formation folders
    [self.resourceManager fetchFormationFoldersWithCompletionHandler:^(NSArray *formationFolders){
        if (formationFolderTVC)
            formationFolderTVC.formationFolders=formationFolders;
    }];
}

- (void)studentResponseDatabaseDidChange:(NSNotification *)notification {
    //Pop student response list's nav to root vc
    [self.studentResponseListNav popToRootViewControllerAnimated:YES];
    
    //Show loading screen in the student group vc in student response list
    GDVStudentGroupTVC *studentGroupTVC=self.studentResponseListStudentGroupTVC;
    [studentGroupTVC showLoadingScreen];
    
    //Update student groups
    [self.resourceManager fetchStudentGroupsWithCompletionHandler:^(NSArray *studentGroups){
        if (studentGroups)
            studentGroupTVC.studentGroups=studentGroups;
    }];
}

- (void)registerNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(recordDatabaseDidChange:) 
                               name:GDVResourceManagerRecordDatabaseDidUpdate 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(formationDatabaseDidChange:) 
                               name:GDVResourceManagerFormationDatabaseDidUpdate 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(studentResponseDatabaseDidChange:) 
                               name:GDVResourceManagerStudentResponseDatabaseDidUpdate 
                             object:nil];
}

#pragma mark - Target-Action Handlers

- (void)dismissAllVisiblePopoversAnimated:(BOOL)animated {
    [self.formationListPopover dismissPopoverAnimated:NO];
    [self.recordList dismissPopoverAnimated:NO];
    [self.studentResponseList dismissPopoverAnimated:NO];
    [self.importPopover dismissPopoverAnimated:NO];
    self.importPopover=nil;
}

- (IBAction)recordListButtonPressed:(UIButton *)recordListButton 
{    
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Present
    [self.recordList presentPopoverFromBarButtonItem:self.recordListButton 
                                       permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                       animated:YES];
}

- (IBAction)formationButtonPressed:(UIButton *)sender {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Segue to the formation folder popover
    [self performSegueWithIdentifier:@"Formation List" sender:self.formationListButton];
}

- (IBAction)feedbackButtonPressed:(UIButton *)sender {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Present
    [self.studentResponseList presentPopoverFromBarButtonItem:self.feedbackListButton 
                              permittedArrowDirections:UIPopoverArrowDirectionAny 
                                              animated:YES];
}

- (IBAction)importExportButtonPressed:(UIButton *)sender {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Show UIActionSheet with import/export options
    UIActionSheet *importExportActionSheet=[[UIActionSheet alloc] initWithTitle:IMPORT_EXPORT_ACTION_SHEET_TITLE 
                                                                       delegate:self 
                                                              cancelButtonTitle:@"Cancel" 
                                                         destructiveButtonTitle:nil 
                                                              otherButtonTitles:@"Import Records",@"Import Formations", @"Import Student Responses",nil];
    [importExportActionSheet showInView:self.contentView];
}

- (IBAction)settingButtonPressed:(UIButton *)sender {
    //Segue to the settings view controller
    //[self performSegueWithIdentifier:@"Settings" sender:nil];
}

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Perform custom segues
    [self performSegueWithIdentifier:@"Record List" sender:nil];
    [self performSegueWithIdentifier:@"Student Response List" sender:nil];
    [self performSegueWithIdentifier:@"Map View" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Register to receive notifications
    [self registerNotifications];
    
    //Change the look of the master presenter
    UIButton *recordListButtonCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [recordListButtonCustomView setImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
    recordListButtonCustomView.frame=CGRectMake(0, 0, 32, 32);
    [recordListButtonCustomView addTarget:self action:@selector(recordListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    recordListButtonCustomView.showsTouchWhenHighlighted=YES;
    self.recordListButton.customView=recordListButtonCustomView;
    
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
    self.formationListButton.customView=formationButtonCustomView;
    
    //Change the look of the settings button
    UIButton *settingButtonCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [settingButtonCustomView setImage:[UIImage imageNamed:@"gear2.png"] forState:UIControlStateNormal];
    settingButtonCustomView.frame=CGRectMake(0, 0, 30, 30);
    [settingButtonCustomView addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    settingButtonCustomView.showsTouchWhenHighlighted=YES;
    self.settingsButton.customView=settingButtonCustomView;
    
    //Change the look of the group button
    UIButton *feedbackListCustomView=[UIButton buttonWithType:UIButtonTypeCustom];
    [feedbackListCustomView setImage:[UIImage imageNamed:@"group.png"] forState:UIControlStateNormal];
    feedbackListCustomView.frame=CGRectMake(0, 0, 30, 30);
    [feedbackListCustomView addTarget:self action:@selector(feedbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    feedbackListCustomView.showsTouchWhenHighlighted=YES;
    self.feedbackListButton.customView=feedbackListCustomView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setRecordListButton:nil];
    [self setFormationListButton:nil];
    [self setImportExportButton:nil];
    [self setSettingsButton:nil];
    [super viewDidUnload];
}

#pragma mark - ImportTableViewControllerDelegate Protocol Methods

- (void)userDidSelectRecordCSVFiles:(NSArray *)files forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
    [self.resourceManager importRecordCSVFiles:files];
}

- (void)userDidSelectFormationCSVFiles:(NSArray *)files forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
    [self.resourceManager importFormationCSVFiles:files];
}

- (void)userDidSelectFeedbackCSVFiles:(NSArray *)files forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
    [self.resourceManager importFeedbackCSVFiles:files];
}

#pragma mark - GDVStudentGroupTVCDelegate Protocol Methods

- (void)studentGroupTVC:(GDVStudentGroupTVC *)sender preparedToSegueToFolderTVC:(GDVFolderTVC *)folderTVC
{
    //Load the folders
    [self.resourceManager fetchFoldersForStudentGroup:folderTVC.studentGroup completion:^(NSArray *folders) {
        if (folders)
            folderTVC.folders=folders;
    }];
    
    //Set the delegate of the folder TVC
    folderTVC.delegate=self;
}

- (void)studentGroupTVC:(GDVStudentGroupTVC *)sender preparedToSegueToStudentResponseTVC:(GDVStudentResponseTVC *)studentResponseTVC
{
    //Load the student responses
    [self.resourceManager fetchStudentResponsesForStudentGroup:studentResponseTVC.studentGroup completion:^(NSArray *studentResponses) {
        if (studentResponses)
            studentResponseTVC.studentResponses=studentResponses;
    }];
}

#pragma mark - GDVFolderTVCDelegate Protocol Methods

- (void)folderTVC:(GDVFolderTVC *)sender preparedToSegueToRecordTVC:(GDVRecordTVC *)recordTVC 
{
    //Load the records
    [self.resourceManager fetchRecordsForFolder:recordTVC.folder completion:^(NSArray *records) {
        if (records)
            recordTVC.records=records;
    }];
}

#pragma mark - GDVFormationFolderTVCDelegate Protocol Methods

- (void)formationFolderTVC:(GDVFormationFolderTVC *)sender preparedToSegueToFormationTVC:(GDVFormationTableViewController *)formationTVC
{
    //Load the formation
    [self.resourceManager fetchFormationsForFormationFolder:formationTVC.formationFolder completion:^(NSArray *formations) {
        if (formations)
            formationTVC.formations=formations;
    }];
}

@end
