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

#pragma mark - UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Get the folder corresponding to the given index path
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Pass the folder to the export record tvc
    self.exportRecordTableViewController.folder=folder;
    
    //Pass the selected records to the export record tvc
    [self.exportRecordTableViewController updateSelectedRecordsWith:[self.selectedRecordsForFolders objectForKey:folder.folderName]];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedRecordsForFolders=self.selectedRecordsForFolders.mutableCopy;
    [selectedRecordsForFolders setObject:folder.records  forKey:folder.folderName];
    self.selectedRecordsForFolders=selectedRecordsForFolders.copy;
    
    //Pass the folder to the export record tvc
    self.exportRecordTableViewController.folder=folder;
    
    //If the folder of the export record tvc is the same as the selected folder, update its selected records
    if (self.exportRecordTableViewController.folder==folder) {
        //Pass the selected records to the export record tvc
        [self.exportRecordTableViewController updateSelectedRecordsWith:[self.selectedRecordsForFolders objectForKey:folder.folderName]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedRecordsForFolders=self.selectedRecordsForFolders.mutableCopy;
    [selectedRecordsForFolders setObject:[NSSet set]  forKey:folder.folderName];
    self.selectedRecordsForFolders=selectedRecordsForFolders.copy;
    
    //Pass the folder to the export record tvc
    self.exportRecordTableViewController.folder=folder;
    
    //If the folder of the export record tvc is the same as the selected folder, update its selected records
    if (self.exportRecordTableViewController.folder==folder) {
        //Pass the selected records to the export record tvc
        [self.exportRecordTableViewController updateSelectedRecordsWith:[self.selectedRecordsForFolders objectForKey:folder.folderName]];
    }
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
}

@end
