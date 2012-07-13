//
//  FormationFolderTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationFolderTableViewController.h"
#import "FormationFolderViewController.h"
#import "FormationTableViewController.h"
#import "Formation_Folder+Creation.h"
#import "Formation_Folder.h"
#import "Formation_Folder+Modification.h"

#import "GeoDatabaseManager.h"
#import "TextInputFilter.h"

@interface FormationFolderTableViewController() <FormationFolderViewControllerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) NSArray *toBeDeletedFolders;
@property (nonatomic,strong) UIManagedDocument *database;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (strong, nonatomic) UIBarButtonItem *hiddenButton;

@end

@implementation FormationFolderTableViewController

@synthesize database=_database;

@synthesize addButton = _addButton;
@synthesize deleteButton = _deleteButton;
@synthesize editButton = _editButton;
@synthesize hiddenButton=_hiddenButton;

@synthesize toBeDeletedFolders=_toBeDeletedFolders;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
        
    //Setup the fectched results controller
    [self setupFetchedResultsController];
}

- (NSArray *)toBeDeletedFolders {
    if (!_toBeDeletedFolders)
        _toBeDeletedFolders=[NSArray array];
    
    return _toBeDeletedFolders;
}

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Set up the request for fetched result controllers
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    
    //Set up the fetched results controller
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                      managedObjectContext:self.database.managedObjectContext 
                                                                        sectionNameKeyPath:nil 
                                                                                 cacheName:nil];
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a FormationFolderViewController
    if ([segue.identifier isEqualToString:@"Formation Folder Manipulation"]) {
        //Set the delegate of the destination controller as self
        [segue.destinationViewController setDelegate:self];
        
        //If the sender is a UITableViewCell, set the folder name of the destination controller as well
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=sender;
            Formation_Folder *selectedFormationFolder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFolderName:selectedFormationFolder.folderName];
        }
    }
    
    //Else if seguing to a FormationTableViewController
    else if ([segue.identifier isEqualToString:@"Show Formations"]) {
        //Set the database of the destination view controller
        [segue.destinationViewController setDatabase:self.database];
        
        //Set the folder name of the destination view controller
        UITableViewCell *cell=sender;
        Formation_Folder *folder=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        [segue.destinationViewController setFormationFolder:folder.folderName];
        [segue.destinationViewController navigationItem].title=folder.folderName;
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
    UIAlertView *duplicationAlert=[[UIAlertView alloc] initWithTitle:@"Name Duplicate" message:[NSString stringWithFormat:@"A formation folder with the name '%@' already exists!",duplicateName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [duplicationAlert show];
}

#pragma mark - Formation Folder Creation/Update/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (BOOL)createNewFormationFolderWithName:(NSString *)folderName {
    //create a new formation folder, if that returns nil (name duplicate), put up an alert and return NO
    if (![Formation_Folder formationFolderForName:folderName inManagedObjectContext:self.database.managedObjectContext]) {
        [self putUpDuplicateNameAlertWithName:folderName];
        return NO;
    }
    
    return YES;
}

- (BOOL)modifyFormationFolderWithName:(NSString *)originalName toName:(NSString *)newName {
    //Filter new name
    newName=[TextInputFilter filterDatabaseInputText:newName];
    
    //Get the formation folder with the specified original name
    Formation_Folder *selectedFormationFolder=nil;
    for (Formation_Folder *formationFolder in [self.fetchedResultsController fetchedObjects]) {
        if ([formationFolder.folderName isEqualToString:originalName])
            selectedFormationFolder=formationFolder;
    }
    
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert and return NO
    if (![selectedFormationFolder changeFormationFolderNameTo:newName]) {
        [self putUpDuplicateNameAlertWithName:newName];
        return NO;
    }
    
    //Else, save
    else
        [self saveChangesToDatabase];
    
    return YES;
}

- (void)deleteFormationFolders:(NSArray *)formationFolders {
    for (Formation_Folder *formationFolder in formationFolders) {
        //Delete the folder
        [self.database.managedObjectContext deleteObject:formationFolder];
    }
    
    //Save
    [self saveChangesToDatabase];
}

#pragma mark - Target-Action Handlers

- (void)setupButtonsForEditingMode:(BOOL)editing {
    //Change the style of the action button
    self.editButton.style=editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    //Show/Hide add/delete button
    UIBarButtonItem *hiddenButton=self.hiddenButton;
    self.hiddenButton=editing ? self.addButton : self.deleteButton;
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    if (editing)
        [toolbarItems removeObject:self.addButton];
    else
        [toolbarItems removeObject:self.deleteButton];
    [toolbarItems insertObject:hiddenButton atIndex:0];
    self.toolbarItems=[toolbarItems copy];
    
    //Reset the title of the delete button and disable it
    self.deleteButton.title=@"Delete";
    self.deleteButton.enabled=NO;
}

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Set up the buttons
    [self setupButtonsForEditingMode:self.tableView.editing];
    
    //Reset the array of to be deleted records
    self.toBeDeletedFolders=nil;
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedFolders=self.toBeDeletedFolders.count;
    NSString *message=numOfDeletedFolders > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d formation folders?",numOfDeletedFolders] : @"Are you sure you want to delete this formation folder?";
    NSString *destructiveButtonTitle=numOfDeletedFolders > 1 ? @"Delete Folders" : @"Delete Folder";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

#pragma mark - Formation Folder View Controller Delegate methods

- (void)formationFolderViewController:(FormationFolderViewController *)sender 
      didObtainNewFormationFolderName:(NSString *)formationFolderName
{
    //Create a new folder with the specified name, and if that returns YES (no name duplication) dismiss the modal
    if ([self createNewFormationFolderWithName:formationFolderName]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)formationFolderViewController:(FormationFolderViewController *)sender 
         didAskToModifyFolderWithName:(NSString *)originalName 
                   andObtainedNewName:(NSString *)folderName
{
    //Modify the folder with the specified original name, and if that returns YES (no name duplication error), dismiss the modal
    if ([self modifyFormationFolderWithName:originalName toName:folderName]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - TableViewControllerDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Folder Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Formation_Folder *formationFolder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text=formationFolder.folderName;
    NSString *formationCounter=[formationFolder.formations count]>1 ? @"Formations" : @"Formation";
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d %@",[formationFolder.formations count],formationCounter];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //If the table view is currently in editting mode, segue to the MoDalNewFolderViewController and set its 
    if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"Formation Folder Manipulation" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected folder to the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        [toBeDeletedFolders addObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
        
        //Update the title of the delete button
        int numFolders=self.toBeDeletedFolders.count;
        self.deleteButton.title=[NSString stringWithFormat:@"Delete (%d)",numFolders];
        
        //Enable the delete button
        self.deleteButton.enabled=numFolders>0;
    }
    
    //If the table view is not in editing mode, segue to show the records
    else
        [self performSegueWithIdentifier:@"Show Formations" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedFolders=[self.toBeDeletedFolders mutableCopy];
        [toBeDeletedFolders removeObject:folder];
        self.toBeDeletedFolders=[toBeDeletedFolders copy];
        
        //Update the title of the delete button
        int numFolders=self.toBeDeletedFolders.count;
        self.deleteButton.title=numFolders ? [NSString stringWithFormat:@"Delete (%d)",numFolders] : @"Delete";
        
        //Disable the delete button if no record is selected
        self.deleteButton.enabled=numFolders>0;
    }
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load the database
    UIManagedDocument *database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
    if (database.documentState==UIDocumentStateClosed) {
        [database openWithCompletionHandler:^(BOOL successful){
            if (successful)
                self.database=database;
            else {
                //Handle errors
            }
        }];
    } 
    else if (database.documentState==UIDocumentStateNormal) 
        self.database=database;
    
    //Hide the delete button
    self.hiddenButton=self.deleteButton;
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    [toolbarItems removeObject:self.deleteButton];
    self.toolbarItems=[toolbarItems copy];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete folder action sheet and user clicks "Delete Folders" or "Delete Folder", delete the folder(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Folders",@"Delete Folder", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected folders
        [self deleteFormationFolders:self.toBeDeletedFolders];
        
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}

@end
