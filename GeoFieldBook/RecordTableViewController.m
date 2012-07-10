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

@interface RecordTableViewController() <ModalRecordTypeSelectorDelegate,UIAlertViewDelegate,FormationFolderPickerDelegate,UIActionSheetDelegate,UIScrollViewDelegate>

- (void)createRecordForRecordType:(NSString *)recordType;
- (void)modifyRecord:(Record *)record withNewInfo:(NSDictionary *)recordInfo;
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Image Cache

@property (nonatomic,strong) NSMutableDictionary *imageCache;

#pragma mark - Temporary record's modified info

@property (nonatomic,strong) Record *modifiedRecord;
@property (nonatomic,strong) NSDictionary *recordModifiedInfo;

#pragma mark - UI Outlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem *setLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

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
@synthesize setLocationButton = _setLocationButton;
@synthesize editButton = _editButton;

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
    [self updateCheckboxes];
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

//Delete the record at the specified index path in the table
- (void)deleteRecordAtIndexPath:(NSIndexPath *)indexPath {
    //Get the record and delete it
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.database.managedObjectContext deleteObject:record];
    
    //If the deleted record is the currently chosen record, set it to nil
    if (record==self.chosenRecord)
        self.chosenRecord=nil;
    
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

#pragma mark - View lifecycle

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
    UIActionSheet *controlActionSheet=[[UIActionSheet alloc] initWithTitle:@"Control Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Set Location",@"Control Option 1",@"Control Option 2", nil];
    [controlActionSheet showInView:self.view];
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

- (void)updateCheckboxes {
    //Iterate through the visible table cells and manage their checkboxes
    for (CustomRecordCell *cell in self.tableView.visibleCells) {
        Record *record=[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        
        //Set up the checkbox
        CheckBox *checkbox=cell.checkBox;
        checkbox.image=[self.selectedRecordTypes containsObject:[record.class description]] ? checkbox.checked : checkbox.unchecked;
        if (!self.selectedRecordTypes)
            checkbox.image=checkbox.checked;
        if (self.willShowCheckboxes)
            [cell showCheckBoxAnimated:YES];
        else
            [cell hideCheckBoxAnimated:YES];
    }
}

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
    //If the cache has more than 50 images, flush it
    if ([self.imageCache count]>50)
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

- (void) tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //If editting style is delete, delete the corresponding record
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self deleteRecordAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Save the chosen record
    if (self.chosenRecord!=[self.fetchedResultsController objectAtIndexPath:indexPath])
        self.chosenRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end