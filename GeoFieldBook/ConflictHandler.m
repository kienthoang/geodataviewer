//
//  ConflictHandler.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ConflictHandler.h"

#import "TransientRecord.h"
#import "TransientProject.h"
#import "TransientFormation.h"
#import "TransientFormation_Folder.h"

#import "Record.h"
#import "Folder.h"
#import "Formation.h"
#import "Formation_Folder.h"
#import "Image.h"

@interface ConflictHandler() <UIAlertViewDelegate>

@property (nonatomic,strong) Folder *folderInConflict;
@property (nonatomic,strong) TransientProject *transientFolderInConflict;
@property (nonatomic,strong) Formation_Folder *formationFolderInConflict;
@property (nonatomic,strong) TransientFormation_Folder *transientFormationFolderInConflict;

@end

@implementation ConflictHandler

@synthesize database=_database;

@synthesize transientRecords=_transientRecords;
@synthesize transientFolders=_transientFolders;
@synthesize transientFormations=_transientFormations;
@synthesize transientFormationFolders=_transientFormationFolders;

@synthesize folderInConflict=_folderInConflict;
@synthesize formationFolderInConflict=_formationFolderInConflict;
@synthesize transientFolderInConflict=_transientFolderInConflict;
@synthesize transientFormationFolderInConflict=_transientFormationFolderInConflict;

@synthesize duplicateFolderName=_duplicateFolderName;
@synthesize duplicateFormationFolderName=_duplicateFormationFolderName;

#pragma mark - Getters and Setters

-(NSArray *)transientFormationFolders {
    if(!_transientFormationFolders) _transientFormationFolders = [NSArray array];
    return _transientFormationFolders;
}

-(NSArray *)transientFormations {
    if(!_transientFormations) _transientFormations = [NSArray array];
    return _transientFormations;
}

- (void)setTransientRecords:(NSArray *)transientRecords {
    _transientRecords=transientRecords;
        
    //Post a notification
    if (!self.transientRecords.count)
        [self postNotificationWithName:GeoNotificationConflictHandlerImportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

- (void)setTransientFormations:(NSArray *)transientFormations {
    _transientFormations=transientFormations;
    
    //Post a notification
    if (!self.transientFormations.count)
        [self postNotificationWithName:GeoNotificationConflictHandlerImportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

#pragma mark - Process Transient Data

- (void)processTransientRecords:(NSArray *)records 
                     andFolders:(NSArray *)folders 
       withValidationMessageLog:(NSArray *)validationLog
{
    //If the given array of transient records is not nil (i.e. no validation errors happened), process them
    if (records.count) {
        //Iterate through the given folders and check if there is any folder name duplicate
        NSMutableArray *unprocessedFolders=[folders mutableCopy];
        NSMutableArray *processedFolders=[NSMutableArray array];
        for (int index=0;index<folders.count;index++) {
            //Save the folder name if there is a duplicate
            TransientProject *transientFolder=[folders objectAtIndex:index];
            [unprocessedFolders removeObject:transientFolder];
            Folder *duplicateFolder=[self queryDatabaseForFolderWithName:transientFolder.folderName];
            if (duplicateFolder) {
                //Save the duplicate folder name
                self.duplicateFolderName=duplicateFolder.folderName;
                
                //Save the "real" folder that is in conflict
                self.folderInConflict=duplicateFolder;
                
                //Save the transient folder in conflict
                self.transientFolderInConflict=transientFolder;
                                
                //Break to give the user duplicate alerts one-by-one
                break;
            } 
            
            //Else add the folder to the list of processed folders
            [processedFolders addObject:transientFolder];
        }
        
        //Save the processed folders if any (there is no duplicate in these)
        NSArray *unprocessedRecords=records;
        if (processedFolders.count) {
            //Save the process folders
            [self saveTransientFolders:processedFolders];
            
            //Save the associated records
            unprocessedRecords=[self saveTransientRecordsInRecordList:records withFolderNames:processedFolders];
        }
        
        //Save the unprocessed transient folders and records
        self.transientRecords=unprocessedRecords;
        self.transientFolders=[unprocessedFolders copy];
                
        //If the duplicate folder name is not nil, save the unprocessed transient records and folders and notify the program
        if (self.duplicateFolderName) {            
            //Notify the program
            [self postNotificationWithName:GeoNotificationConflictHandlerFolderNameConflictOccurs withUserInfo:[NSDictionary dictionary]];
        }
    }
    
    //Else (some validation errors happened), cancel everything and notify the program
    else {
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:validationLog,GeoNotificationConflictHandlerValidationLogKey, nil];
        [self postNotificationWithName:GeoNotificationConflictHandlerValidationErrorsOccur withUserInfo:userInfo];
    }
}

- (void)processTransientFormations:(NSArray *)formations 
               andFormationFolders:(NSArray *)folders 
          withValidationMessageLog:(NSArray *)validationLog 
{
    //If the given array of transient formations is not nil (i.e. no validation errors happened), process them
    if (formations) {
        //Iterate through the given formation folders and check if there is any folder name duplicate
        NSMutableArray *unprocessedFolders=[folders mutableCopy];
        NSMutableArray *processedFolders=[NSMutableArray array];
        for (int index=0;index<folders.count;index++) {
            //Save the folder name if there is a duplicate
            TransientFormation_Folder *transientFolder=[folders objectAtIndex:index];
            [unprocessedFolders removeObject:transientFolder];
            NSLog(@"TransientFormationFolderName: %@", transientFolder.folderName);
            Formation_Folder *duplicateFormationFolder=[self queryDatabaseForFormationFolderWithName:transientFolder.folderName];
            if (duplicateFormationFolder) {
                //Save the duplicate folder name
                self.duplicateFormationFolderName=duplicateFormationFolder.folderName;
                
                //Save the "real" folder that is in conflict
                self.formationFolderInConflict=duplicateFormationFolder;
                
                //Save the transient folder in conflict
                self.transientFormationFolderInConflict=transientFolder;
                
                //Break to give the user duplicate alerts one-by-one
                break;
            } 
            
            //Else add the folder to the list of processed folders
            [processedFolders addObject:transientFolder];
        }
        
        //Save the processed folders if any (there is no duplicate in these)
        NSArray *unprocessedFormations=formations;
        if (processedFolders.count) {
            //Save the process folders
            [self saveTransientFormationFolders:processedFolders];
            
            //Save the associated records
            unprocessedFormations=[self saveTransientFormationsInFormationList:formations withFormationFolderNames:processedFolders];
        }
        
        //Save the unprocessed transient folders and records
           
        self.transientFormations=unprocessedFormations;
        self.transientFormationFolders=[unprocessedFolders copy];
        
        //If the duplicate folder name is not nil, save the unprocessed transient formations and folders and notify the program
        if (self.duplicateFormationFolderName) {
            //Notify the program
            [self postNotificationWithName:GeoNotificationConflictHandlerFormationFolderNameConflictOccurs withUserInfo:[NSDictionary dictionary]];
        }
    }
    
    //Else (some validation errors happened), cancel everything and notify the program
    else {
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:validationLog,GeoNotificationConflictHandlerValidationLogKey, nil];
        [self postNotificationWithName:GeoNotificationConflictHandlerValidationErrorsOccur withUserInfo:userInfo];
    }
}

#pragma mark - Handle Conflicts

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

- (void)userDidChooseToHandleFolderNameConflictWith:(HandleOption)handleOption {
    NSArray *transientFolders=nil;
    
    //If user chose "Replace"
    if (handleOption==ConflictHandleReplace) {
        //Delete the folder in conflict
        [self.database.managedObjectContext deleteObject:self.folderInConflict];
        
        //Save the transient folder in conflict
        transientFolders=[NSArray arrayWithObject:self.transientFolderInConflict];
        [self saveTransientFolders:transientFolders];
        
        //Save the records associated with the transient folder
        self.transientRecords=[self saveTransientRecordsInRecordList:self.transientRecords withFolderNames:transientFolders];
    }
    
    //If user chose "Keep Both"
    else if (handleOption==ConflictHandleKeepBoth) {
        //Rename
        [self renameFolder:self.folderInConflict andCorrespondingTransientFolder:self.transientFolderInConflict];
        
        //Put the transient folder in conflict back for processing
        NSMutableArray *transientFolders=self.transientFolders.mutableCopy;
        [transientFolders insertObject:self.transientFolderInConflict atIndex:0];
        self.transientFolders=transientFolders.copy;        
    }
    
    //If user chose "Cancel"
    else if (handleOption==ConflictHandleCancel) {
        //Post a notification to indicate that the importing is canceled
        [self postNotificationWithName:GeoNotificationConflictHandlerImportingWasCanceled withUserInfo:[NSDictionary dictionary]];
        
        return;
    }
    
    //Unset the folders in conflict
    self.duplicateFolderName=nil;
    self.folderInConflict=nil;
    self.transientFolderInConflict=nil;
    
    //Save changes to database
    [self saveDatabase:self.database];
}

- (void)userDidChooseToHandleFormationFolderNameConflictWith:(HandleOption)handleOption {
    NSArray *transientFolders=nil;
        
    //If user chose "Replace"
    if (handleOption==ConflictHandleReplace) {
        //Delete the folder in conflict
        [self.database.managedObjectContext deleteObject:self.formationFolderInConflict];
        
        //Save the transient folder in conflict
        transientFolders=[NSArray arrayWithObject:self.transientFormationFolderInConflict];
        [self saveTransientFormationFolders:transientFolders];
    }
    
    //If user chose "Keep Both"
    else if (handleOption==ConflictHandleKeepBoth) {
        //Rename
        [self renameFormationFolder:self.formationFolderInConflict andCorrespondingTransientFormationFolder:self.transientFormationFolderInConflict];
        
        //Put the transient formation folder in conflict back for processing
        NSMutableArray *transientFormationFolders=self.transientFormationFolders.mutableCopy;
        [transientFormationFolders insertObject:self.transientFormationFolderInConflict atIndex:0];
        self.transientFormationFolders=transientFormationFolders.copy;
    } 
    
    //If user chose "Cancel"
    else if (handleOption==ConflictHandleCancel) {
        //Post a notification to indicate that the importing is canceled
        [self postNotificationWithName:GeoNotificationConflictHandlerImportingWasCanceled withUserInfo:[NSDictionary dictionary]];
        
        return;
    }
    
    //Save the formations associated with the transient folder
    self.transientFormations=[self saveTransientFormationsInFormationList:self.transientFormations withFormationFolderNames:transientFolders];
    
    //Unset the folders in conflict
    self.formationFolderInConflict=nil;
    self.transientFormationFolderInConflict=nil;
    self.duplicateFormationFolderName=nil;
    
    //Save changes to database
    [self saveDatabase:self.database];
}

#pragma mark - Renaming Schemes

- (NSString *)renameFolder:(Folder *)folder andCorrespondingTransientFolder:(TransientProject *)transientFolder {
    NSRegularExpression *renameRegex=[[NSRegularExpression alloc] initWithPattern:@"(.+)\\s?\\((\\d*)\\)$" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
    
    //If there is already a renaming suffix number in the name of the folders in conflict, increment that number for the trasient folder
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    NSTextCheckingResult *match=[renameRegex firstMatchInString:folder.folderName options:0 range:NSMakeRange(0, folder.folderName.length)];
    NSString *newTransientFolderName=transientFolder.folderName;
    if (match) {
        NSString *numberSuffixString=[renameRegex stringByReplacingMatchesInString:folder.folderName 
                                                                     options:0 
                                                                       range:NSMakeRange(0, folder.folderName.length) 
                                                                withTemplate:@"$2"];
        int numberSuffix=[numberFormatter numberFromString:numberSuffixString].intValue+1;
        newTransientFolderName=[renameRegex stringByReplacingMatchesInString:folder.folderName 
                                                                     options:0 
                                                                       range:NSMakeRange(0, folder.folderName.length) 
                                                                withTemplate:@"$1"];
        newTransientFolderName=[newTransientFolderName stringByAppendingFormat:@"(%d)",numberSuffix];
        
    } else {
        newTransientFolderName=[newTransientFolderName stringByAppendingString:@" (1)"];
    }
    
    transientFolder.folderName=newTransientFolderName;
    return newTransientFolderName;
}

- (NSString *)renameFormationFolder:(Formation_Folder *)folder andCorrespondingTransientFormationFolder:(TransientFormation_Folder *)transientFolder {
    NSRegularExpression *renameRegex=[[NSRegularExpression alloc] initWithPattern:@"(.+)\\s?\\((\\d*)\\)$" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
    
    //If there is already a renaming suffix number in the name of the folders in conflict, increment that number for the trasient folder
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    NSTextCheckingResult *match=[renameRegex firstMatchInString:folder.folderName options:0 range:NSMakeRange(0, folder.folderName.length)];
    NSString *newTransientFolderName=transientFolder.folderName;
    if (match) {
        NSString *numberSuffixString=[renameRegex stringByReplacingMatchesInString:folder.folderName 
                                                                           options:0 
                                                                             range:NSMakeRange(0, folder.folderName.length) 
                                                                      withTemplate:@"$2"];
        int numberSuffix=[numberFormatter numberFromString:numberSuffixString].intValue+1;
        newTransientFolderName=[renameRegex stringByReplacingMatchesInString:folder.folderName 
                                                                     options:0 
                                                                       range:NSMakeRange(0, folder.folderName.length) 
                                                                withTemplate:@"$1"];
        newTransientFolderName=[newTransientFolderName stringByAppendingFormat:@"(%d)",numberSuffix];
        
    } else
        newTransientFolderName=[newTransientFolderName stringByAppendingString:@" (1)"];
    
    transientFolder.folderName=newTransientFolderName;
    return newTransientFolderName;
}

#pragma mark - Database Operations

- (void)saveDatabase:(UIManagedDocument *)database {
    [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //Handle errors
        }
    }];
}

- (Folder *)queryDatabaseForFolderWithName:(NSString *)folderName {
    //Query the database for a folder with the given named
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
        
    //If there is a result return it
    return results.count>0 ? [results lastObject] : nil;
}

- (Formation_Folder *)queryDatabaseForFormationFolderWithName:(NSString *)folderName {
    //Query the database for a formation folder with the given named
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //If there is a result return it
    return results.count>0 ? [results lastObject] : nil;
}

- (BOOL)formationFolderExistsInDatabase:(NSString *)folderName {
    //Query the database for a folder with the given named
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //If there is a result return YES, else NO
    return results.count>0;
}

#pragma mark - Saving Operations

//Save the records in the record list that have given folder name and return the rest
- (NSArray *)saveTransientRecordsInRecordList:(NSArray *)records withFolderNames:(NSArray *)folders
{
    NSMutableArray *unsavedRecords=[records mutableCopy];
    for (TransientRecord *transientRecord in records) {
        //Save the record if it has one of the given folder names
        if ([folders containsObject:transientRecord.folder]) {
            [self.database.managedObjectContext performBlock:^{
                //Save the record
                [transientRecord saveToManagedObjectContext:self.database.managedObjectContext completion:^(NSManagedObject *savedManagedObject){
                }];
            }];
            
            //Mark it as saved
            [unsavedRecords removeObject:transientRecord];
        }
    }
    
    //Save database
    [self saveDatabase:self.database];
    
    return unsavedRecords.copy;
}

- (void)saveTransientFolders:(NSArray *)folders;
{
    for (TransientProject *transientFolder in folders) {
        //Save the folder (in the approrpiate thread since UIManagedDocument is not thread-safe)
        [self.database.managedObjectContext performBlock:^{
            [transientFolder saveToManagedObjectContext:self.database.managedObjectContext completion:^(NSManagedObject *savedManagedObject){
                
            }];
        }];
    }    
    
    //Save database
    [self saveDatabase:self.database];
}

//Save the formations in the formation list that have given formation folder name and return the rest
- (NSArray *)saveTransientFormationsInFormationList:(NSArray *)formations withFormationFolderNames:(NSArray *)folderNames
{
    NSMutableArray *unsavedFormations=[formations mutableCopy];
    for (TransientFormation *transientFormation in formations) {
        //Save the formation if it has one of the given folder names
        if ([folderNames containsObject:transientFormation.formationFolder]) {
            [self.database.managedObjectContext performBlock:^{
                //Save the formation
                [transientFormation saveToManagedObjectContext:self.database.managedObjectContext completion:^(NSManagedObject *savedManagedObject){
                }];
            }];
            
            //Mark it as saved
            [unsavedFormations removeObject:transientFormation];
        }
    }
    
    //Save database
    [self saveDatabase:self.database];
    
    return unsavedFormations.copy;
}

- (void)saveTransientFormationFolders:(NSArray *)folders;
{
    for (TransientFormation_Folder *transientFolder in folders) {
        //Save the folder (in the approrpiate thread since UIManagedDocument is not thread-safe)
        [self.database.managedObjectContext performBlock:^{
            [transientFolder saveToManagedObjectContext:self.database.managedObjectContext completion:^(NSManagedObject *savedManagedObject){}];
        }];
    }    
    
    //Save database
    [self saveDatabase:self.database];
}

@end
