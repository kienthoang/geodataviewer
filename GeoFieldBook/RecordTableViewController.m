//
//  RecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordTableViewController.h"
#import "FormationFolderPickerViewController.h"
#import "ModalRecordTypeSelector.h"
#import "GeoDatabaseManager.h"
#import "Folder.h"

#import "Record.h"
#import "Record+State.h"
#import "Record+Types.h"
#import "Record+Creation.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Record+DateAndTimeFormatter.h"
#import "Formation_Folder.h"
#import "CheckBox.h"
#import "Image.h"

#import "ModelGroupNotificationNames.h"

#import "FolderSelectTableViewController.h"
#import "FolderSelectTableViewControllerDelegate.h"

#import "SettingManager.h"

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate,UIAlertViewDelegate,FormationFolderPickerDelegate,UIActionSheetDelegate,UIScrollViewDelegate,UIAlertViewDelegate,FolderSelectTableViewControllerDelegate>

#pragma mark - Image Cache

#pragma mark - Temporary record's modified info

@property (nonatomic,strong) Record *modifiedRecord;
@property (nonatomic,strong) NSDictionary *recordModifiedInfo;

@property (nonatomic,strong) NSArray *selectedRecords;

#pragma mark - UI Outlets

@property (strong, nonatomic) IBOutlet UIBarButtonItem *setLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectNone;

#pragma mark - Temporary buttons

@property (nonatomic,strong) UIBarButtonItem *hiddenButton;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationFolderPopoverController;

@end

@implementation RecordTableViewController

@synthesize willShowCheckboxes=_willShowCheckboxes;

@synthesize modifiedRecord=_modifiedRecord;
@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize selectedRecords=_selectedRecords;

@synthesize setLocationButton = _setLocationButton;
@synthesize editButton = _editButton;
@synthesize deleteButton = _deleteButton;
@synthesize addButton = _addButton;
@synthesize moveButton=_moveButton;
@synthesize hiddenButton=_hiddenButton;
@synthesize selectAllButton = _selectAllButton;
@synthesize selectNone = _selectNone;

@synthesize delegate=_delegate;
@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize chosenRecord=_chosenRecord;

@synthesize selectedRecordTypes=_selectedRecordTypes;

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Setters

- (void)setWillShowCheckboxes:(BOOL)willShowCheckboxes {
    _willShowCheckboxes=willShowCheckboxes;
    
    //Reset the checkboxes
    [self reloadCheckboxesInVisibleCellsForEditingMode:self.tableView.editing];
}

- (void)setSelectedRecordTypes:(NSArray *)selectedRecordTypes {
    if (![_selectedRecordTypes isEqualToArray:selectedRecordTypes]) {
        _selectedRecordTypes=selectedRecordTypes;
        
        //Reload the checkboxes
        if (self.selectedRecordTypes)
            [self.tableView reloadData];
    }
}

- (void)setChosenRecord:(Record *)chosenRecord {
    _chosenRecord=chosenRecord;
    
    //Post a notification
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:self.chosenRecord,GeoNotificationKeyModelGroupSelectedRecord, nil];
    [self postNotificationWithName:GeoNotificationModelGroupDidSelectRecord andUserInfo:userInfo];

}

- (void)updateDeleteButton {
    //Update the title of the delete button
    int numRecords=self.selectedRecords.count;
    self.deleteButton.title=numRecords>0 ? [NSString stringWithFormat:@"Delete (%d)",numRecords] : @"Delete";
    
    //Enable the delete button
    self.deleteButton.enabled=numRecords>0;
}

- (void)updateMoveButton {
    //Update the title of the move button
    int numRecords=self.selectedRecords.count;
    self.moveButton.title=numRecords>0 ? [NSString stringWithFormat:@"Move (%d)",numRecords] : @"Move";
    
    //Enable the delete button
    self.moveButton.enabled=numRecords>0;
}


- (void)setSelectedRecords:(NSArray *)selectedRecords {
    if (selectedRecords) {
        _selectedRecords=selectedRecords;
                
        //Update the delete button
        [self updateDeleteButton];
        
        //Update the move button
        [self updateMoveButton];
    }
}

#pragma mark - Getters

- (NSArray *)records {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    return [self.database.managedObjectContext executeFetchRequest:request error:NULL];
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
    if (![indexPath isEqual:self.tableView.indexPathForSelectedRow])
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

//Put the right hand side (detail view) into editing mode, probably used when a new record is created
- (void)putDetailViewIntoEditingMode {
    //Post a notification
    [self postNotificationWithName:GeoNotificationModelGroupDidCreateNewRecord andUserInfo:[NSDictionary dictionary]];
}

//Create a new record entity with the specified record type
- (void)createRecordForRecordType:(NSString *)recordType {
    Record *record=[Record recordForRecordType:recordType andFolderName:self.folder.folderName 
                        inManagedObjectContext:self.database.managedObjectContext];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        if (success) {
            //Choose the newly created record
            self.chosenRecord=record;
            
            //highlight the newly created record and update the detail view accordingly
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
    //Save the current longitude and latitude of the record for reference
    CLLocationDegrees latitude=record.latitude.doubleValue;
    CLLocationDegrees longitude=record.longitude.doubleValue;
    
    //If the record state is new, increment the feedback counter
    if (record.recordState==RecordStateNew) {
        SettingManager *settingManager=[SettingManager standardSettingManager];
        int feedbackCounter=settingManager.feedbackCounter.intValue;
        settingManager.feedbackCounter=[NSNumber numberWithInt:feedbackCounter+1];
    }
    
    //Update the record
    [record updateWithNewRecordInfo:recordInfo];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        if (success) {
            //Highlight the modified record
            [self highlightRecord:record];
            
            //If the record's latitude and longitude weren't updated, post a notification to indicate that the database has updated
            if (latitude==record.latitude.doubleValue && longitude==record.longitude.doubleValue) {
                //Post a notification to indicate that the record database has changed
                [self postNotificationWithName:GeoNotificationModelGroupRecordDatabaseDidUpdate andUserInfo:[NSDictionary dictionary]];
            }
            
            //Else post a notification to indicate that the database has changed (to update location)
            else {
                //Post a notification to indicate that the record database has changed
                [self postNotificationWithName:GeoNotificationModelGroupRecordDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
            }
        }
    }];
}

//Delete the given records
- (void)deleteRecords:(NSArray *)records {
    //Get the record and delete it
    for (Record *record in records) {
        [self.database.managedObjectContext deleteObject:record];
    
        //If the deleted record is the currently chosen record, set it to nil
        if (record==self.chosenRecord)
            self.chosenRecord=nil;
    }
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        //Post a notification to indicate that the record database has changed
        [self postNotificationWithName:GeoNotificationModelGroupRecordDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    }];
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

- (void)alertViewCancel:(UIAlertView *)alertView {
    //Nillify the temporary record modified data
    self.modifiedRecord=nil;
    self.recordModifiedInfo=nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Hide the buttons
    self.hiddenButton=self.addButton;
    [self setupButtonsForEditingMode:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //highlight the currently chosen record
    [self highlightRecord:self.chosenRecord];
    
    //Set the title of the set location button
    NSString *formationFolderName=self.folder.formationFolder.folderName;
    self.setLocationButton.title=[formationFolderName length] ? formationFolderName : @"Set Location";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Switch out of editing mode
    if (self.tableView.editing)
        [self editPressed:self.editButton];
}

- (void)viewDidUnload {
    [self setSetLocationButton:nil];
    [self setEditButton:nil];
    [self setDeleteButton:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}

#pragma mark - Target-Action Handlers

- (void)reloadCheckboxesInVisibleCellsForEditingMode:(BOOL)editing {
    for (CustomRecordCell *cell in self.tableView.visibleCells) {
        if (editing || !self.willShowCheckboxes)
            [cell hideCheckBoxAnimated:YES];
        else {
            //Show the checkboxes
            [cell showCheckBoxAnimated:YES];
        }
    }
}

- (void)setupUIForEditingMode:(BOOL)editing {
    //Setup the buttons
    [self setupButtonsForEditingMode:editing];
    
    //Reload the checkboxes
    [self reloadCheckboxesInVisibleCellsForEditingMode:editing];
}

- (void)toggleSelectButtonsForEditingMode:(BOOL)editing {
    //Setup the select buttons
    NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
    if (editing) {
        [toolbarItems insertObject:self.selectAllButton atIndex:1];
        [toolbarItems insertObject:self.selectNone atIndex:toolbarItems.count-1];
    }
    else {
        [toolbarItems removeObject:self.selectAllButton];
        [toolbarItems removeObject:self.selectNone];
    }
    
    self.toolbarItems=toolbarItems.copy;
}

- (void)toggleSetLocationButtonForEditingMode:(BOOL)editing {
    //Hide the set location button if in editing mode
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    if (editing)
        [toolbarItems removeObject:self.setLocationButton];
    else {
        if (![toolbarItems containsObject:self.setLocationButton])
            [toolbarItems insertObject:self.setLocationButton atIndex:2];
    }
    
    self.toolbarItems=[toolbarItems copy];
}

- (void)toggleAddDeleteButtonsForEditingMode:(BOOL)editing {
    UIBarButtonItem *hiddenButton=self.hiddenButton;
    self.hiddenButton=editing ? self.addButton : self.deleteButton;
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    if (editing)
        [toolbarItems removeObject:self.addButton];
    else
        [toolbarItems removeObject:self.deleteButton];
    
    if (![toolbarItems containsObject:hiddenButton])
        [toolbarItems insertObject:hiddenButton atIndex:(editing ? 2 : 0)];
    
    self.toolbarItems=[toolbarItems copy];
    
    //Reset the title of the delete button and disable it
    self.deleteButton.title=@"Delete";
    self.deleteButton.enabled=NO;
    
    //Reset the title of the move button and disable it
    self.moveButton.title=@"Move";
    self.moveButton.enabled=NO;
}

- (void)toggleMoveButtonForEditingMode:(BOOL)editing {
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    if (!editing)
        [toolbarItems removeObject:self.moveButton];
    else {
        if (![toolbarItems containsObject:self.moveButton])
            [toolbarItems insertObject:self.moveButton atIndex:2];
    }
    
    self.toolbarItems=[toolbarItems copy];
}

- (void)setupButtonsForEditingMode:(BOOL)editing {
    //Change the style of the action button
    self.editButton.style=editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    
    //Show/Hide add/delete button
    [self toggleAddDeleteButtonsForEditingMode:editing];
    
    //Set up the set location button
    [self toggleSetLocationButtonForEditingMode:editing];
    
    //Set up select buttons
    [self toggleSelectButtonsForEditingMode:editing];
    
    //Set up the move button
    [self toggleMoveButtonForEditingMode:editing];
}

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Set the table view to editting mode
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    //Set up the buttons
    [self setupUIForEditingMode:self.tableView.editing];
    
    //Reset the array of to be deleted records
    if (self.tableView.editing)
        self.selectedRecords=[NSArray array];
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedRecords=self.selectedRecords.count;
    NSString *message=numOfDeletedRecords > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d records?",numOfDeletedRecords] : @"Are you sure you want to delete this record?";
    NSString *destructiveButtonTitle=numOfDeletedRecords > 1 ? @"Delete Records" : @"Delete Record";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (IBAction)movePressed:(UIBarButtonItem *)sender {
    
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.selectedRecords=self.fetchedResultsController.fetchedObjects;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.selectedRecords=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
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
    
    //Seguing to the folder select tvc
    else if ([segue.identifier isEqualToString:@"Move Records"]) {
        UINavigationController *navigationController=(UINavigationController *)segue.destinationViewController;
        [(FolderSelectTableViewController *)navigationController.topViewController setDelegate:self];        
    }
}


#pragma mark - ModalRecordTypeSelectorDelegate methods

- (void)modalRecordTypeSelector:(ModalRecordTypeSelector *)sender userDidPickRecordType:(NSString *)recordType {
    //Create a new record
    [self createRecordForRecordType:recordType];
    
    //Dismiss modal view controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomRecordCell *cell=(CustomRecordCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //Select cell if its record is in the list of selected records
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.selectedRecords containsObject:record]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    //Load the checkbox if table view is not in editing mode and willShowCheckBoxes is YES (the map is visible)
    if (tableView.editing || !self.willShowCheckboxes)
        [cell hideCheckBoxAnimated:YES];
    else {
        //Show the checkboxes
        [cell showCheckBoxAnimated:YES];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //Load images for visible cells
        [self loadImagesForCells:self.tableView.visibleCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //Load images for visible cells
    [self loadImagesForCells:self.tableView.visibleCells];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, increment the count for delete
    if (self.tableView.editing) {
        //Add the selected record to the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *selectedRecords=self.selectedRecords.mutableCopy;
        [selectedRecords addObject:folder];
        self.selectedRecords=selectedRecords.copy;
    }
    
    //Else, save the chosen record
    else {
        self.chosenRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *selectedRecords=self.selectedRecords.mutableCopy;
        [selectedRecords removeObject:folder];
        self.selectedRecords=selectedRecords.copy;
    }
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete record action sheet and user clicks "Delete Records" or "Delete Record", delete the record(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Records",@"Delete Record", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected folders
        [self deleteRecords:self.selectedRecords];
        
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}
#pragma mark - FolderSelectTableViewController Protocol methods

- (void)folderSelectTVC:(FolderSelectTableViewController *)sender userDidSelectFolder:(Folder *)folder {
    //Move the selected folders to the destination folder
    for (Record *record in self.selectedRecords) {
        //Change the folder of the record
        record.folder=folder;        
    }
    
    //Post a notification
    [self postNotificationWithName:GeoNotificationModelGroupRecordDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
    
    //Reload the table
    [self.tableView reloadData];
    
    //Dismiss the modal
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Change active records

- (BOOL)hasNextRecord {
    //If the currently chosen record is not the last record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:self.chosenRecord];
    return indexPath.row<self.fetchedResultsController.fetchedObjects.count-1;
}

- (BOOL)hasPrevRecord {
    //If the currently chosen record is not the first record and there's more than 1 record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:self.chosenRecord];
    return indexPath.row>0 && self.fetchedResultsController.fetchedObjects.count>1;
}

- (void)forwardToNextRecord {
    //Get the index path of the currenly chosen record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:self.chosenRecord];
    
    //if there is a next record, choose the next record
    if ([self hasNextRecord]) {
        NSIndexPath *nextIndexPath=[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        self.chosenRecord=[self.fetchedResultsController objectAtIndexPath:nextIndexPath];
    }
} 

- (void)backToPrevRecord {
    //Get the index path of the currenly chosen record
    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:self.chosenRecord];
    
    //If there is a prev record, choose the prev record
    if ([self hasPrevRecord]) {
        NSIndexPath *prevIndexPath=[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        self.chosenRecord=[self.fetchedResultsController objectAtIndexPath:prevIndexPath];
    }
}

@end