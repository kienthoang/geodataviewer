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
    
    
    //UITableViewController *exportTVC;
    
    if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
        ExportFolderTableViewController *exportFolderTVC = (ExportFolderTableViewController *)self.masterTableViewController;
        exportFolderTVC.exportButtonOwner=self;
        [(ExportRecordTableViewController *)self.detailTableViewController setDelegate:exportFolderTVC];
    }
    else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
        ExportFormationFolderTableViewController *exportFormationsTVC = (ExportFormationFolderTableViewController *)self.masterTableViewController;
        [(ExportFormationTableViewController *)self.detailTableViewController setDelegate:exportFormationsTVC];
    }
    else {
        //
    }
    
    //Set the delegate of the export record tvc to be the export folder tvc
    //ExportFolderTableViewController *exportFolderTVC=(ExportFolderTableViewController *)self.masterTableViewController;
    //[(ExportRecordTableViewController *)self.detailTableViewController setDelegate:exportFolderTVC];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Target-Action Handlers

- (IBAction)exportPressed:(UIBarButtonItem *)sender {
    //Export the records
    NSArray *exportedItems;
    
    if ([self.masterTableViewController isKindOfClass:[ExportFolderTableViewController class]]) {
        exportedItems = [(ExportFolderTableViewController *)self.masterTableViewController selectedRecords];
    }
    else if ([self.masterTableViewController isKindOfClass:[ExportFormationFolderTableViewController class]]) {
        exportedItems = [(ExportFormationFolderTableViewController *)self.masterTableViewController selectedFormations];
    }
    else {
        //
    }
    
    //NSArray *exportedRecords=[(ExportFolderTableViewController *)self.masterTableViewController selectedRecords];
    [self.exportEngine createCSVFilesFromRecords:exportedItems];
}

- (void)viewDidUnload {
    [self setExportButton:nil];
    [super viewDidUnload];
}

#pragma mark - ExportButtonOwner Protocol methods

- (void)needsUpdateExportButtonForNumberOfSelectedItems:(int)count {
    NSString *exportButtonTitle=count ? [NSString stringWithFormat:@"Export (%d)",count] : @"Export";
    self.exportButton.title=exportButtonTitle;
}

@end
