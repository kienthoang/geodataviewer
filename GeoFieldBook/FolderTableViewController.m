//
//  FolderTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FolderTableViewController.h"
#import "ModalFolderViewController.h"
#import "RecordTableViewController.h"
#import "TextInputFilter.h"
#import "GeoDatabaseManager.h"

#import "Folder.h"
#import "Record.h"
#import "Folder+Creation.h"
#import "Folder+Modification.h"
#import "Folder+DictionaryKeys.h"

#import "CheckBox.h"

#import "GeoFilter.h"
#import "CustomFolderCell.h"

#import "ModelGroupNotificationNames.h"

@interface FolderTableViewController() <ModalFolderDelegate,UIActionSheetDelegate,RecordTableViewControllerDelegate,CustomFolderCellDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) GeoFilter *recordFilter;

#pragma mark - Temporary "to-be-deleted" data

@property (nonatomic,strong) NSArray *toBeDeletedFolders;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationPopoverController;
@property (nonatomic,strong) UIPopoverController *folderInfoPopoverController;

#pragma mark - Buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectNone;

@end

@implementation FolderTableViewController 

@synthesize recordFilter=_recordFilter;
@synthesize willFilterByFolder=_willFilterByFolder;

@synthesize editButton = _editButton;
@synthesize deleteButton = _deleteButton;
@synthesize addButton = _addButton;
@synthesize selectAllButton = _selectAllButton;
@synthesize selectNone = _selectNone;

@synthesize toBeDeletedFolders=_toBeDeletedFolders;

@synthesize formationPopoverController=_formationPopoverController;
@synthesize folderInfoPopoverController=_folderInfoPopoverController;

#pragma mark - Getters and Setters

- (GeoFilter *)recordFilter {
    if (!_recordFilter)
        _recordFilter=[[GeoFilter alloc] init];
    
    return _recordFilter;
}

- (NSArray *)toBeDeletedFolders {
    if (!_toBeDeletedFolders)
        _toBeDeletedFolders=[NSArray array];
    
    return _toBeDeletedFolders;
}

- (void)setToBeDeletedFolders:(NSArray *)toBeDeletedFolders {
    _toBeDeletedFolders=toBeDeletedFolders;
    
    //Update the title of the delete button
    int numFolders=self.toBeDeletedFolders.count;
    self.deleteButton.title=numFolders ? [NSString stringWithFormat:@"Delete (%d)",numFolders] : @"Delete";
    
    //Disable the delete button if no record is selected
    self.deleteButton.enabled=numFolders>0;
}

- (NSArray *)selectedFolders {
    return [self.recordFilter selectedFolderNames];
}

- (void)setWillFilterByFolder:(BOOL)willFilterByFolder {
    _willFilterByFolder=willFilterByFolder;
    
    //Reload the table view
    [self.tableView reloadData];
}

#pragma mark - Notification Center

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

#pragma mark - Alert Generators

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    UIAlertView *duplicationAlert=[[UIAlertView alloc] initWithTitle:@"Name Duplicate" message:[NSString stringWithFormat:@"A folder with the name '%@' already exists!",duplicateName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [duplicationAlert show];
}

#pragma mark - RecordTableViewControllerDelegate methods

- (void)recordTableViewController:(RecordTableViewController *)sender 
                needsUpdateFolder:(Folder *)folder 
           setFormationFolderName:(NSString *)formationFolder
{
    //Update the folder
    [folder setFormationFolderWithName:formationFolder];
}

#pragma mark - Folder Creation/Editing/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
            NSLog(@"Database error: %@",self.database);
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (BOOL)createNewFolderWithInfo:(NSDictionary *)folderInfo {
    //Create a folder entity with the specified name (after filtering), put up an alert if that returns nil (name duplicate) and return NO
    if (![Folder folderWithInfo:folderInfo inManagedObjectContext:self.database.managedObjectContext]) {
        [self putUpDuplicateNameAlertWithName:[folderInfo objectForKey:FOLDER_NAME]];
        return NO;
    }
        
    //Else, save
    else 
        [self saveChangesToDatabase];
    
    //Update the record filter (add the name of the newly created folder)
    [self.recordFilter userDidSelectFolderWithName:[folderInfo objectForKey:FOLDER_NAME]];
    
    //Reload
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)modifyFolder:(Folder *)folder withNewInfo:(NSDictionary *)folderInfo {
    NSString *originalName=folder.folderName;
    
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert and return NO
    if (![folder updateWithNewInfo:folderInfo]) {
        [self putUpDuplicateNameAlertWithName:[folderInfo objectForKey:FOLDER_NAME]];
        return NO;
    }
    
    //Else, save
    else
        [self saveChangesToDatabase];
    
    //Update the filter
    [self.recordFilter changeFolderName:originalName toFolderName:[folderInfo objectForKey:FOLDER_NAME]];
    
    //Reload
    [self.tableView reloadData];
    
    return YES;
}

- (void)deleteFolders:(NSArray *)folders {
    for (Folder *folder in folders) {
        //Update the record filter
        [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
        //Delete the folder
        [self.database.managedObjectContext deleteObject:folder];
    }
    
    //Save
    [self saveChangesToDatabase];
    
    //Send out a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Hide delete button
    [self toggleDeleteButtonForEditingMode:self.tableView.editing];
    
    //hide the select buttons
    [self toggleSelectButtonsForEditingMode:self.tableView.editing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadVisibleCells];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Switch out of editing mode
    if (self.tableView.editing)
        [self editPressed:self.editButton];
}

#pragma mark - Target-Action Handlers

- (void)reloadCheckboxesInVisibleCellsForEditingMode:(BOOL)editing {
    for (CustomFolderCell *cell in self.tableView.visibleCells) {
        if (editing || !self.willFilterByFolder)
            [cell hideCheckBoxAnimated:YES];
        else {
            //Show the checkboxes
            [cell showCheckBoxAnimated:YES];
        }
    }
}

- (void)setupUIForEditingMode:(BOOL)editing {
    //Setup the buttons
    [self setupButtonsForEditingMode:editing];
    
    //Reload the checkboxes
    [self reloadCheckboxesInVisibleCellsForEditingMode:editing];
}

- (void)toggleSelectButtonsForEditingMode:(BOOL)editing {
    //Setup the select buttons
    NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
    if (editing) {
        [toolbarItems insertObject:self.selectAllButton atIndex:1];
        [toolbarItems insertObject:self.selectNone atIndex:toolbarItems.count-1];
    }
    else {
        [toolbarItems removeObject:self.selectAllButton];
        [toolbarItems removeObject:self.selectNone];
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
    self.toBeDeletedFolders=nil;
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedFolders=self.toBeDeletedFolders.count;
    NSString *message=numOfDeletedFolders > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d folders?",numOfDeletedFolders] : @"Are you sure you want to delete this folder?";
    NSString *destructiveButtonTitle=numOfDeletedFolders > 1 ? @"Delete Folders" : @"Delete Folder";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.toBeDeletedFolders=self.fetchedResultsController.fetchedObjects;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.toBeDeletedFolders=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Seguing to ModalNewFolderViewController
    if ([segue.identifier isEqualToString:@"Add/Edit Folder"]) {
        //Set the delegate of the destination controller
        [segue.destinationViewController setDelegate:self];
        
        //Set the folder of the destination controller if the table view is in editting mode
        if (self.tableView.editing) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFolder:folder];
        }
    }
    
    //Seguing to the RecordTableViewController
    else if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Common setup
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setDelegate:self];
        
        //Get the cell that activates the segue and set up the destination controller if the sender is a table cell
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setTitle:folder.folderName];
            [segue.destinationViewController setFolder:folder];
        }
        
        //If the sender is a record
        else if ([sender isKindOfClass:[Record class]]) {
            Record *record=(Record *)sender;
            Folder *folder=record.folder;
            [segue.destinationViewController setTitle:folder.folderName];
            [segue.destinationViewController setFolder:folder];
            [segue.destinationViewController setChosenRecord:record];
        }
    }
}

#pragma mark - ModalFolderDelegate methods

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
            obtainedNewFolderInfo:(NSDictionary *)folderInfo
{
    //Create the folder with the specified name, and if that returns YES (no name duplication) dismiss the modal
    if ([self createNewFolderWithInfo:folderInfo]) {
        //Dismiss modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
             didAskToModifyFolder:(Folder *)folder
       obtainedModifiedFolderInfo:(NSDictionary *)folderInfo
{
    //Modify the folder's name and that returns YES, dismiss the modal
    if ([self modifyFolder:folder withNewInfo:folderInfo]) {
        //Dismiss modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (void)reloadVisibleCells {
    for (CustomFolderCell *cell in self.tableView.visibleCells)
        cell.folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomFolderCell *cell=(CustomFolderCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //Set the delegate of the cell to be notified when user toggles on/off checkboxes to include/exclude folders from being showed on the map
    cell.delegate=self;
    
    //Select cell if its folder is in the list of selected folders
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.selectedFolders containsObject:folder]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    //Show/Hide the checkboxes
    if (self.willFilterByFolder && !self.tableView.editing)
        [cell showCheckBoxAnimated:YES];
    else
        [cell hideCheckBoxAnimated:YES];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //If the table view is currently in editting mode, segue to the MoDalNewFolderViewController and set its 
    if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"Add/Edit Folder" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected folder to the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        if (![toBeDeletedFolders containsObject:folder])
            [toBeDeletedFolders addObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
    }
    
    //If the table view is not in editing mode, segue to show the records
    else
        [self performSegueWithIdentifier:@"Show Records" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        [toBeDeletedFolders removeObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
    }
}

#pragma mark - CustomFolderCellDelegate methods

- (void)folderCell:(CustomFolderCell *)sender userDidSelectDidCheckBoxForFolder:(Folder *)folder {
    [self.recordFilter userDidSelectFolderWithName:folder.folderName];
        
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

- (void)folderCell:(CustomFolderCell *)sender userDidDeselectDidCheckBoxForFolder:(Folder *)folder {
    [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

#pragma mark - NSFetchedResultsControllerDelegate protocol methods

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //If a folder is inserted, add it to the filter
            if (type==NSFetchedResultsChangeInsert) {
                Folder *folder=[self.fetchedResultsController objectAtIndexPath:newIndexPath];
                [self.recordFilter userDidSelectFolderWithName:folder.folderName];
            }
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
 
#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete folder action sheet and user clicks "Delete Folders" or "Delete Folder", delete the folder(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Folders",@"Delete Folder", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected folders
        [self deleteFolders:self.toBeDeletedFolders];
        
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}

@end