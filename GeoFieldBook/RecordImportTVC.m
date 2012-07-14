//
//  RecordImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordImportTVC.h"
#import "IEConflictHandlerNotificationNames.h"

#import "TransientProject.h"

@interface RecordImportTVC() <UIAlertViewDelegate>

@property (nonatomic,strong) UIBarButtonItem *spinner;

@end

@implementation RecordImportTVC

@synthesize spinner=_spinner;

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get the list of csv files from the document directories
    NSMutableArray *csvFileNames=[NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *urls=[fileManager contentsOfDirectoryAtPath:[documentDirURL path] error:NULL];
    for (NSURL *url in urls) {
        //If the file name has extension .record.csv, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:@".record.csv"])
            [csvFileNames addObject:fileName];
    }
    self.csvFileNames=csvFileNames;
    
    //Register for notifications from conflict handler
    [self registerForNotificationsForConflictHandler];
}

#pragma mark - UIAlertViewDelegate protocol methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Folder Name Conflict
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Replace"]) {
        ConflictHandler *conflictHandler=self.conflictHandler;
        dispatch_queue_t conflict_handler_queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(conflict_handler_queue, ^{
            //Handle the conflict
            [conflictHandler userDidChooseToHandleFolderNameConflictWith:ConflictHandleReplace];
            
            //If there is any unprocessed records, continue
            if (conflictHandler.transientRecords.count)
                [conflictHandler processTransientRecords:conflictHandler.transientRecords 
                                                   andFolders:conflictHandler.transientFolders 
                                     withValidationMessageLog:nil];
        });
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Keep Both"]) {
        ConflictHandler *conflictHandler=self.conflictHandler;
        dispatch_queue_t conflict_handler_queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(conflict_handler_queue, ^{
            //Handle the conflict
            [conflictHandler userDidChooseToHandleFolderNameConflictWith:ConflictHandleKeepBoth];
            
            //If there is any unprocessed records, continue
            if (conflictHandler.transientRecords.count)
                [conflictHandler processTransientRecords:conflictHandler.transientRecords 
                                              andFolders:conflictHandler.transientFolders 
                                withValidationMessageLog:nil];
        });
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        [self.conflictHandler userDidChooseToHandleFolderNameConflictWith:ConflictHandleCancel];
    }
}

#pragma mark - Handle Notifications

- (void)registerForNotificationsForConflictHandler {
    //Register to hear notifications from conflict handler
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(handleFolderNameConflict:) 
                               name:GeoNotificationConflictHandlerFolderNameConflictOccurs 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(handleValidationErrors:) 
                               name:GeoNotificationConflictHandlerValidationErrorsOccur 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingDidEnd:) 
                               name:GeoNotificationConflictHandlerImportingDidEnd 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingWasCanceled:) 
                               name:GeoNotificationConflictHandlerImportingWasCanceled
                             object:nil];
}

- (void)putImportButtonBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Hide the spinner and put the import button
        NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
        int index=[toolbarItems indexOfObject:self.spinner];
        [toolbarItems removeObjectAtIndex:index];
        [toolbarItems insertObject:self.importButton atIndex:index];
        self.toolbarItems=toolbarItems.copy;
        self.spinner=nil;
    });
}

- (void)importingWasCanceled:(NSNotification *)notification {
    //Put the import button back
    [self putImportButtonBack];
    
    //Notify delegate
    [self.importDelegate importTableViewControllerDidCancelImporting:self];
}

- (void)importingDidEnd:(NSNotification *)notification {
    //Notify delegate of the completion of the importing
    [self.importDelegate importTableViewControllerDidEndImporting:self];
    
    //Put the import button back again
    [self putImportButtonBack];
}

- (void)handleFolderNameConflict:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *duplicateFolderName=self.conflictHandler.duplicateFolderName;
        NSString *alertTitle=[NSString stringWithFormat:@"Folder With Name \"%@\" already exists!",duplicateFolderName];
        NSString *message=@"";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle 
                                                      message:message 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Replace",@"Keep Both", nil];
        [alert show];
    });
}

- (void)handleValidationErrors:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo=notification.userInfo;
        NSArray *errorMessages=[userInfo objectForKey:GeoNotificationConflictHandlerValidationLogKey];
        NSString *alertTitle=@"Importing Failed!";
        NSString *message=[errorMessages componentsJoinedByString:@"\n"];;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle 
                                                      message:message 
                                                     delegate:self 
                                            cancelButtonTitle:@"Dismiss" 
                                            otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark - UITableViewDataSource protocol methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Record CSV Files";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Record Import Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSString *fileNameWithoutExtension=[[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    cell.textLabel.text=fileNameWithoutExtension;
    
    return cell;
}

#pragma mark - Target Action Handlers

- (IBAction)importPressed:(UIBarButtonItem *)sender {
    //Notify delegate of the start of the importing
    [self.importDelegate importTableViewControllerDidStartImporting:self];
    
    __weak RecordImportTVC *weakSelf=self;
        
    //Start importing in another thread
    dispatch_queue_t import_queue_t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(import_queue_t, ^{
        //Put up a spinner for the import button
        __block UIActivityIndicatorView *spinner=nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            UIBarButtonItem *spinnerBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
            [spinner startAnimating];
            weakSelf.navigationItem.rightBarButtonItem=spinnerBarButtonItem;
            
            //Save the spinner
            weakSelf.spinner=spinnerBarButtonItem;
            
            //Hide the import button and put the spinner there
            NSMutableArray *toolbarItems=self.toolbarItems.mutableCopy;
            
            int index=[toolbarItems indexOfObject:self.importButton];
            [toolbarItems removeObject:self.importButton];
            [toolbarItems insertObject:spinnerBarButtonItem atIndex:index];
            self.toolbarItems=toolbarItems.copy;
        });
        
        //Pass the selected csv files to the engine
        weakSelf.engine.handler=weakSelf.conflictHandler;
        [weakSelf.engine createRecordsFromCSVFiles:weakSelf.selectedCSVFiles];
    });
    dispatch_release(import_queue_t);
}

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.selectedCSVFiles=self.csvFileNames;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.selectedCSVFiles=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

@end
