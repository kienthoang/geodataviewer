//
//  GDVStudentGroupTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVStudentGroupTVC.h"
#import "GDVFolderTVC.h"
#import "GDVStudentResponseTVC.h"

@interface GDVStudentGroupTVC ()

@end

@implementation GDVStudentGroupTVC

@synthesize studentGroups=_studentGroups;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setStudentGroups:(NSArray *)studentGroups {
    if (studentGroups) {
        _studentGroups=studentGroups;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //Show loading screen while asking for data
    if (!self.studentGroups)
        [self showLoadingScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Group *selectedGroup=nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        //Get the selected student group
        UITableViewCell *cell=(UITableViewCell *)sender;
        selectedGroup=[self.studentGroups objectAtIndex:[self.tableView indexPathForCell:cell].row];
    }
    
    if ([segue.identifier isEqualToString:@"Show Folders"]) {
        //Set the student group of the destination
        [segue.destinationViewController setStudentGroup:selectedGroup];
        
        //Notify the delegate
        [self.delegate studentGroupTVC:self preparedToSegueToFolderTVC:segue.destinationViewController];
    }
    
    else if ([segue.identifier isEqualToString:@"Show Student Responses"]) {
        //Set the student group of the destination
        [segue.destinationViewController setStudentGroup:selectedGroup];
        
        //Notify the delegate
        [self.delegate studentGroupTVC:self preparedToSegueToStudentResponseTVC:segue.destinationViewController];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.studentGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Student Group Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Group *group=[self.studentGroups objectAtIndex:indexPath.row];
    cell.textLabel.text=group.name;
    
    return cell;
}

@end
