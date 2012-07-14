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
#import "Record+Types.h"
#import "Record+Creation.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Record+DateAndTimeFormatter.h"
#import "Formation_Folder.h"
#import "CheckBox.h"
#import "Image.h"

#import "ModelGroupNotificationNames.h"

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate,UIAlertViewDelegate,FormationFolderPickerDelegate,UIActionSheetDelegate,UIScrollViewDelegate,UIAlertViewDelegate>

#pragma mark - Image Cache

@property (nonatomic,strong) NSMutableDictionary *imageCache;

#pragma mark - Temporary record's modified info

@property (nonatomic,strong) Record *modifiedRecord;
@property (nonatomic,strong) NSDictionary *recordModifiedInfo;

@property (nonatomic,strong) NSArray *toBeDeletedRecords;

#pragma mark - UI Outlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem *setLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

#pragma mark - Temporary buttons

@property (nonatomic,strong) UIBarButtonItem *hiddenButton;

#pragma mark - Popover Controllers

@property (nonatomic,weak) UIPopoverController *formationFolderPopoverController;

@end

@implementation RecordTableViewController

@synthesize imageCache=_imageCache;

@synthesize folder=_folder;
@synthesize database=_database;

@synthesize willShowCheckboxes=_willShowCheckboxes;

@synthesize modifiedRecord=_modifiedRecord;
@synthesize recordModifiedInfo=_recordModifiedInfo;
@synthesize toBeDeletedRecords=_toBeDeletedRecords;

@synthesize setLocationButton = _setLocationButton;
@synthesize editButton = _editButton;
@synthesize deleteButton = _deleteButton;
@synthesize addButton = _addButton;
@synthesize hiddenButton=_hiddenButton;

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

#pragma mark - Getters

- (NSArray *)selectedRecords {
    return [self.fetchedResultsController fetchedObjects];
}

- (NSMutableDictionary *)imageCache {
    if (!_imageCache)
        _imageCache=[NSMutableDictionary dictionary];
    
    return _imageCache;
}

- (NSArray *)toBeDeletedRecords {
    if (!_toBeDeletedRecords)
        _toBeDeletedRecords=[NSArray array];
    
    return _toBeDeletedRecords;
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
    //Update the record
    [record updateWithNewRecordInfo:recordInfo];
    
    //Save changes to database
    [self saveChangesToDatabase:self.database completion:^(BOOL success){
        if (success) {
            //Highlight the modified record
            [self highlightRecord:record];
            
            //Post a notification to indicate that the record database has changed
            [self postNotificationWithName:GeoNotificationModelGroupRecordDatabaseDidChange andUserInfo:[NSDictionary dictionary]];
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
    
    //Hide the delete button
    self.hiddenButton=self.deleteButton;
    NSMutableArray *toolbarItems=[self.toolbarItems mutableCopy];
    [toolbarItems removeObject:self.deleteButton];
    self.toolbarItems=[toolbarItems copy];
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
    
    //Flush the image cache
    [self flushImageCache];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
    [self setupUIForEditingMode:self.tableView.editing];
    
    //Reset the array of to be deleted records
    self.toBeDeletedRecords=nil;
}

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedRecords=self.toBeDeletedRecords.count;
    NSString *message=numOfDeletedRecords > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d records?",numOfDeletedRecords] : @"Are you sure you want to delete this record?";
    NSString *destructiveButtonTitle=numOfDeletedRecords > 1 ? @"Delete Records" : @"Delete Record";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
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
    cell.name.text=[NSString stringWithFormat:@"%@",record.name];
    cell.type.text=[record.class description];
    cell.date.text=[Record dateFromNSDate:record.date];
    cell.time.text = [Record timeFromNSDate:record.date];
    
    //Hide the spinner (in case it's still animating as the cell has been reused)
    cell.spinner.hidden=YES;

    //Set the image to nil (for asyncronous image loading)
    cell.recordImageView.image=nil;
    
    //Load the image asynchronously
    [self loadImageForCell:cell withRecord:record];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)cacheImage:(UIImage *)image forHashValue:(NSString *)hashValue {
    //If the cache has more than 30 images, flush it
    if ([self.imageCache count]>30)
        [self flushImageCache];
    
    //Cache the given image
    [self.imageCache setValue:image forKey:hashValue];
}

- (UIImage *)imageInCacheWithHashValue:(NSString *)hashValue {
    return [self.imageCache objectForKey:hashValue];
}

- (void)flushImageCache {
    self.imageCache=[NSMutableDictionary dictionary];
}

- (void)loadImageForCell:(CustomRecordCell *)cell withRecord:(Record *)record {
    UIImage *image=[self imageInCacheWithHashValue:[NSString stringWithFormat:@"%@",record.image.imageHash]];
    if (image)
        cell.recordImageView.image=image;
    
    //Load and cache the image if it's not there
    else {
        //Show the spinner
        cell.spinner.hidden=NO;
        [cell.spinner startAnimating];
        
        //Load the image from database asynchronously
        dispatch_queue_t image_loader=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(image_loader, ^{
            UIImage *image = [[UIImage alloc] initWithData:record.image.imageData];
            [self cacheImage:image forHashValue:[NSString stringWithFormat:@"%@",record.image.imageHash]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Load the image
                if (!cell.recordImageView.image) {
                    cell.recordImageView.image=image;
                    
                    //Stop the spinner
                    [cell.spinner stopAnimating];
                    cell.spinner.hidden=YES;
                }
            });
        });
        
        dispatch_release(image_loader);
    }
}

- (void)loadImagesForCells:(NSArray *)cells {
    for (CustomRecordCell *cell in cells) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
        Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Try to retrieve the image from the cache
        [self loadImageForCell:cell withRecord:record];
    }
}

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
        NSMutableArray *toBeDeletedRecords=[self.toBeDeletedRecords mutableCopy];
        [toBeDeletedRecords addObject:folder];
        self.toBeDeletedRecords=[toBeDeletedRecords copy];
        
        //Update the title of the delete button
        int numRecords=self.toBeDeletedRecords.count;
        self.deleteButton.title=numRecords>0 ? [NSString stringWithFormat:@"Delete (%d)",numRecords] : @"Delete";
        
        //Enable the delete button
        self.deleteButton.enabled=numRecords>0;
    }
    
    //Else, save the chosen record
    else if (self.chosenRecord!=[self.fetchedResultsController objectAtIndexPath:indexPath])
        self.chosenRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //If the table view is in editing mode, decrement the count for delete
    if (self.tableView.editing) {
        //Remove the selected folder from the delete list
        Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSMutableArray *toBeDeletedRecords=[self.toBeDeletedRecords mutableCopy];
        [toBeDeletedRecords removeObject:folder];
        self.toBeDeletedRecords=[toBeDeletedRecords copy];
         
        //Update the title of the delete button
        int numRecords=self.toBeDeletedRecords.count;
        self.deleteButton.title=numRecords>0 ? [NSString stringWithFormat:@"Delete (%d)",numRecords] : @"Delete";
        
        //Enable the delete button
        self.deleteButton.enabled=numRecords>0;
    }
}

#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the delete record action sheet and user clicks "Delete Records" or "Delete Record", delete the record(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Delete Records",@"Delete Record", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Delete the selected folders
        [self deleteRecords:self.toBeDeletedRecords];
        
        //End editing mode
        if (self.tableView.editing)
            [self editPressed:self.editButton];
    }
}

@end