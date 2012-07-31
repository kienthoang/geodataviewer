//
//  ExportFormationFolderTableViewController.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportFormationFolderTableViewController.h"
#import "ExportFormationTableViewController.h"

#import "Formation_Folder.h"

@interface ExportFormationFolderTableViewController ()

@property (nonatomic,readonly) ExportFormationTableViewController *exportFormationTableViewController;
@property (nonatomic,strong) NSDictionary *selectedFormationsForFolders;

@end

@implementation ExportFormationFolderTableViewController

@synthesize doubleTableViewController=_doubleTableViewController;
@synthesize selectedFormationsForFolders=_selectedFormationsForFolders;
@synthesize selectedFormations=_selectedFormations;

@synthesize exportButtonOwner=_exportButtonOwner;

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
    //Return all the selected formations
    NSMutableArray *selectedFormations=[NSMutableArray array];
    for (NSSet *formations in self.selectedFormationsForFolders.allValues)
        [selectedFormations addObjectsFromArray:formations.allObjects];
    
    //Sort the selected records
    return [selectedFormations sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"formationFolder.folderName" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"formationSortNumber" ascending:YES],nil]];    
}

- (void)updateExportButton {
    //Notify the export button owner
    [self.exportButtonOwner needsUpdateExportButtonForNumberOfSelectedItems:self.selectedFormations.count];
}

#pragma mark - UITableViewDataSource Protocol methods

- (void)updateSubtitleForTableCell:(UITableViewCell *)folderCell {
    NSIndexPath *indexPath=[self.tableView indexPathForCell:folderCell];
    if (indexPath) {
        //Modify the cell's subtitle
        Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        int numSelectedFormations=[[self.selectedFormationsForFolders objectForKey:folder.folderName] count];
        NSString *formationCounter=[folder.formations count]>1 ? @"Formations" : @"Formation";
        folderCell.detailTextLabel.text=[NSString stringWithFormat:@"%d %@ (%d selected)",folder.formations.count,formationCounter,numSelectedFormations];         
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Modify the cell's subtitle
    UITableViewCell *folderCell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
    folderCell.detailTextLabel.text=[folderCell.detailTextLabel.text stringByAppendingString:@" (0 selected)"];
    [self updateSubtitleForTableCell:folderCell];
    
    return folderCell;
}

#pragma mark - UITableViewDelegate Protocol methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Get the formation folder corresponding to the given index path
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Update
    [self userDidChangeSelectedFormationsForFolder:folder];
}

- (void)updateCellCorrespondingToFolder:(Formation_Folder *)folder {
    //update the subtitle of the table cells to show the number of selected formations
    UITableViewCell *folderCell=[self.tableView cellForRowAtIndexPath:[self.fetchedResultsController indexPathForObject:folder]];
    [self updateSubtitleForTableCell:folderCell];
}

- (void)userDidChangeSelectedFormationsForFolder:(Formation_Folder *)folder {
    //Pass the folder to the export formation tvc
    self.exportFormationTableViewController.formationFolder=folder;
    
    //Pass the selected records to the export formation tvc
    [self.exportFormationTableViewController updateSelectedFormationsWith:[self.selectedFormationsForFolders objectForKey:folder.folderName]];
        
    //Update corresponding cell
    [self updateCellCorrespondingToFolder:folder];
    
    //Update export button
    [self updateExportButton];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected formation for the selected folder
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedFormationsForFolders=self.selectedFormationsForFolders.mutableCopy;
    [selectedFormationsForFolders setObject:folder.formations forKey:folder.folderName];
    self.selectedFormationsForFolders=selectedFormationsForFolders.copy;
    
    //Update
    [self userDidChangeSelectedFormationsForFolder:folder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add all the selected records for the selected folder
    Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableDictionary *selectedFormationsForFolders=self.selectedFormationsForFolders.mutableCopy;
    [selectedFormationsForFolders setObject:[NSSet set]  forKey:folder.folderName];
    self.selectedFormationsForFolders=selectedFormationsForFolders.copy;
    
    //Update
    [self userDidChangeSelectedFormationsForFolder:folder];
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

#pragma mark - ExportFormationTableViewControllerDelegate Protocol methods

- (void)exportTVC:(ExportFormationTableViewController *)sender userDidSelectFormations:(NSSet *)formations forFolder:(Formation_Folder *)folder
{
    //Save the selected records
    NSMutableDictionary *selectedFormationsForFolders=self.selectedFormationsForFolders.mutableCopy;
    [selectedFormationsForFolders setObject:formations forKey:folder.folderName];
    self.selectedFormationsForFolders=selectedFormationsForFolders.copy;  
    
    //Update corresponding cell
    [self updateCellCorrespondingToFolder:folder];
    
    //Update export button
    [self updateExportButton];
    
    //Select/Deselect Cell if appropriate
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:folder];
    NSArray *selectedIndexPaths=self.tableView.indexPathsForSelectedRows;
    if (formations.count) {
        if (![selectedIndexPaths containsObject:indexPath]) 
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        if ([selectedIndexPaths containsObject:indexPath])
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    }
}

@end