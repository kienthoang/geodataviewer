//
//  RecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordTableViewController.h"
#import "ModalRecordTypeSelector.h"
#import "Folder.h"
#import "Record+Types.h"
#import "Record+Creation.h"

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate>

- (void)createRecordForRecordType:(NSString *)recordType;
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

#pragma mark - Record Creation/Deletion

//Create a new record entity with the specified record type
- (void)createRecordForRecordType:(NSString *)recordType {
    [Record recordForRecordType:recordType andFolderName:self.folderName inManagedObjectContext:self.database.managedObjectContext];
}

//Delete the record at the specified index path in the table
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath {
    //Get the record and delete it
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.database.managedObjectContext deleteObject:record];
    NSLog(@"DatabaseL %@",self.database);
    
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //handle errors
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
        
    }
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle editting mode of the table view
    [self.tableView setEditing:!self.tableView.editing animated:YES];
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
