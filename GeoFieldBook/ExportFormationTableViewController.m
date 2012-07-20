//
//  ExportFormationTableViewController.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ExportFormationTableViewController.h"

@interface ExportFormationTableViewController()

@end

@implementation ExportFormationTableViewController

@synthesize delegate=_delegate;
@synthesize doubleTableViewController=_doubleTableViewController;
@synthesize selectedFormations=_selectedFormations;

#pragma mark - Getters and Setters

- (NSSet *)selectedFormations {
    if (!_selectedFormations)
        _selectedFormations=[NSSet set];
    
    return _selectedFormations;
}

- (void)updateSelectedFormationsWith:(NSSet *)formations {
    self.selectedFormations=formations;
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
    
    //Select all the selected records in the table view
    if (self.selectedFormations) {
        for (Formation *formation in self.selectedFormations) {
            NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:formation];
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
    self.tableView.allowsMultipleSelection=YES;
}

#pragma mark - UITableViewDelegate Protocol methods

- (void)userDidSelectFormations {
    //Notify the delegate
    [self.delegate exportTVC:self userDidSelectFormations:self.selectedFormations forFolder:self.formationFolder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Add the selected formation to the set of selected formations
    Formation *selectedFormation=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableSet *selectedFormations=self.selectedFormations.mutableCopy;
    [selectedFormations addObject:selectedFormation];
    self.selectedFormations=selectedFormations.copy;
    
    //Process
    [self userDidSelectFormations];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Remove the selected formation from the set of selected formations
    Formation *selectedFormation=[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableSet *selectedFormations=self.selectedFormations.mutableCopy;
    [selectedFormations removeObject:selectedFormation];
    self.selectedFormations=selectedFormations.copy;
    
    //Process
    [self userDidSelectFormations];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

@end