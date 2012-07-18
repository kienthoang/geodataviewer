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

#import "IEEngine.h"

@interface ExportDoubleTableViewController()

@property (nonatomic,strong) IEEngine *exportEngine;

@end

@implementation ExportDoubleTableViewController

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
    
    //Set the delegate of the export record tvc to be the export folder tvc
    ExportFolderTableViewController *exportFolderTVC=(ExportFolderTableViewController *)self.masterTableViewController;
    [(ExportRecordTableViewController *)self.detailTableViewController setDelegate:exportFolderTVC];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Target-Action Handlers

- (IBAction)exportPressed:(UIBarButtonItem *)sender {
    //Export the records
    NSArray *exportedRecords=[(ExportFolderTableViewController *)self.masterTableViewController selectedRecords];
    [self.exportEngine createCSVFilesFromRecords:exportedRecords];
}

@end
