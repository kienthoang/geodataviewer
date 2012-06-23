//
//  RecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordTableViewController.h"
#import "UISplitViewBarButtonPresenter.h"
#import "ModalRecordTypeSelector.h"
#import "RecordViewController.h"
#import "Folder.h"
#import "Record+Types.h"
#import "Record+Creation.h"
#import "Record+Modification.h"

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate,RecordViewControllerDelegate>

- (void)createRecordForRecordType:(NSString *)recordType;
- (void)modifyRecord:(Record *)record withNewInfo:(NSDictionary *)recordInfo;
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RecordTableViewController

@synthesize folderName=_folderName;
@synthesize database=_database;

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Set up fetchedResultsController
        [self setupFetchedResultsController];
    }
}

- (void)setFolderName:(NSString *)folderName {
    _folderName=folderName;
    
    //Set up fetchedResultsController
    [self setupFetchedResultsController];
}

- (id <UISplitViewBarButtonPresenter>)barButtonPresenter {
    //Get the detail view controller
    id detailvc=[self.splitViewController.viewControllers lastObject];
    
    //if the detail view controller does not want to be the splitview bar button presenter, set detailvc to nil
    if (![detailvc conformsToProtocol:@protocol(UISplitViewBarButtonPresenter)]) {
        detailvc=nil;
    }
    
    return detailvc;
}

#pragma mark - Record Creation/Deletion

- (void)saveChangesToDatabase {
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
        }
    }];
}

//Create a new record entity with the specified record type
- (void)createRecordForRecordType:(NSString *)recordType {
    Record *record=[Record recordForRecordType:recordType andFolderName:self.folderName inManagedObjectContext:self.database.managedObjectContext];
        
    //Save
    [self saveChangesToDatabase];
    
    //get ithe index path of the newly created record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:record];
    
    //Select the new record
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    //Show the new record on the detail view
    [self performSegueWithIdentifier:@"Show Record" sender:[self.fetchedResultsController indexPathForObject:record]];
}

//Modify a record wiht the specified record type
- (void)modifyRecord:(Record *)record 
         withNewInfo:(NSDictionary *)recordInfo
{
    //Update the record
    [record updateWithNewRecordInfo:recordInfo];
    
    //Save
    [self saveChangesToDatabase];
}

//Delete the record at the specified index path in the table
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath {
    //Get the record and delete it
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.database.managedObjectContext deleteObject:record];
    
    //Save
    [self saveChangesToDatabase];
}

#pragma mark - RecordViewControllerDelegate methods

- (void)recordViewController:(RecordViewController *)sender 
         userDidModifyRecord:(Record *)record 
           withNewRecordInfo:(NSDictionary *)recordInfo
{
    //Modify the specified record with the specified info
    [self modifyRecord:record withNewInfo:recordInfo];
    
    //Dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a modal record type selector, set the destination controller's array of record types
    if ([segue.identifier isEqualToString:@"Select Record Type"]) {
        [segue.destinationViewController setRecordTypes:[Record allRecordTypes]];
        [segue.destinationViewController setDelegate:self];
    } else if ([segue.identifier isEqualToString:@"Show Record"]) {
        //Transfer the bar button item over
        id <UISplitViewBarButtonPresenter> detailvc=[self barButtonPresenter];
        if (detailvc)
            [segue.destinationViewController setSplitViewBarButtonItem:[detailvc splitViewBarButtonItem]];
        
        
        NSIndexPath *indexPath=nil;
        //if the sender if a table view cell
        if ([sender isKindOfClass:[UITableViewCell class]])
            indexPath=[self.tableView indexPathForCell:sender];
        
        //else if the sender is an index path (probably sent by the createRecordWithRecordType method)
        else if ([sender isKindOfClass:[NSIndexPath class]])
            indexPath=(NSIndexPath *)sender;
        
        //Set up the record for the record view controller
        Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setRecord:record];
        
        //Set the delegate of the destination view controller to be self
        [segue.destinationViewController setDelegate:self];
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

#pragma mark - ModalRecordTypeSelectorDelegate methods

- (void)modalRecordTypeSelector:(ModalRecordTypeSelector *)sender userDidPickRecordType:(NSString *)recordType {
    //Create a new record
    [self createRecordForRecordType:recordType];
    
    //Dismiss modal view controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Record Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=record.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Folder: %@",record.folder.folderName];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //If editting style is delete, delete the corresponding record
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self deleteRecordAtIndexPath:indexPath];
    }
}

@end
