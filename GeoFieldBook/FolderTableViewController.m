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
#import "InitialDetailViewController.h"
#import "FormationFolderTableViewController.h"
#import "TextInputFilter.h"
#import "GeoDatabaseManager.h"
#import "UISplitViewBarButtonPresenter.h"

#import "Folder.h"
#import "Folder+Creation.h"
#import "Folder+Modification.h"
#import "Folder+DictionaryKeys.h"

@interface FolderTableViewController() <ModalFolderDelegate,UISplitViewControllerDelegate,RecordTVCAutosaverDelegate,UIAlertViewDelegate,RecordTableViewControllerDelegate>

- (void)normalizeDatabase;        //Make sure the database's document state is normal
- (BOOL)createNewFolderWithInfo:(NSDictionary *)folderInfo;    //Create a folder in the database with the specified name
- (BOOL)modifyFolder:(Folder *)folder withNewInfo:(NSDictionary *)folderInfo;   //Modify a folder's name
- (void)deleteFolder:(Folder *)folder;   //Delete the specified folder
- (void)showInitialDetailView;            //Put the G-mode initial view onto the right screen (detail view)

- (id <UISplitViewBarButtonPresenter>)barButtonPresenter;

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
@synthesize editButton = _editButton;

@synthesize autosaverCancelBlock=_autosaverCancelBlock;
@synthesize autosaverConfirmTitle=_autosaverConfirmTitle;
@synthesize autosaverConfirmBlock=_autosaverConfirmBlock;

@synthesize toBeDeletedFolder=_toBeDeletedFolder;

@synthesize database=_database;

@synthesize formationPopoverController=_formationPopoverController;
@synthesize folderInfoPopoverController=_folderInfoPopoverController;

#pragma mark - Setters

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Make sure the document is open and set up the fetched result controller
        [self normalizeDatabase];        
    }
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

//Put up the initial detail view (the one with the geology logo) on the detail view
- (void)showInitialDetailView {
    [self performSegueWithIdentifier:@"Show Home Page" sender:self];
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
            
            //Show home view
            [self showInitialDetailView];
        }
        
        //If user canceled the alert view, execute the cancel block and put up the initial detail view controller on the detail side
        else if (buttonIndex==alertView.cancelButtonIndex) {
            //Cancel button on the autosaver's alert view clicked
            self.autosaverCancelBlock();
            
            //Nillify cancel block
            self.autosaverCancelBlock=nil;
            
            //Show home view
            [self showInitialDetailView];
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
    
    return YES;
}

- (BOOL)modifyFolder:(Folder *)folder withNewInfo:(NSDictionary *)folderInfo {
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert and return NO
    if (![folder updateWithNewInfo:folderInfo]) {
        [self putUpDuplicateNameAlertWithName:[folderInfo objectForKey:FOLDER_NAME]];
        return NO;
    }
    
    //Else, save
    else
        [self saveChangesToDatabase];
    
    return YES;
}

- (void)deleteFolder:(Folder *)folder {
    //Delete the folder
    [self.database.managedObjectContext deleteObject:folder];
    
    //Save
    [self saveChangesToDatabase];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Set up the database using the GeoDatabaseManager fetch method=====>the block will get called only the first time the database gets created
    //success is YES if the database saving process succeeded or NO otherwise
    self.database=[[GeoDatabaseManager standardDatabaseManager] fetchDatabaseFromDisk:self completion:^(BOOL success){
        //May be show up an alert if not success?
        if (!success) {
            //Put up an alert
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to access the database. Please make sure the database is not corrupted."];
        } 
    }];
    
    //Set self to be the split view's delegate
    self.splitViewController.delegate=self;
    
    //Perform a segue to the initial view controller if no autosaver blocks are set
    if (![[self.splitViewController.viewControllers lastObject] isKindOfClass:[InitialDetailViewController class]]) 
    {
        if (!self.autosaverCancelBlock || !self.autosaverConfirmBlock)
            [self showInitialDetailView];
    }
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

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Seguing to ModalNewFolderViewController
    if ([segue.identifier isEqualToString:@"Add/Edit Folder"]) {
        //Set the delegate of the destination controller
        [segue.destinationViewController setDelegate:self];
        
        //End the table view's editing mode if the table is in editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
        
        //Set the folder of the destination controller if the table view is in editting mode
        if (self.tableView.editing) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFolder:folder];
        }
    }
    
    //Seguing to the RecordTableViewController
    else if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Get the cell that activates the segue and set up the destination controller
        UITableViewCell *cell=(UITableViewCell *)sender;
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        [segue.destinationViewController setTitle:folder.folderName];
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setFolder:folder];
        [segue.destinationViewController setAutosaveDelegate:self];
        [segue.destinationViewController setDelegate:self];
    }
    
    //Seguing to the modal formation folder tvc
    else if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        //Set the database of the formation folder tvc to self's database
        UINavigationController *navigationController=segue.destinationViewController;
        [(FormationFolderTableViewController *)navigationController.topViewController setDatabase:self.database];
        
        //If the formation popover is already there, dismiss it
        if (self.formationPopoverController.isPopoverVisible)
            [self.formationPopoverController dismissPopoverAnimated:YES];
        
        //End the table view's editing mode if the table is in editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
        
        //Save the popover controller
        UIStoryboardPopoverSegue *popoverSegue=(UIStoryboardPopoverSegue *)segue;
        self.formationPopoverController=popoverSegue.popoverController;
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];

    //Change the style of the button to edit or done
    sender.style=self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.tableView.editing ? @"Done" : @"Edit";
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text=folder.folderName;
    NSString *recordCounter=[folder.records count]>1 ? @"Records" : @"Record";
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d %@",[folder.records count],recordCounter];
    
    //Add gesture recognizer for long press
    UILongPressGestureRecognizer *longPressRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnTableCell:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
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

#pragma mark - UISplitViewControllerDelegate methods

- (id <UISplitViewBarButtonPresenter>)barButtonPresenter {
    //Get the detail view controller
    id detailvc=[self.splitViewController.viewControllers lastObject];
    
    //if the detail view controller does not want to be the splitview bar button presenter, set detailvc to nil
    if (![detailvc conformsToProtocol:@protocol(UISplitViewBarButtonPresenter)]) {
        detailvc=nil;
    }
    
    return detailvc;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willHideViewController:(UIViewController *)navigation 
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc
{
    //Set the bar button item's title to self's title
    barButtonItem.title=self.navigationController.topViewController.navigationItem.title;
    
    //Put up the button
    [self barButtonPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)navigation 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    //Take the button off
    [self barButtonPresenter].splitViewBarButtonItem=nil;
}

//Hide the master in portrait modes only
-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)viewDidUnload {
    [self setEditButton:nil];
    [super viewDidUnload];
}
@end