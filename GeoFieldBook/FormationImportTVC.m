//
//  FormationImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationImportTVC.h"

@interface FormationImportTVC ()

@property (nonatomic,strong) UIActivityIndicatorView *spinner;

@end

@implementation FormationImportTVC

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
        //If the file name has extension .formation.csv, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:@".formation.csv"]) {
            [csvFileNames addObject:fileName];
        }
    }
    self.csvFileNames=csvFileNames;
    
    //Register to hear notifications from the conflict handler
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
            [conflictHandler userDidChooseToHandleFormationFolderNameConflictWith:ConflictHandleReplace];
            
            //If there is any unprocessed formations, continue
            if (conflictHandler.transientFormations.count)
                [conflictHandler processTransientFormations:conflictHandler.transientFormations 
                                        andFormationFolders:conflictHandler.transientFormationFolders 
                                   withValidationMessageLog:nil];
        });
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Keep Both"]) {
        ConflictHandler *conflictHandler=self.conflictHandler;
        dispatch_queue_t conflict_handler_queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(conflict_handler_queue, ^{
            //Handle the conflict
            [conflictHandler userDidChooseToHandleFormationFolderNameConflictWith:ConflictHandleKeepBoth];
            
            //If there is any unprocessed records, continue
            if (conflictHandler.transientFormations.count)
                [conflictHandler processTransientFormations:conflictHandler.transientFormations 
                                        andFormationFolders:conflictHandler.transientFormationFolders 
                                   withValidationMessageLog:nil];
        });
    }
}

#pragma mark - Handle Notifications

- (void)importingDidEnd:(NSNotification *)notification {
    //Notify delegate of the completion of the importing
    [self.importDelegate importTableViewControllerDidEndImporting:self];
        
    //Put the import button back again
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        self.spinner=nil;
        self.navigationItem.rightBarButtonItem=self.importButton;
    });
}

- (void)registerForNotificationsForConflictHandler {
    //Register to hear notifications from conflict handler
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(handleFolderNameConflict:) 
                               name:GeoNotificationConflictHandlerFormationFolderNameConflictOccurs 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(handleValidationErrors:) 
                               name:GeoNotificationConflictHandlerValidationErrorsOccur 
                             object:nil];
    [notificationCenter addObserver:self 
                           selector:@selector(importingDidEnd:) 
                               name:GeoNotificationConflictHandlerImportingDidEnd 
                             object:nil];
}

- (void)handleFolderNameConflict:(NSNotification *)notification {
    //Put up an alert in the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *duplicateFormationFolderName=self.conflictHandler.duplicateFormationFolderName;
        NSString *alertTitle=[NSString stringWithFormat:@"Formation Folder With Name \"%@\" already exists!",duplicateFormationFolderName];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle 
                                                      message:nil 
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
    return @"Formation CSV Files";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Import Cell";
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
    
    __weak FormationImportTVC *weakSelf=self;
    
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
        });
        
        //Pass the selected csv files to the engine
        self.engine.handler=self.conflictHandler;
        [self.engine createFormationsFromCSVFiles:self.selectedCSVFiles];
        
        //Save the spinner
        self.spinner=spinner;
    });
    dispatch_release(import_queue_t);
}

@end
