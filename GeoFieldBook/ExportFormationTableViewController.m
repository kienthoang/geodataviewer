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

- (void)setSelectedFormations:(NSSet *)selectedFormations {
    if (![_selectedFormations isEqualToSet:selectedFormations]) {
        _selectedFormations=selectedFormations;
        
        //Deselect all the rows
        for (UITableViewCell *cell in self.tableView.visibleCells)
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
        
        //Select all the selected records in the table view
        if (selectedFormations) {
            for (Formation *formation in selectedFormations) {
                NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:formation];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Put the table view into editing mode
    self.tableView.editing=YES;
    self.tableView.allowsMultipleSelection=YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

@end