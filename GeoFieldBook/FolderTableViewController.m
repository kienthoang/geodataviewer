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
#import "Folder+Creation.h"

@interface FolderTableViewController() <ModalFolderDelegate,UISplitViewControllerDelegate>

- (void)normalizeDatabase;        //Make sure the database's document state is normal
- (void)createNewFolderWithName:(NSString *)folderName;    //Create a folder in the database with the specified name
- (void)modifyFolderWithName:(NSString *)originalName toName:(NSString *)newName;   //Modify a folder's name
- (void)deleteFolder:(Folder *)folder;

@end

@implementation FolderTableViewController 

@synthesize database=_database;

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Make sure the document is open and set up the fetched result controller
        [self normalizeDatabase];        
    }
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

#pragma mark - Folder Creation/Editing/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
        }
    }];
}

- (void)createNewFolderWithName:(NSString *)folderName {
    //Filter folder name
    folderName=[TextInputFilter filterDatabaseInputText:folderName];
    
    //Create a folder entity with the specified name (after filtering)
    [Folder folderWithName:folderName inManagedObjectContext:self.database.managedObjectContext];
    
    //Save
    [self saveChangesToDatabase];
}

- (void)modifyFolderWithName:(NSString *)originalName toName:(NSString *)newName {
    //Filter new name
    newName=[TextInputFilter filterDatabaseInputText:newName];
    
    //Fetch the folder entity with the specified original name
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",originalName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //If there is exactly one folder in the result array, modify the folder's name (after filtering)
    if ([results count]==1) {
        Folder *folder=[results lastObject];
        folder.folderName=newName;
    } 
    
    //Else, handle errors
    else {
    }
    
    //Save
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
        } 
    }];
    
    //Set the split view controller's delegate to self here because doing so in awakeFromNib would set the 
    //presentingViewController of ModalFolderViewController to UISplitViewController, which screws up its
    //context and its frame
    self.splitViewController.delegate=self;
}

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
        UITableViewCell *cell=(UITableViewCell *)sender;
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        [segue.destinationViewController setTitle:folder.folderName];
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setFolderName:folder.folderName];
    }
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
