//
//  ConflictHandler.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ConflictHandler.h"
#import "TransientRecord.h"
#import "TransientFormation.h"
#import <CoreData/CoreData.h>
#import "Record.h"
#import "Folder.h"
#import "Formation.h"
#import "Formation_Folder.h"
#import "Image.h"

@interface ConflictHandler () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *thingsToAdd;
@property (nonatomic, strong) NSMutableArray *foldersToAdd;

@end

@implementation ConflictHandler

@synthesize database=_database;
@synthesize thingsToAdd=_thingsToAdd;
@synthesize foldersToAdd = _foldersToAdd;

#pragma mark - Handle Conflicts

- (BOOL) handleConflictsForArray:(NSArray *)items
{
    self.thingsToAdd=nil;
    self.foldersToAdd=nil;
    
    if ([[items objectAtIndex:0] isKindOfClass:[TransientRecord class]]) {
        [self handleConflictsForRecords:items];
    }
    else if ([[items objectAtIndex:0] isKindOfClass:[TransientFormation class]]) {
        [self handleConflictsForFormations:items];
    }
    else {
        //invalid type in array
    }
    return YES;
}

- (void) handleConflictsForRecords:(NSArray *) transientRecords
{
    //fetch records from database
    NSDictionary *recordsByFolder = [self fetchRecordsFromDatabase];
    
    //if duplicate name in records ask user: duplicate, cancel
    NSArray *duplicateRecordNames = [self findDuplicateRecordsInArray:transientRecords andDictionary:recordsByFolder];
    
    if ([duplicateRecordNames count] > 0) {
        //alert user of duplicates and get response one by one
        for (TransientRecord *duplicate in duplicateRecordNames) {
            [self.thingsToAdd addObject:duplicate];
            UIAlertView *duplicateRecordAlert = [self duplicateRecordAlert:duplicate];
            [duplicateRecordAlert show];
        }
    }
    
    //if any folders do not exist, create them
    if (self.foldersToAdd) {
        for (Folder *folder in self.foldersToAdd) {
            //create and add it to the database
        }
    }
    
    //convert transientrecords to records
    [self.thingsToAdd addObjectsFromArray:transientRecords];
    self.thingsToAdd = [[self convertToRecords:self.thingsToAdd] copy];//all records to add to the database
    
    //add records to the database
    
    //NSManagedObjectContext *context = [self.database managedObjectContext];
    //[context save:nil];
    
    //update database
    //save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //error alert
            [self errorSavingToDatabaseAlert];
            NSLog(@"database not saved...");
        }
    }];
    
    NSDictionary *testDictionary = [self fetchRecordsFromDatabase];
    for (Record *r in [testDictionary allValues]) {
        NSLog(@"Record Names: %@", r.name);
    }
}

- (void) handleConflictsForFormations:(NSArray *) transientFormations
{
    //fetch formations from database
    NSDictionary *formationsByFolder = [self fetchFormationsFromDatabase];
    
    //if duplicate name in records ask user: duplicate, cancel
    NSArray *duplicateFormationNames = [self findDuplicateFormationsInArray:transientFormations andDictionary:formationsByFolder];
    
    if ([duplicateFormationNames count] > 0) {
        //alert user of duplicates and get response
        for (TransientFormation *duplicate in duplicateFormationNames) {
            [self.thingsToAdd addObject:duplicate];
            UIAlertView *duplicateFormationAlert = [self duplicateFormationAlert:duplicate];
            [duplicateFormationAlert show];
        }
    }
    
    //if any folders do not exist, create them
    if (self.foldersToAdd) {
        for (Folder *folder in self.foldersToAdd) {
            //add to database
        }
    }
    
    //convert transientformations to formations
    [self.thingsToAdd addObjectsFromArray:transientFormations];
    self.thingsToAdd = [[self convertToFormations:self.thingsToAdd] copy];//all formations to add to the database
    
    //add formations to the database
    
    //NSManagedObjectContext *context = [self.database managedObjectContext];
    //[context save:nil];
    
    //update database
    //save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            //error alert
            [self errorSavingToDatabaseAlert];
            NSLog(@"database not saved...");
        }
    }];
    
    NSDictionary *testDictionary = [self fetchFormationsFromDatabase];
    for (Formation *r in [testDictionary allValues]) {
        NSLog(@"Formation Names: %@", r.formationName);
    }
    
}

#pragma mark - Convert Transient to Regular

- (NSArray *)convertToFormations:(NSArray *) transientFormations
{
    NSMutableArray *formations;
    
    for (TransientFormation *f in transientFormations) {
        Formation *newFormation;
        newFormation.formationName=f.formationName;
        newFormation.formationSortNumber=f.formationSortNumber;
        newFormation.beddings=f.beddings;
        newFormation.faults=f.faults;
        newFormation.joinSets=f.joinSets;
        newFormation.lowerContacts=f.lowerContacts;
        newFormation.upperContacts=f.upperContacts;
        
        Formation_Folder *newFormationFolder;
        newFormationFolder.folderName=f.formationFolder.folderName;
        newFormationFolder.formations=f.formationFolder.formations;
        newFormationFolder.folders=f.formationFolder.folders;
        
        newFormation.formationFolder=newFormationFolder;
    }
    
    return formations;
}

- (Folder *)convertFolder:(TransientProject *) old
{
    Folder *newFolder;
    
    newFolder.folderID=old.folderID;
    newFolder.folderName=old.name;
    newFolder.folderDescription=old.folderDescription;
    
    Formation_Folder *formationFolder;
    formationFolder.folderName=old.formationFolder.folderName;
    formationFolder.formations=old.formationFolder.formations;
    formationFolder.folders=old.formationFolder.folders;
    newFolder.formationFolder=formationFolder;
    
    newFolder.records=[[NSSet alloc] initWithArray:old.records];//array to set
    
    return newFolder;
}

- (Image *)convertImage:(TransientImage *) old
{
    Image *newImage;
    
    newImage.imageData=old.imageData;
    newImage.imageHash=old.imageHash;
    newImage.whoUses=old.whoUses;
    
    return newImage;
}

- (NSArray *)convertToRecords:(NSArray *) transientRecords
{
    NSMutableArray *records;
    
    for (TransientRecord *tr in transientRecords) {
        Record *newRecord;
        newRecord.date=tr.date;
        newRecord.dip=tr.dip;
        newRecord.dipDirection=tr.dipDirection;
        newRecord.fieldOservations=tr.fieldOservations;
        //newRecord.idOnServer=tr.idOnServer;
        //newRecord.imageHashData=tr.imageHashData;
        newRecord.latitude=tr.latitude;
        newRecord.longitude=tr.longitude;
        newRecord.name=tr.name;
        newRecord.strike=tr.strike;
        
        newRecord.folder=[self convertFolder:tr.folder];
        
        newRecord.image=[self convertImage:tr.image];
    }
    
    return records;
}

#pragma mark - Find Duplicates

-(NSArray *)findDuplicateRecordsInArray:(NSArray *) transientRecords andDictionary:(NSDictionary *) databaseRecords
{
    NSMutableArray *duplicateRecordNames;
    
    //filter by folder name then search for record names... databaseRecords is a 2d array
    for (TransientRecord *r in transientRecords) {
        
        //find array with folder name or add folder as folder name to be added
        NSArray *currentFolder = [databaseRecords objectForKey:r.folder.name];
        if (currentFolder) {
            
            //check for duplicate records
            BOOL notFound=YES;
            int i=0;
            while (notFound && i < [currentFolder count])
            {
                Record *record = [currentFolder objectAtIndex:i];
                if ([record.name isEqualToString:r.name]) {
                    [duplicateRecordNames addObject:r.name];
                    notFound=NO;
                }
                i++;
            }
        }
        else {
            
            //add to new folder names
            Folder *newFolder=[self convertFolder:r.folder];
            [self.foldersToAdd addObject:newFolder];
        }
    }
    
    return duplicateRecordNames;
}

- (NSArray *) findDuplicateFormationsInArray:(NSArray *)transientFormations andDictionary:(NSDictionary *) databaseFormations
{
    NSMutableArray *duplicateFormationNames;
    
    //filter by folder name then search for record names... databaseRecords is a 2d array
    for (TransientFormation *r in transientFormations) {
        
        //find array with folder name or add folder as folder name to be added
        NSArray *currentFolder = [databaseFormations objectForKey:r.formationFolder.folderName];
        if (currentFolder) {
            
            //check for duplicate records
            BOOL notFound=YES;
            int i=0;
            while (notFound && i < [currentFolder count])
            {
                Formation *formation = [currentFolder objectAtIndex:i];
                if ([formation.formationName isEqualToString:r.formationName]) {
                    [duplicateFormationNames addObject:r.formationName];
                    notFound=NO;
                }
                i++;
            }
        }
        else {
            
            //add to new folder names
            Formation_Folder *newFolder;
            
            newFolder.folderName=r.formationFolder.folderName;
            newFolder.formations=r.formationFolder.formations;
            newFolder.folders=r.formationFolder.folders;
            
            [self.foldersToAdd addObject:newFolder];
        }
    }
    
    return duplicateFormationNames;
}

#pragma mark - Fetch Data From Database

- (NSDictionary *)fetchRecordsFromDatabase
{
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folder.folderName" ascending:YES]];
    NSFetchedResultsController *fetchedResults =[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    //make 2d array based on folder names...
    NSArray *fetchedRecords = fetchedResults.fetchedObjects;
    NSMutableArray *mutableFetchedRecords;
    NSMutableDictionary *recordsByFolder;
    [mutableFetchedRecords addObject:[fetchedRecords objectAtIndex:0]];
    for (int i = 1; i < [fetchedRecords count] ; i++) {
        if ([[fetchedRecords objectAtIndex:i] isKindOfClass:[Record class]]) {
            if ([((Record *)[fetchedRecords objectAtIndex:i]).folder.folderName isEqualToString: ((Record *)[mutableFetchedRecords objectAtIndex:(i-1)]).folder.folderName]) {
                [mutableFetchedRecords addObject:[fetchedRecords objectAtIndex:i]];
            }
            else {
                [recordsByFolder setValue:mutableFetchedRecords forKey:((Record*)[mutableFetchedRecords objectAtIndex:0]).folder.folderName];
                [mutableFetchedRecords removeAllObjects];
            }
        }
    }
    
    return recordsByFolder;
}

- (NSDictionary *) fetchFormationsFromDatabase
{
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationFolder.folderName" ascending:YES]];
    NSFetchedResultsController *fetchedResults =[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    //make 2d array based on folder names...
    NSArray *fetchedFormations = fetchedResults.fetchedObjects;
    NSMutableArray *mutableFetchedFormations;
    NSMutableDictionary *formationsByFolder;
    [mutableFetchedFormations addObject:[fetchedFormations objectAtIndex:0]];
    for (int i = 1; i < [fetchedFormations count] ; i++) {
        if ([[fetchedFormations objectAtIndex:i] isKindOfClass:[Record class]]) {
            if ([((Record *)[fetchedFormations objectAtIndex:i]).folder.folderName isEqualToString: ((Record *)[mutableFetchedFormations objectAtIndex:(i-1)]).folder.folderName]) {
                [mutableFetchedFormations addObject:[fetchedFormations objectAtIndex:i]];
            }
            else {
                [formationsByFolder setValue:mutableFetchedFormations forKey:((Record*)[mutableFetchedFormations objectAtIndex:0]).folder.folderName];
                [mutableFetchedFormations removeAllObjects];
            }
        }
    }
    
    return formationsByFolder;
}

#pragma  mark - Alert Views

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Duplicate"]) {
        //save with an appended number
        
        //[self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){}];
    }
}

- (void) alertViewCancel:(UIAlertView *)alertView
{
    //
    [self.thingsToAdd removeLastObject];
}

- (UIAlertView *) duplicateRecordAlert:(TransientRecord *) record
{
    UIAlertView *duplicateRecordAlert = [[UIAlertView alloc] initWithTitle:@"Duplicate Record" message:[NSString stringWithFormat:@"The record name %@ is a duplicate. Would you like to save another copy?", record.name] delegate:self cancelButtonTitle:@"Don't Save" otherButtonTitles:@"Save Duplicate", nil];
    
    return duplicateRecordAlert;
}

- (UIAlertView *) duplicateFormationAlert:(TransientFormation *) formation
{
    UIAlertView *duplicateFormationsAlert = [[UIAlertView alloc] initWithTitle:@"Duplicate Formation" message:[NSString stringWithFormat:@"The formation name %@ is a duplicate. Would you like to save another copy?", formation.formationName] delegate:self cancelButtonTitle:@"Don't Save" otherButtonTitles:@"Save Duplicate", nil];
    
    return duplicateFormationsAlert;
}

- (void) errorSavingToDatabaseAlert
{
    UIAlertView *saveFailAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error saving data to the database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [saveFailAlert show];
}

#pragma mark - Save the new Database

- (void) saveRecords:(NSArray *) records
{
    
}

@end
