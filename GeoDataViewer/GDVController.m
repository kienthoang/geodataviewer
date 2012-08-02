//
//  GDVController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVController.h"

@interface GDVController() <ImportTableViewControllerDelegate,UIActionSheetDelegate>

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
@synthesize feedbackList=_feedbackList;
@synthesize formationListPopover=_formationListPopover;
@synthesize importPopover=_importPopover;

@synthesize mapViewController=_mapViewController;

#pragma mark - Getters and Setters

- (GDVResourceManager *)resourceManager {
    return [GDVResourceManager defaultResourceManager];
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Segue to record list
    NSString *segueIdentifier=segue.identifier;
    if ([segueIdentifier isEqualToString:@"Record List"]) {
         UIViewController *recordList=[self.storyboard instantiateViewControllerWithIdentifier:@"Record List"];
        self.recordList=[[UIPopoverController alloc] initWithContentViewController:recordList];
    }
    
    //Segue to feedback list
    else if ([segueIdentifier isEqualToString:@"Feedback List"]) {
        UIViewController *feedbackList=[self.storyboard instantiateViewControllerWithIdentifier:@"Feedback List"];
        self.feedbackList=[[UIPopoverController alloc] initWithContentViewController:feedbackList];
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

- (void)presentFeedbackImportPopover {
    //Dismiss all visible popovers
    [self dismissAllVisiblePopoversAnimated:NO];
    
    //Instantiate the record import popover
    UINavigationController *feedbackImportTVC=[self.storyboard instantiateViewControllerWithIdentifier:FEEDBACK_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER];
    self.importPopover=[[UIPopoverController alloc] initWithContentViewController:feedbackImportTVC];
    
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
            
            //If user clicked import feedbacks
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Import Feedbacks"]) {
                [self presentFeedbackImportPopover];
            }
        }
    }
}


#pragma mark - Target-Action Handlers

- (void)dismissAllVisiblePopoversAnimated:(BOOL)animated {
    [self.formationListPopover dismissPopoverAnimated:NO];
    [self.recordList dismissPopoverAnimated:NO];
    [self.feedbackList dismissPopoverAnimated:NO];
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
    [self.feedbackList presentPopoverFromBarButtonItem:self.feedbackListButton 
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
                                                              otherButtonTitles:@"Import Records",@"Import Formations", @"Import Feedbacks",nil];
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
    [self performSegueWithIdentifier:@"Feedback List" sender:nil];
    [self performSegueWithIdentifier:@"Map View" sender:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self setFeedbackListButton:nil];
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

@end
