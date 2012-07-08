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

@interface FolderTableViewController() <ModalFolderDelegate,RecordTVCAutosaverDelegate,UIAlertViewDelegate,RecordTableViewControllerDelegate,CustomFolderCellDelegate>

- (void)normalizeDatabase;        //Make sure the database's document state is normal
- (BOOL)createNewFolderWithInfo:(NSDictionary *)folderInfo;    //Create a folder in the database with the specified name
- (BOOL)modifyFolder:(Folder *)folder withNewInfo:(NSDictionary *)folderInfo;   //Modify a folder's name
- (void)deleteFolder:(Folder *)folder;   //Delete the specified folder

@property (nonatomic, strong) GeoFilter *recordFilter;
@property (nonatomic) BOOL mapDidAppear;

#pragma mark - Temporary data of the autosaver

@property (nonatomic,strong) autosaver_block_t autosaverCancelBlock;
@property (nonatomic,strong) autosaver_block_t autosaverConfirmBlock;
@property (nonatomic,strong) NSString *autosaverConfirmTitle;

#pragma mark - Temporary "to-be-deleted" data

@property (nonatomic,strong) Folder *toBeDeletedFolder;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationPopoverController;
@property (nonatomic,strong) UIPopoverController *folderInfoPopoverController;

#pragma mark - Buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation FolderTableViewController 

@synthesize recordFilter=_recordFilter;
@synthesize mapDidAppear=_mapDidAppear;
@synthesize editButton = _editButton;

@synthesize autosaverCancelBlock=_autosaverCancelBlock;
@synthesize autosaverConfirmTitle=_autosaverConfirmTitle;
@synthesize autosaverConfirmBlock=_autosaverConfirmBlock;

@synthesize toBeDeletedFolder=_toBeDeletedFolder;

@synthesize database=_database;

@synthesize formationPopoverController=_formationPopoverController;
@synthesize folderInfoPopoverController=_folderInfoPopoverController;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Make sure the document is open and set up the fetched result controller
        [self normalizeDatabase];        
    }
}

- (GeoFilter *)recordFilter {
    if (!_recordFilter)
        _recordFilter=[[GeoFilter alloc] init];
    
    return _recordFilter;
}

#pragma mark - Notification Center

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];
    
    NSLog(@"Posted notification with name: %@",name);
}

#pragma mark - Controller State Initialization

//Set up the FetchedResultsController to fetch folder entities from the database
- (void)setupFetchedResultsController {
    //Setup its request
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    
    //Create the fetchedResultsController
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                      managedObjectContext:self.database.managedObjectContext 
                                                                        sectionNameKeyPath:nil 
                                                                                 cacheName:nil];
}

- (void)normalizeDatabase {
    //If the managed document is closed, open it
    if (self.database.documentState==UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success){
            //Set up the fetched result controller
            [self setupFetchedResultsController];
        }];
    }
    
    //Else if the managed document is open, just use it
    else if (self.database.documentState==UIDocumentStateNormal) {
        //Set up the fetched result controller
        [self setupFetchedResultsController];
    }
}

#pragma mark - Alert Generators

//Put up an alert about some database failure with specified message
- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Database Error" 
                                                  message:message 
                                                 delegate:nil 
                                        cancelButtonTitle:@"Dismiss" 
                                        otherButtonTitles: nil];
    [alert show];
}

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

#pragma mark - RecordTVCAutosaver methods

- (void)recordTableViewController:(RecordTableViewController *)sender 
                        showAlert:(UIAlertView *)alertView 
          andExecuteBlockOnCancel:(autosaver_block_t)cancelBlock 
                  andExecuteBlock:(autosaver_block_t)confirmBlock 
         whenClickButtonWithTitle:(NSString *)buttonTitle
{
    //Set the delegate of the alert to be self
    alertView.delegate=self;
    
    //Save the blocks
    self.autosaverCancelBlock=cancelBlock;
    self.autosaverConfirmBlock=confirmBlock;
    self.autosaverConfirmTitle=buttonTitle;
        
    //Show the alert
    [alertView show];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the alert view is the delete folder alert and user clicks "Continue", delete the folder
    if ([alertView.title isEqualToString:@"Delete Folder"]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
            //Delete the folder
            [self deleteFolder:self.toBeDeletedFolder];
            self.toBeDeletedFolder=nil;
        }
    }
    
    else {
        //If the user clicked on the confirm button (the button with the title sent by RecordViewController via its delegate protocol)
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:self.autosaverConfirmTitle]) {
            //Execute the confirm block and unset it
            self.autosaverConfirmBlock();
            self.autosaverConfirmBlock=nil;
        }
        
        //If user canceled the alert view, execute the cancel block and put up the initial detail view controller on the detail side
        else if (buttonIndex==alertView.cancelButtonIndex) {
            //Cancel button on the autosaver's alert view clicked
            self.autosaverCancelBlock();
            
            //Nillify cancel block
            self.autosaverCancelBlock=nil;
        }
    }
}

#pragma mark - Folder Creation/Editing/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
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

- (void)deleteFolder:(Folder *)folder {
    //Update the record filter
    [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
    //Delete the folder
    [self.database.managedObjectContext deleteObject:folder];
    
    //Save
    [self saveChangesToDatabase];
    
    //Reload
    [self.tableView reloadData];
    
    //Send out a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up the database using the GeoDatabaseManager fetch method=====>the block will get called only the first time the database gets created
    //success is YES if the database saving process succeeded or NO otherwise
    self.database=[[GeoDatabaseManager standardDatabaseManager] fetchDatabaseFromDisk:self completion:^(BOOL success){
        //May be show up an alert if not success?
        if (!success) {
            //Put up an alert
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to access the database. Please make sure the database is not corrupted."];
        } 
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Save any change to database
    [self saveChangesToDatabase];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Support all orientations
    return YES;
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];

    //Change the style of the button to edit or done
    sender.style=self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.tableView.editing ? @"Done" : @"Edit";
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
            [self editPressed:self.editButton];
        }            
    }
    
    //Seguing to the RecordTableViewController
    else if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Common setup
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setAutosaveDelegate:self];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    
    CustomFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomFolderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.folder=folder;
    cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    CheckBox *checkbox=(CheckBox *)cell.checkBox;
    checkbox.image=[self.recordFilter.selectedFolderNames containsObject:folder.folderName] ? checkbox.checked : checkbox.unchecked;
    
    //Set self to the delegate of the cell
    cell.delegate=self;
    
    //Add gesture recognizer for long press
    UILongPressGestureRecognizer *longPressRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnTableCell:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    //Show/Hide the checkboxes
    if (self.mapDidAppear)
        [cell showCheckBoxAnimated:YES];
    else
        [cell hideCheckBoxAnimated:YES];
    
    return cell;
}

- (void)longPressOnTableCell:(UILongPressGestureRecognizer *)longPress {
    //Show a popover
    //UITableViewCell *cell=(UITableViewCell *)longPress.view;
    //Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    //cell.textLabel.text=folder.folderDescription;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //If the table view is currently in editting mode, segue to the MoDalNewFolderViewController and set its 
    if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"Add/Edit Folder" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the editing style is delete, delete the corresponding folder
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //Get the selected folder and save it to delete later
        self.toBeDeletedFolder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Put up an alert
        UIAlertView *deleteAlert=[[UIAlertView alloc] initWithTitle:@"Delete Folder" message:@"You are about to delete an entire folder of records. Do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        [deleteAlert show];
    }
}

#pragma mark - GeoMapDelegate Protocol methods

- (NSArray *)records {
    //Get the array of records 
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.sortDescriptors=[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"folder.folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],nil];
    NSArray *records=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //Filter the array of records
    records=[self.recordFilter filterRecordCollectionByFolder:records];
    
    return records;
}

- (NSArray *)recordsForMapViewController:(UIViewController *)mapViewController {
    return [self records];
}

- (void)mapViewControllerDidAppearOnScreen:(UIViewController *)mapViewController {
    self.mapDidAppear=YES;
    [self.tableView reloadData];
}

- (void)mapViewControllerDidDisappear:(UIViewController *)mapViewController {
    self.mapDidAppear=NO;
    [self.tableView reloadData];
}

#pragma mark - CustomFolderCellDelegate methods

- (void)folderCell:(CustomFolderCell *)sender userDidSelectDidCheckBoxForRecord:(Folder *)folder {
    [self.recordFilter userDidSelectFolderWithName:folder.folderName];
    
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

- (void)folderCell:(CustomFolderCell *)sender userDidDeselectDidCheckBoxForRecord:(Folder *)folder {
    [self.recordFilter userDidDeselectFolderWithName:folder.folderName];
    
    //Post a notification to indicate that the folder database has changed
    [self postNotificationWithName:GeoNotificationModelGroupFolderDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
}

@end