//
//  PrototypeFormationTableViewController.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeFormationTableViewController.h"

@interface PrototypeFormationTableViewController ()

@end

@implementation PrototypeFormationTableViewController

@synthesize database=_database;
@synthesize folder=_folder;

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationFolder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationFolder.folderName" ascending:YES]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Setters

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

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Set up fetchedResultsController
        if (self.folder) {
            //Make sure the document is open and set up the fetched result controller
            [self normalizeDatabase]; 
        }
    }
}

- (void)setFolder:(Formation_Folder *)folder {
    _folder=folder;
    
    //Set up fetchedResultsController
    if (self.folder)
        [self setupFetchedResultsController];
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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.database) {
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Formation *formation=[self.fetchedResultsController objectAtIndexPath:indexPath];  
    
    cell.textLabel.text=formation.formationName;
    
    return cell;
}

@end