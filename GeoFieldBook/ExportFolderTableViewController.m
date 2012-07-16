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
@synthesize selectedRecords=_selectedRecords;

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
    if (!_selectedRecords)
        _selectedRecords=[NSArray array];
    
    return _selectedRecords;
}

#pragma mark - UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Get the folder corresponding to the given index path
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Pass the folder to the export record tvc
    self.exportRecordTableViewController.folder=folder;
    
    //Pass the selected records to the export record tvc
    self.exportRecordTableViewController.selectedRecords=[self.selectedRecordsForFolders objectForKey:folder.folderName];
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
        self.exportRecordTableViewController.selectedRecords=[self.selectedRecordsForFolders objectForKey:folder.folderName];
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
        self.exportRecordTableViewController.selectedRecords=[self.selectedRecordsForFolders objectForKey:folder.folderName];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
}

@end
