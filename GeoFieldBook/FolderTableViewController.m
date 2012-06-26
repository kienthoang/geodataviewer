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

@interface FolderTableViewController() <ModalFolderDelegate,UISplitViewControllerDelegate,RecordTVCAutosaverDelegate,UIAlertViewDelegate>

- (void)normalizeDatabase;        //Make sure the database's document state is normal
- (void)createNewFolderWithName:(NSString *)folderName;    //Create a folder in the database with the specified name
- (void)modifyFolderWithName:(NSString *)originalName toName:(NSString *)newName;   //Modify a folder's name
- (void)deleteFolder:(Folder *)folder;
- (void)showInitialDetailView;

- (id <UISplitViewBarButtonPresenter>)barButtonPresenter;

@property (nonatomic,strong) autosaver_block_t autosaverCancelBlock;
@property (nonatomic,strong) autosaver_block_t autosaverConfirmBlock;
@property (nonatomic,strong) NSString *autosaverConfirmTitle;

@end

@implementation FolderTableViewController 

@synthesize autosaverCancelBlock=_autosaverCancelBlock;
@synthesize autosaverConfirmTitle=_autosaverConfirmTitle;
@synthesize autosaverConfirmBlock=_autosaverConfirmBlock;

@synthesize database=_database;

@synthesize barButtonItem=_barButtonItem;

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Make sure the document is open and set up the fetched result controller
        [self normalizeDatabase];        
    }
}

- (void)setBarButtonItem:(UIBarButtonItem *)barButtonItem {
    //Transfer the bar button to the detail view
    [self barButtonPresenter].splitViewBarButtonItem=barButtonItem;
        
    _barButtonItem=barButtonItem;
}

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
    //If the managed document has not been saved to disk, save it
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.database.fileURL path]]) {
        [self.database saveToURL:self.database.fileURL 
                forSaveOperation:UIDocumentSaveForCreating 
               completionHandler:^(BOOL sucess){
                   //Set up the fetched result controller
                   [self setupFetchedResultsController];                   
               }];
    }
    
    //If the managed document is closed, open it
    else if (self.database.documentState==UIDocumentStateClosed) {
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

//Put up an alert about some database failure with specified message
- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Database Error" 
                                                  message:message 
                                                 delegate:nil 
                                        cancelButtonTitle:@"Dismiss" 
                                        otherButtonTitles: nil];
    [alert show];
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

#pragma mark - Folder Creation/Editing/Deletion

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    UIAlertView *duplicationAlert=[[UIAlertView alloc] initWithTitle:@"Name Duplicate" message:[NSString stringWithFormat:@"A folder with the name '%@' already exists!",duplicateName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [duplicationAlert show];
}

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (void)createNewFolderWithName:(NSString *)folderName {
    //Filter folder name
    folderName=[TextInputFilter filterDatabaseInputText:folderName];
    
    //Create a folder entity with the specified name (after filtering), put up an alert if that returns nil (name duplicate)
    if (![Folder folderWithName:folderName inManagedObjectContext:self.database.managedObjectContext])
        [self putUpDuplicateNameAlertWithName:folderName];
        
    //Else, save
    else
        [self saveChangesToDatabase];
}

- (void)modifyFolderWithName:(NSString *)originalName toName:(NSString *)newName {
    //Filter new name
    newName=[TextInputFilter filterDatabaseInputText:newName];
    
    //Get the folder with the specified original name
    Folder *selectedFolder=nil;
    for (Folder *folder in [self.fetchedResultsController fetchedObjects]) {
        if ([folder.folderName isEqualToString:originalName])
            selectedFolder=folder;
    }
    
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert
    if (![selectedFolder changeFolderNameTo:newName])
        [self putUpDuplicateNameAlertWithName:newName];
    
    //Else, save
    else
        [self saveChangesToDatabase];
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
    
    //If there is a transferred button, give it to the detail view
    if (self.barButtonItem)
        [[self barButtonPresenter] setSplitViewBarButtonItem:self.barButtonItem];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Support all orientations
    return YES;
}

#pragma mark - prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Seguing to ModalNewFolderViewController
    if ([segue.identifier isEqualToString:@"Add/Edit Folder"]) {
        //Set the delegate of the destination controller
        [segue.destinationViewController setDelegate:self];
        
        //Set the folderName of the destination controller if the table view is in editting mode
        if (self.tableView.editing) {
            UITableViewCell *cell=(UITableViewCell *)sender;
            Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFolderName:folder.folderName];
        }
    }
    
    //Seguing to the RecordTableViewController
    else if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Get the cell that activates the segue and set up the destination controller
        UITableViewCell *cell=(UITableViewCell *)sender;
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        [segue.destinationViewController setTitle:folder.folderName];
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setFolderName:folder.folderName];
        [segue.destinationViewController setAutosaveDelegate:self];
    }
    
    //Seguing to the modal formation folder tvc
    else if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        //Set the database of the formation folder tvc to self's database
        UINavigationController *navigationController=segue.destinationViewController;
        [(FormationFolderTableViewController *)navigationController.topViewController setDatabase:self.database];
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
            obtainedNewFolderName:(NSString *)folderName 
{
    //Create the folder with the specified name
    [self createNewFolderWithName:folderName];
        
    //Dismiss modal
    [self dismissModalViewControllerAnimated:YES];
}

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
         didAskToModifyFolderName:(NSString *)originalName 
       obtainedModifiedFolderName:(NSString *)folderName 
{
    //Modify the folder's name
    [self modifyFolderWithName:originalName toName:folderName];
        
    //Dismiss modal
    [self dismissModalViewControllerAnimated:YES];
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
    
    return cell;
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
        //Get the selected folder and delete it
        [self deleteFolder:[self.fetchedResultsController objectAtIndexPath:indexPath]];
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

-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

@end