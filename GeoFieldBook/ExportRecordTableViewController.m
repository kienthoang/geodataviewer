//
//  ExportRecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportRecordTableViewController.h"

@interface ExportRecordTableViewController()

@end

@implementation ExportRecordTableViewController

@synthesize doubleTableViewController=_doubleTableViewController;
@synthesize selectedRecords=_selectedRecords;

#pragma mark - Getters and Setters

- (void)setSelectedRecords:(NSSet *)selectedRecords {
    _selectedRecords=selectedRecords;
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
    
    //Select all the selected records in the table view
    if (selectedRecords) {
        for (Record *record in selectedRecords) {
            NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:record];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
}

@end
