//
//  RecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordTableViewController.h"
#import "FormationFolderPickerViewController.h"
#import "UISplitViewBarButtonPresenter.h"
#import "ModalRecordTypeSelector.h"
#import "GeoDatabaseManager.h"
#import "RecordViewController.h"
#import "Folder.h"

#import "Record.h"
#import "Record+Types.h"
#import "Record+Creation.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Record+DateAndTimeFormatter.h"
#import "Formation_Folder.h"

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate,RecordViewControllerDelegate,UIAlertViewDelegate,FormationFolderPickerDelegate,UIActionSheetDelegate>

- (void)createRecordForRecordType:(NSString *)recordType;
- (void)modifyRecord:(Record *)record withNewInfo:(NSDictionary *)recordInfo;
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath;

- (void)autosaveRecord:(Record *)record withNewRecordInfo:(NSDictionary *)recordInfo;

#pragma mark - Temporary record's modified info

@property (nonatomic,strong) Record *modifiedRecord;
@property (nonatomic,strong) NSDictionary *recordModifiedInfo;

#pragma mark - UI Outlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem *setLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationFolderPopoverController;

#pragma mark - Currently active record

@property (nonatomic,weak) Record *chosenRecord;

@end

@implementation RecordTableViewController

@synthesize folder=_folder;
@synthesize database=_database;

@synthesize modifiedRecord=_modifiedRecord;
@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize setLocationButton = _setLocationButton;
@synthesize editButton = _editButton;

@synthesize autosaveDelegate=_autosaveDelegate;
@synthesize delegate=_delegate;

@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize chosenRecord=_chosenRecord;

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Setters

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Set up fetchedResultsController
        [self setupFetchedResultsController];
    }
}

- (void)setFolder:(Folder *)folder {
    _folder=folder;
    
    //Set up fetchedResultsController
    [self setupFetchedResultsController];
    
    //Set the title of the set location button
    NSString *formationFolderName=self.folder.formationFolder.folderName;
    self.setLocationButton.title=[formationFolderName length] ? formationFolderName : @"Set Location";
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

#pragma mark - Autosave Controller

- (UIAlertView *)autosaveAlertForValidationOfRecordInfo:(NSDictionary *)recordInfo {
    UIAlertView *autosaveAlert=nil;
    
    //If the record info passes the validations, show the alert; otherwise, show an alert with no confirm button
    NSArray *failedKeyNames=[Record validatesMandatoryPresenceOfRecordInfo:recordInfo];
    if (![failedKeyNames count]) {
        //If the name of the record is not nil
        NSString *message=@"You are navigating away. Do you want to save the record you were editing?";
        
        //Put up an alert to ask the user whether he/she wants to save
        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave" 
                                                              message:message 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Don't Save" 
                                                    otherButtonTitles:@"Save", nil];
    } else {
        //Show the autosave fail alert with all the missing record info
        NSMutableArray *failedNames=[NSMutableArray array];
        for (NSString *failedKey in failedKeyNames)
            [failedNames addObject:[Record nameForDictionaryKey:failedKey]];
        NSString *message=[NSString stringWithFormat:@"Record could not be saved because the following information was missing: %@",[failedNames componentsJoinedByString:@", "]];
        autosaveAlert=[[UIAlertView alloc] initWithTitle:@"Autosave Failed!" 
                                                                  message:message 
                                                                 delegate:nil 
                                                        cancelButtonTitle:@"Dismiss" 
                                                        otherButtonTitles:nil];
    }
    
    return autosaveAlert;
}

- (void)autosaveRecord:(Record *)record 
     withNewRecordInfo:(NSDictionary *)recordInfo 
{
    //Save the recordInfo dictionary in a temporary property
    self.recordModifiedInfo=recordInfo;
    
    //Save the record in a temporary property
    self.modifiedRecord=record;
    
    //Get and show the appropriate alert
    UIAlertView *autosaveAlert=[self autosaveAlertForValidationOfRecordInfo:recordInfo];
    [autosaveAlert show];
}

//Ask the folder tvc
- (void)setupAutosaveBeforeGoingOffStack {
    //Get the detail view controller
    id detailvc=[self.splitViewController.viewControllers lastObject];
    if (![detailvc isKindOfClass:[RecordViewController class]])
        detailvc=nil;
    RecordViewController *detail=(RecordViewController *)detailvc;
    
    //If the detail vc is in editing mode and self is being kicked off the navigation stack (it's going away!!!!!!)
    if ([detail isInEdittingMode] && ![self.navigationController.viewControllers containsObject:self]) {
        //Get the record
        Record *modifiedRecord=[(RecordViewController *)detailvc record];
        NSDictionary *recordModifiedInfo=[(RecordViewController *)detailvc dictionaryFromForm];
        UIManagedDocument *database=self.database;
        
        //Get the approriate alert view
        UIAlertView *autosaveAlert=[self autosaveAlertForValidationOfRecordInfo:recordModifiedInfo];
        
        [self.autosaveDelegate recordTableViewController:self showAlert:autosaveAlert andExecuteBlockOnCancel:^{
            //NSLog(@"Cancel autosave alert!");
        } andExecuteBlock:^{
            //Update the record info if the info passed validations
            [modifiedRecord updateWithNewRecordInfo:recordModifiedInfo];
            
            //Save changes to database
            [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){}];
        } whenClickButtonWithTitle:@"Save"];
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

#pragma mark - Record Creation/Update/Deletion

- (void)saveChangesToDatabase:(UIManagedDocument *)database completion:(completion_handler_t)completionHandler {
    //Save changes to database
    [database saveToURL:database.fileURL 
       forSaveOperation:UIDocumentSaveForOverwriting 
      completionHandler:^(BOOL success)
     {
         //If there was a failure, put up an alert
         if (!success) {
             //handle errors
             [self putUpDatabaseErrorAlertWithMessage:@"Could not save changes to the database. Please try again."];
         }
         
        //Pass control to the completion handler when the saving is done
        completionHandler(success);
    }];
}

- (void)highlightRecord:(Record *)record {
    //get ithe index path of the specified record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:record];
    
    //Select the new record
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    //Show the record on the detail view
    [self performSegueWithIdentifier:@"Show Record" sender:[self.fetchedResultsController indexPathForObject:record]];
}

//Put the right hand side (detail view) into editing mode, probably used when a new record is created
- (void)putDetailViewIntoEditingMode {
    //Get the detail vc and if it's of RecordViewController class, put it into editing mode
    id detailvc=[self.splitViewController.viewControllers lastObject];
         [detailvc setEditing:YES animated:YES validationEnabled:NO];
}

//Create a new record entity with the specified record type
- (void)createRecordForRecordType:(NSString *)recordType {
    Record *record=[Record recordForRecordType:recordType andFolderName:self.folder.folderName 
                        inManagedObjectContext:self.database.managedObjectContext];
    
    //highlight the newly created record
    [self highlightRecord:record];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        if (success) {
            //highlight the newly created record
            [self highlightRecord:record];
            
            //Put the detail view (now showing the newly created record's info) into editing mode
            [self putDetailViewIntoEditingMode];
        }
    }];
}

//Modify a record with the specified record type
- (void)modifyRecord:(Record *)record 
         withNewInfo:(NSDictionary *)recordInfo
{
    //Update the record
    [record updateWithNewRecordInfo:recordInfo];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        if (success) {
            //highlight the newly modified record if it's also the currently chosen record
            if (record==self.chosenRecord)
                [self highlightRecord:record];
        }
    }];
}

//Delete the record at the specified index path in the table
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath {
    //Get the record and delete it
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.database.managedObjectContext deleteObject:record];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){}];
}

#pragma mark - FormationFolderPickerDelegate methods

- (void)formationFolderPickerViewController:(FormationFolderPickerViewController *)sender 
       userDidSelectFormationFolderWithName:(NSString *)formationFolderName 
{
    //Save the formation folder name in the folder if the returned formationFolderName is not empty (it's empty when user selects the empty option)
    if ([formationFolderName length])
        [self.delegate recordTableViewController:self 
                               needsUpdateFolder:self.folder
                          setFormationFolderName:formationFolderName];
    
    //Change the text of the set location button to show the new location
    self.setLocationButton.title=[formationFolderName length] ? formationFolderName : @"Set Location";
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
        //Save the record info
        [self modifyRecord:self.modifiedRecord withNewInfo:self.recordModifiedInfo];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    //Nillify the temporary record modified data
    self.modifiedRecord=nil;
    self.recordModifiedInfo=nil;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If user click set location
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Set Location"]) {
        [self performSegueWithIdentifier:@"Formation Folder Picker" sender:self];
    }
}

#pragma mark - RecordViewControllerDelegate methods

- (void)recordViewController:(RecordViewController *)sender 
         userDidModifyRecord:(Record *)record 
           withNewRecordInfo:(NSDictionary *)recordInfo
{
    //Modify the specified record with the specified info
    [self modifyRecord:record withNewInfo:recordInfo];
}

- (void)userDidNavigateAwayFrom:(RecordViewController *)sender 
           whileModifyingRecord:(Record *)record 
              withNewRecordInfo:(NSDictionary *)recordInfo
{
    [self autosaveRecord:record withNewRecordInfo:recordInfo];
}

- (UIManagedDocument *)databaseForFormationPicker {
    return self.database;
}

- (NSString *)formationFolderName {
    return self.setLocationButton.title;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set the title of the set location button
    NSString *formationFolderName=self.folder.formationFolder.folderName;
    self.setLocationButton.title=[formationFolderName length] ? formationFolderName : @"Set Location";
}

- (void)viewWillDisappear:(BOOL)animated {    
    //Setup the autosaver if self is going off stack and the detail view is still in editing mode
    [self setupAutosaveBeforeGoingOffStack];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setSetLocationButton:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a modal record type selector, set the destination controller's array of record types
    if ([segue.identifier isEqualToString:@"Select Record Type"]) {
        //Prepare the segue's destination
        [segue.destinationViewController setRecordTypes:[Record allRecordTypes]];
        [segue.destinationViewController setDelegate:self];
        
        //End the table view's editing mode if the table is in editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    } else if ([segue.identifier isEqualToString:@"Show Record"]) {
        //Transfer the bar button item over
        id <UISplitViewBarButtonPresenter> detailvc=[self barButtonPresenter];
        if (detailvc)
            [segue.destinationViewController setSplitViewBarButtonItem:[detailvc splitViewBarButtonItem]];
        
        
        NSIndexPath *indexPath=nil;
        //if the sender is a table view cell
        if ([sender isKindOfClass:[UITableViewCell class]])
            indexPath=[self.tableView indexPathForCell:sender];
        
        //else if the sender is an index path (probably sent by the createRecordWithRecordType method)
        else if ([sender isKindOfClass:[NSIndexPath class]])
            indexPath=(NSIndexPath *)sender;
        
        //Set up the record for the record view controller
        Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setRecord:record];
        
        //Save the chosen record
        self.chosenRecord=record;
        
        //Set the delegate of the destination view controller to be self
        [segue.destinationViewController setDelegate:self];
    }
    
    //Seguing to the formation folder picker popover
    else if ([segue.identifier isEqualToString:@"Formation Folder Picker"]) {
        //Prepare the destination view controller
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setDelegate:self];
        
        //Dismiss the formation folder picker popover if it's already there
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:YES];
        
        //Save the new formation folder picker popover
        UIStoryboardPopoverSegue *popoverSegue=(UIStoryboardPopoverSegue *)segue;
        self.formationFolderPopoverController=popoverSegue.popoverController;
        
        //Set the previously selected formation name
        [segue.destinationViewController setPreviousSelection:self.folder.formationFolder.folderName];
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

- (IBAction)controlPressed:(UIBarButtonItem *)sender {
    //Set up an action sheet of control buttons
    UIActionSheet *controlActionSheet=[[UIActionSheet alloc] initWithTitle:@"Control Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Importing Records",@"Exporting Records",@"Set Location", nil];
    [controlActionSheet showInView:self.view];
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
    
    CustomRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //show the name, date and time
    cell.name.text=[NSString stringWithFormat:@"%@ (%@)",record.name,[record.class description]];    
    cell.date.text=[Record dateFromNSDate:record.date];
    cell.time.text = [Record timeFromNSDate:record.date];
    
    //show the image
    UIImage *image = [[UIImage alloc] initWithData:record.image.imageData];
    cell.recordImageView.image=image;
    
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