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
@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (NSSet *)selectedRecords {
    if (!_selectedRecords)
        _selectedRecords=[NSSet set];
    
    return _selectedRecords;
}

- (void)updateSelectedRecordsWith:(NSSet *)records {
    self.selectedRecords=records;
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
    
    //Select all the selected records in the table view
    if (self.selectedRecords) {
        for (Record *record in self.selectedRecords) {
            NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:record];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    //Scroll the table view to show the top
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
}

#pragma mark - UITableView Delegate Protocol methods

- (void)userDidSelectRecords {
    //Notify the delegate
    [self.delegate exportTVC:self userDidSelectRecords:self.selectedRecords forFolder:self.folder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add the selected record to the set of selected records
    Record *selectedRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableSet *selectedRecords=self.selectedRecords.mutableCopy;
    [selectedRecords addObject:selectedRecord];
    self.selectedRecords=selectedRecords.copy;
    
    //Process
    [self userDidSelectRecords];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Remove the selected record from the set of selected records
    Record *selectedRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableSet *selectedRecords=self.selectedRecords.mutableCopy;
    [selectedRecords removeObject:selectedRecord];
    self.selectedRecords=selectedRecords.copy;
    
    //Process
    [self userDidSelectRecords];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

@end
