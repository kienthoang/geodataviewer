//
//  ExportFormationFolderTableViewController.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportFormationFolderTableViewController.h"
#import "ExportFormationTableViewController.h"

@interface ExportFormationFolderTableViewController ()

@property (nonatomic,readonly) ExportFormationTableViewController *exportFormationTableViewController;
@property (nonatomic,strong) NSDictionary *selectedFormationsForFolders;

@end

@implementation ExportFormationFolderTableViewController

@synthesize doubleTableViewController=_doubleTableViewController;
@synthesize selectedFormationsForFolders=_selectedFormationsForFolders;
@synthesize selectedFormations=_selectedFormations;

#pragma mark - Getters and Setters

- (ExportFormationTableViewController *)exportFormationTableViewController {
    return (ExportFormationTableViewController *)self.doubleTableViewController.detailTableViewController;
}

- (NSDictionary *)selectedFormationsForFolders {
    if (!_selectedFormationsForFolders)
        _selectedFormationsForFolders=[NSDictionary dictionary];
    
    return _selectedFormationsForFolders;
}

- (NSArray *)selectedFormations {
    if (!_selectedFormations)
        _selectedFormations=[NSArray array];
    
    return _selectedFormations;
}

#pragma mark - UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Get the folder corresponding to the given index path
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Pass the folder to the export record tvc
    self.exportFormationTableViewController.folder=folder;
    
    //Pass the selected records to the export record tvc
    self.exportFormationTableViewController.selectedFormations=[self.selectedFormationsForFolders objectForKey:folder.folderName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedFormationsForFolders=self.selectedFormationsForFolders.mutableCopy;
    [selectedFormationsForFolders setObject:folder.formations  forKey:folder.folderName];
    self.selectedFormationsForFolders=selectedFormationsForFolders.copy;
    
    //Pass the folder to the export record tvc
    self.exportFormationTableViewController.folder=folder;
    
    //If the folder of the export record tvc is the same as the selected folder, update its selected records
    if (self.exportFormationTableViewController.folder==folder) {
        //Pass the selected records to the export record tvc
        self.exportFormationTableViewController.selectedFormations=[self.selectedFormationsForFolders objectForKey:folder.folderName];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedFormationsForFolders=self.selectedFormationsForFolders.mutableCopy;
    [selectedFormationsForFolders setObject:[NSSet set]  forKey:folder.folderName];
    self.selectedFormationsForFolders=selectedFormationsForFolders.copy;
    
    //Pass the folder to the export record tvc
    self.exportFormationTableViewController.folder=folder;
    
    //If the folder of the export record tvc is the same as the selected folder, update its selected records
    if (self.exportFormationTableViewController.folder==folder) {
        //Pass the selected records to the export record tvc
        self.exportFormationTableViewController.selectedFormations=[self.selectedFormationsForFolders objectForKey:folder.folderName];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
    self.tableView.allowsMultipleSelectionDuringEditing=YES;
}

@end