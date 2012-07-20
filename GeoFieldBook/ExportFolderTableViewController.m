//
//  ExportFolderTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportFolderTableViewController.h"
#import "ExportRecordTableViewController.h"

@interface ExportFolderTableViewController ()

@property (nonatomic,readonly) ExportRecordTableViewController *exportRecordTableViewController;
@property (nonatomic,strong) NSDictionary *selectedRecordsForFolders;

@end

@implementation ExportFolderTableViewController

@synthesize doubleTableViewController=_doubleTableViewController;
@synthesize selectedRecordsForFolders=_selectedRecordsForFolders;

@synthesize exportButtonOwner=_exportButtonOwner;

#pragma mark - Getters and Setters

- (ExportRecordTableViewController *)exportRecordTableViewController {
    return (ExportRecordTableViewController *)self.doubleTableViewController.detailTableViewController;
}

- (NSDictionary *)selectedRecordsForFolders {
    if (!_selectedRecordsForFolders)
        _selectedRecordsForFolders=[NSDictionary dictionary];
    
    return _selectedRecordsForFolders;
}

- (NSArray *)selectedRecords {
    //Return all the selected records
    NSMutableArray *selectedRecords=[NSMutableArray array];
    for (NSSet *records in self.selectedRecordsForFolders.allValues)
        [selectedRecords addObjectsFromArray:records.allObjects];
    
    //Sort the selected records
    return [selectedRecords sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],nil]];    
}

- (void)updateExportButton {
    //Notify the export button owner
    [self.exportButtonOwner needsUpdateExportButtonForNumberOfSelectedItems:self.selectedRecords.count];
}

#pragma mark - UITableViewDataSource protocol methods

- (void)updateSubtitleForTableCell:(CustomFolderCell *)folderCell {
    NSIndexPath *indexPath=[self.tableView indexPathForCell:folderCell];
    if (indexPath) {
        //Modify the cell's subtitle
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        int numSelectedRecords=[[self.selectedRecordsForFolders objectForKey:folder.folderName] count];
        NSString *recordCounter=[folder.records count]>1 ? @"Records" : @"Record";
        folderCell.subtitle.text=[NSString stringWithFormat:@"%d %@ (%d selected)",folder.records.count,recordCounter,numSelectedRecords];         
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Modify the cell's subtitle
    CustomFolderCell *folderCell=(CustomFolderCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    folderCell.subtitle.text=[folderCell.subtitle.text stringByAppendingString:@" (0 selected)"];
    [self updateSubtitleForTableCell:folderCell];
    
    return folderCell;
}

#pragma mark - UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Get the folder corresponding to the given index path
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
    //Update
    [self userDidChangeSelectedRecordsForFolder:folder];
}

- (void)updateCellCorrespondingToFolder:(Folder *)folder {
    //update the subtitle of the table cells to show the number of selected records
    CustomFolderCell *folderCell=(CustomFolderCell *)[self.tableView cellForRowAtIndexPath:[self.fetchedResultsController indexPathForObject:folder]];
    [self updateSubtitleForTableCell:folderCell];
}

- (void)userDidChangeSelectedRecordsForFolder:(Folder *)folder {
    //Pass the folder to the export record tvc
    self.exportRecordTableViewController.folder=folder;
    
    //Pass the selected records to the export record tvc
    [self.exportRecordTableViewController updateSelectedRecordsWith:[self.selectedRecordsForFolders objectForKey:folder.folderName]];
    
    //Update corresponding cell
    [self updateCellCorrespondingToFolder:folder];
        
    //Update export button
    [self updateExportButton];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedRecordsForFolders=self.selectedRecordsForFolders.mutableCopy;
    [selectedRecordsForFolders setObject:folder.records  forKey:folder.folderName];
    self.selectedRecordsForFolders=selectedRecordsForFolders.copy;
    
    //Update
    [self userDidChangeSelectedRecordsForFolder:folder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedRecordsForFolders=self.selectedRecordsForFolders.mutableCopy;
    [selectedRecordsForFolders setObject:[NSSet set]  forKey:folder.folderName];
    self.selectedRecordsForFolders=selectedRecordsForFolders.copy;
    
    //Update
    [self userDidChangeSelectedRecordsForFolder:folder];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
}

#pragma mark - ExportRecordTVCDelegate protocol methods

- (void)exportTVC:(ExportRecordTableViewController *)sender userDidSelectRecords:(NSSet *)records forFolder:(Folder *)folder {
    //Save the selected records
    NSMutableDictionary *selectedRecordsByFolder=self.selectedRecordsForFolders.mutableCopy;
    [selectedRecordsByFolder setObject:records forKey:folder.folderName];
    self.selectedRecordsForFolders=selectedRecordsByFolder;  
    
    //Update corresponding cell
    [self updateCellCorrespondingToFolder:folder];
    
    //Update export button
    [self updateExportButton];
    
    //Select/Deselect Cell if appropriate
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:folder];
    NSArray *selectedIndexPaths=self.tableView.indexPathsForSelectedRows;
    if (records.count) {
        if (![selectedIndexPaths containsObject:indexPath]) 
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        if ([selectedIndexPaths containsObject:indexPath])
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    }
}

@end