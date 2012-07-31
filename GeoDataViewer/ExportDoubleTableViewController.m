//
//  ExportDoubleTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportDoubleTableViewController.h"

#import "ExportFolderTableViewController.h"
#import "ExportRecordTableViewController.h"

#import "ExportFormationFolderTableViewController.h"
#import "ExportFormationTableViewController.h"

#import "IEEngine.h"
#import "IEEngineNotificationNames.h"

@interface ExportDoubleTableViewController()

@property (nonatomic,strong) IEEngine *exportEngine;

@end

@implementation ExportDoubleTableViewController
@synthesize exportButton = _exportButton;

@synthesize exportEngine=_exportEngine;

#pragma mark - Getters

- (IEEngine *)exportEngine {
    if (!_exportEngine)
        _exportEngine=[[IEEngine alloc] init];
    
    return _exportEngine;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
        ExportFolderTableViewController *exportFolderTVC = (ExportFolderTableViewController *)self.masterTableViewController;
        exportFolderTVC.exportButtonOwner=self;
        [(ExportRecordTableViewController *)self.detailTableViewController setDelegate:exportFolderTVC];
    }
    else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
        ExportFormationFolderTableViewController *exportFormationFolderTVC = (ExportFormationFolderTableViewController *)self.masterTableViewController;
        exportFormationFolderTVC.exportButtonOwner=self;
        [(ExportFormationTableViewController *)self.detailTableViewController setDelegate:exportFormationFolderTVC];
    }
    
    //Register to hear notification
    [self registerForIEEngineNotifications];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setExportButton:nil];
    [super viewDidUnload];
}

#pragma mark - KVO Notification Managers

- (void)registerForIEEngineNotifications {
    //Register to receive notifications from the model group
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(exportingDidEnd:) 
                               name:GeoNotificationIEEngineExportingDidEnd 
                             object:nil];
}

- (void)exportingDidEnd:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Put the export button back
        self.navigationItem.rightBarButtonItem=self.exportButton;
    });    
}

#pragma mark - Target-Action Handlers

- (IBAction)exportPressed:(UIBarButtonItem *)sender {    
    //Do the exporting in a different thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
            //Export records
            NSArray *exportedRecords=[(ExportFolderTableViewController *)self.masterTableViewController selectedRecords];
            [self.exportEngine createCSVFilesFromRecords:exportedRecords];
        }
        else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
            //Export Formations
            NSArray *exportedFormations=[(ExportFormationFolderTableViewController *)self.masterTableViewController selectedFormations];
            [self.exportEngine createCSVFilesFromFormationsWithColors:exportedFormations];
        }
    });
    
    //Put the spinner in place of the export button
    UIActivityIndicatorView *spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
}

#pragma mark - ExportButtonOwner Protocol methods

- (void)needsUpdateExportButtonForNumberOfSelectedItems:(int)count {
    //Update the title of the export button
    NSString *exportButtonTitle=count ? [NSString stringWithFormat:@"Export (%d)",count] : @"Export";
    self.exportButton.title=exportButtonTitle;
    
    //Disable the export button if there is no record to export
    self.exportButton.enabled=count>0;
}

@end
