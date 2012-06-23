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

@end

@implementation RecordTableViewController

@synthesize folderName=_folderName;
@synthesize database=_database;

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
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
    }
}

#pragma mark - ModalRecordTypeSelectorDelegate methods

- (void)modalRecordTypeSelector:(ModalRecordTypeSelector *)sender userDidPickRecordType:(NSString *)recordType {
    //Create a new record
    [Record recordForRecordType:recordType andFolderName:self.folderName inManagedObjectContext:self.database.managedObjectContext];
    
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

@end
