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

#import "CustomStudentGroupCell.h"

@interface GDVStudentGroupTVC() <UIActionSheetDelegate>

@end

@implementation GDVStudentGroupTVC

@synthesize editButton=_editButton;
@synthesize deleteButton=_deleteButton;
@synthesize selectAllButton=_selectAllButton;
@synthesize selectNoneButton=_selectNoneButton;

@synthesize studentGroups=_studentGroups;
@synthesize toBeDeletedGroups=_toBeDeletedGroups;

@synthesize delegate=_delegate;

@synthesize identifier=_identifier;

#pragma mark - Getters and Setters

- (void)setStudentGroups:(NSArray *)studentGroups {
    if (studentGroups) {
        _studentGroups=studentGroups;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Sort the student groups
        _studentGroups=[_studentGroups sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

- (NSArray *)toBeDeletedGroups {
    if (!_toBeDeletedGroups)
        _toBeDeletedGroups=[NSArray array];
    
    return _toBeDeletedGroups;
}

- (void)setToBeDeletedGroups:(NSArray *)toBeDeletedGroups {
    _toBeDeletedGroups=toBeDeletedGroups;
    
    //Update the title of the delete button
    int numGroups=self.toBeDeletedGroups.count;
    self.deleteButton.title=numGroups ? [NSString stringWithFormat:@"Delete (%d)",numGroups] : @"Delete";
    
    //Disable the delete button if no group is selected
    self.deleteButton.enabled=numGroups>0;
}

#pragma mark - Target-Action Handlers

- (void)setupUIForEditingMode:(BOOL)editing {
    //Setup the buttons
    [self setupButtonsForEditingMode:editing];    
}

- (void)toggleSelectButtonsForEditingMode:(BOOL)editing {
    //Setup the select buttons
    NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
    if (editing) {
        [toolbarItems insertObject:self.selectAllButton atIndex:1];
        [toolbarItems insertObject:self.selectNoneButton atIndex:toolbarItems.count-1];
    }
    else {
        [toolbarItems removeObject:self.selectAllButton];
        [toolbarItems removeObject:self.selectNoneButton];
    }
    
    self.toolbarItems=toolbarItems.copy;
}

- (void)toggleDeleteButtonForEditingMode:(BOOL)editing {
    //Setup the select buttons
    NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
    if (editing && ![toolbarItems containsObject:self.deleteButton])
        [toolbarItems insertObject:self.deleteButton atIndex:1];
    else if (!editing)
        [toolbarItems removeObject:self.deleteButton];
    
    self.toolbarItems=toolbarItems.copy;
}

- (void)setupButtonsForEditingMode:(BOOL)editing {
    //Set the style of the action button
    self.editButton.style=editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    //Show the delete button if in editing mode
    [self toggleDeleteButtonForEditingMode:self.tableView.editing];
    
    //Set up select buttons
    [self toggleSelectButtonsForEditingMode:self.tableView.editing];
}

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Setup the UI
    [self setupUIForEditingMode:self.tableView.editing];
    
    //Reset the array of to be deleted folders
    self.toBeDeletedGroups=nil;
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedGroups=self.toBeDeletedGroups.count;
    NSString *message=numOfDeletedGroups > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d groups?",numOfDeletedGroups] : @"Are you sure you want to delete this group?";
    NSString *destructiveButtonTitle=numOfDeletedGroups > 1 ? @"Delete Groups" : @"Delete Group";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the groups
    self.toBeDeletedGroups=self.studentGroups.copy;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.toBeDeletedGroups=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete group action sheet and user clicks "Delete Groups" or "Delete Group", delete the group(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Groups",@"Delete Group", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected groups
        [self.delegate studentGroupTVC:self deleteStudentGroups:self.toBeDeletedGroups];
        
        //Reload data
        NSMutableArray *studentGroups=self.studentGroups.mutableCopy;
        [studentGroups removeObjectsInArray:self.toBeDeletedGroups];
        self.studentGroups=studentGroups.copy;
        
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Hide delete button
    [self toggleDeleteButtonForEditingMode:self.tableView.editing];
    
    //hide the select buttons
    [self toggleSelectButtonsForEditingMode:self.tableView.editing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Ask for data
    if ([self.delegate respondsToSelector:@selector(updateStudentGroupsForStudenGroupTVC:)])
        [self.delegate updateStudentGroupsForStudenGroupTVC:self];
}

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
    CustomStudentGroupCell *cell = (CustomStudentGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Group *group=[self.studentGroups objectAtIndex:indexPath.row];
    cell.studentGroup=group;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected group to the delete list
        Group *group=[self.studentGroups objectAtIndex:indexPath.row];
        NSMutableArray *toBeDeletedGroups=self.toBeDeletedGroups.mutableCopy;
        if (![toBeDeletedGroups containsObject:group])
            [toBeDeletedGroups addObject:group];
        self.toBeDeletedGroups=toBeDeletedGroups.copy;
    }
    
    //If the table view is not in editing mode, segue to show either the records or the responses
    else {
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        if ([self.identifier isEqualToString:RECORD_LIST_STUDENT_GROUP_IDENTIFIER])
            [self performSegueWithIdentifier:@"Show Folders" sender:cell];
        else if ([self.identifier isEqualToString:RESPONSE_LIST_STUDENT_GROUP_IDENTIFIER])
            [self performSegueWithIdentifier:@"Show Student Responses" sender:cell];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Group *group=[self.studentGroups objectAtIndex:indexPath.row];
        NSMutableArray *toBeDeletedGroups=self.toBeDeletedGroups.mutableCopy;
        [toBeDeletedGroups removeObject:group];
        self.toBeDeletedGroups=toBeDeletedGroups.copy;
    }
}
@end
