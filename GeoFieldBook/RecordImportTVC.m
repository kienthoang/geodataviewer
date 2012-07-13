//
//  RecordImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordImportTVC.h"
#import "IEConflictHandlerNotificationNames.h"

@interface RecordImportTVC() <UIAlertViewDelegate>

@end

@implementation RecordImportTVC

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
        [self.conflictHandler processTransientRecords:self.conflictHandler.transientRecords 
                                           andFolders:self.conflictHandler.transientFolders 
                             withValidationMessageLog:nil];
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
    //Start importing in another thread
    dispatch_queue_t import_queue_t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(import_queue_t, ^{
        //Pass the selected csv files to the engine
        self.engine.handler=self.conflictHandler;
        [self.engine createRecordsFromCSVFiles:self.selectedCSVFiles];
    });
    dispatch_release(import_queue_t);
}

@end
