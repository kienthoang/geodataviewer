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
#import "TextInputFilter.h"

@interface FormationFolderTableViewController() <FormationFolderViewControllerDelegate,UIAlertViewDelegate>

- (void)setupFetchedResultsController;

@property (nonatomic,strong) Formation_Folder *toBeDeletedFolder;

@end

@implementation FormationFolderTableViewController

@synthesize database=_database;
@synthesize toBeDeletedFolder=_toBeDeletedFolder;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
    
    //Setup the fectched results controller
    [self setupFetchedResultsController];
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
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If user clicked "Continue" (in the delete formation folder alert view), delete the folder
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
        [self deleteFormationFolder:self.toBeDeletedFolder];
        self.toBeDeletedFolder=nil;
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

- (void)deleteFormationFolder:(Formation_Folder *)formationFolder {
    //Delete the folder
    [self.database.managedObjectContext deleteObject:formationFolder];
    
    //Save
    [self saveChangesToDatabase];
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle the table view's editing mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Change the style of the button to edit or done
    sender.style=self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.tableView.editing ? @"Done" : @"Edit";
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the editing style is delete, delete the corresponding folder
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //Get the selected folder and save it to delete later
        self.toBeDeletedFolder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Put up an alert
        UIAlertView *deleteAlert=[[UIAlertView alloc] initWithTitle:@"Delete Formation Folder" message:@"You are about to delete an entire formation folder. Do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        [deleteAlert show];
    }
}

#pragma mark - View Controller Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
