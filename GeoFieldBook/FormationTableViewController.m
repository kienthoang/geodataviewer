//
//  FormationTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationTableViewController.h"
#import "FormationViewController.h"
#import "Formation.h"
#import "Formation+Creation.h"
#import "Formation+Modification.h"
#import "TextInputFilter.h"

@interface FormationTableViewController() <FormationViewControllerDelegate,NSFetchedResultsControllerDelegate>

- (void)setupFetchedResultsController;

@property (nonatomic) BOOL formationsWereReordered;

@end

@implementation FormationTableViewController

@synthesize formationFolder=_formationFolder;
@synthesize database=_database;

@synthesize formationsWereReordered=_formationsWereReordered;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
    
    //Setup fetched results controller
    [self setupFetchedResultsController];
}

- (void)setFormationFolder:(NSString *)formationFolder {
    _formationFolder=formationFolder;
    
    //Setup fetched results controller
    [self setupFetchedResultsController];
}

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Setup the request
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationFolder.folderName=%@",self.formationFolder];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationSortNumber" ascending:YES]];
    
    //Setup the feched results controller
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    //Set the fetched results controller's delegate to self
    self.fetchedResultsController.delegate=self;
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a formation view controller
    if ([segue.identifier isEqualToString:@"Formation Manipulation"]) {
        //Set the delegate of the destination controller as self
        [segue.destinationViewController setDelegate:self];
        
        //If the sender is a UITableViewCell, set the folder name of the destination controller as well
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=sender;
            Formation *selectedFormation=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            [segue.destinationViewController setFormationName:selectedFormation.formationName];
        }
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
    UIAlertView *duplicationAlert=[[UIAlertView alloc] initWithTitle:@"Name Duplicate" message:[NSString stringWithFormat:@"A formation with the name '%@' already exists in this folder!",duplicateName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [duplicationAlert show];
}

#pragma mark - Formation Manipulation

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
            [self putUpDatabaseErrorAlertWithMessage:@"Failed to save changes to database. Please try to submit them again."];
        }
    }];
}

- (BOOL)createNewFormationWithName:(NSString *)formationName {
    //create a new formation, if that returns nil (name duplicate), put up an alert
    if (![Formation formationForName:formationName inFormationFolderWithName:self.formationFolder inManagedObjectContext:self.database.managedObjectContext])
    {
        [self putUpDuplicateNameAlertWithName:formationName];
        return NO;
    }
    
    [self saveChangesToDatabase];
    return YES;
}

- (BOOL)modifyFormationWithName:(NSString *)originalName toName:(NSString *)newName {
    //Filter new name
    newName=[TextInputFilter filterDatabaseInputText:newName];
    
    //Get the formation with the specified original name
    Formation *selectedFormation=nil;
    for (Formation *formation in [self.fetchedResultsController fetchedObjects]) {
        if ([formation.formationName isEqualToString:originalName])
            selectedFormation=formation;
    }
    
    //Update its name, if that returns NO (i.e. the update failed because of name duplication), put up an alert
    if (![selectedFormation changeFormationNameTo:newName]) {
        [self putUpDuplicateNameAlertWithName:newName];
        return NO;
    }
    
    //Else, save
    [self saveChangesToDatabase];
    return YES;
}

- (void)deleteFormation:(Formation *)formation {
    //Delete the folder
    [self.database.managedObjectContext deleteObject:formation];
    
    //Save
    [self saveChangesToDatabase];
}

#pragma mark - Database-side Formation Reordering


#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle the table view's editing mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Save any changes to database if editing mode is over
    if (!self.editing)
        [self saveChangesToDatabase];
    
    //Change the style of the button to edit or done
    sender.style=self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.tableView.editing ? @"Done" : @"Edit";
}

#pragma mark - Formation View Controller Delegate methods

- (void)formationViewController:(FormationViewController *)sender 
      didObtainNewFormationName:(NSString *)formationName
{
    //Create a new formation with the specified name and if that returns YES (success), dismiss the modal
    if ([self createNewFormationWithName:formationName]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)formationViewController:(FormationViewController *)sender 
didAskToModifyFormationWithName:(NSString *)originalName 
             andObtainedNewName:(NSString *)formationName
{
    //Modify the formation with the specified original name and if that returns YES (success), dismiss the modal
    if ([self modifyFormationWithName:originalName toName:formationName]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - TableViewControllerDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Formation *formation=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.editingAccessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text = formation.formationName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //If the table view is currently in editting mode, segue to the MoDalNewFolderViewController and set its 
    if (self.tableView.editing) {
        [self performSegueWithIdentifier:@"Formation Manipulation" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the editing style is delete, delete the corresponding folder
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //Get the selected formation and delete it
        [self deleteFormation:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table View DataSource

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView 
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    
    //Update the sort number of the formations
    NSMutableArray *formations=[self.fetchedResultsController.fetchedObjects mutableCopy];
    Formation *objectToMove=[formations objectAtIndex:sourceIndexPath.row];
    [formations removeObjectAtIndex:sourceIndexPath.row];
    [formations insertObject:objectToMove atIndex:destinationIndexPath.row];
    for (int i=0;i<[formations count];i++) {
        Formation *formation=[formations objectAtIndex:i];
        formation.formationSortNumber=[NSNumber numberWithInt:i];
    }
}


#pragma mark - View Controller Lifecycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
