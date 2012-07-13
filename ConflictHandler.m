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

@implementation ConflictHandler

@synthesize database = _database;

#pragma mark - Handle Conflicts

- (BOOL) handleConflictsFor:(NSArray *) items
                withFolders:(NSArray *) folderNames
              errorMessages:(NSArray *) errors
{
    if (!items) {
        //cancel everything... pass errors on ?
        return NO;
    }
    else if ([[items objectAtIndex:0] isKindOfClass:[TransientRecord class]]) {
        [self handleRecordFolderNameConflicts:folderNames];
    }
    else if ([[items objectAtIndex:0] isKindOfClass:[TransientFormation class]]) {
        [self handleFormationFolderNameConflicts:folderNames];
    }
    else {
        //invalid type error
        return NO;
    }
    
    return YES;
}

#pragma mark - Handle Record Folder Name Conflicts

- (void) handleRecordFolderNameConflicts:(NSArray *) folderNames
{
    NSSet *currentRecordFolders = [self fetchRecordFolders];
    NSMutableArray *duplicateRecordFolderNames = nil;
    
    for (NSString *toAdd in folderNames) {
        if ([currentRecordFolders containsObject:toAdd]) {
            [duplicateRecordFolderNames addObject:toAdd];
        }
    }
    
    //call program... pass errors and duplicateFolderNames... get array of folder names to save and append
    NSArray *folderNamesToSave = nil;
    NSArray *databaseRecordFolders = [currentRecordFolders allObjects];
    NSArray *saveRecordFolders = [folderNamesToSave arrayByAddingObjectsFromArray:databaseRecordFolders];
    
    TransientManagedObject *managedObject = [[TransientManagedObject alloc] init];
    NSManagedObjectContext *context = [self.database managedObjectContext];
    [managedObject saveToManagedObjectContext:context completion:^(NSManagedObject *object){}];
    
}

- (NSSet *) fetchRecordFolders
{
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folder.folderName" ascending:YES]];
    NSFetchedResultsController *fetchedResults =[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSArray *fetchedRecords = fetchedResults.fetchedObjects;
    NSMutableSet *currentFolders = nil;
    
    for (Record *r in fetchedRecords) {
        [currentFolders addObject:r.folder.folderName];
    }
    
    return [currentFolders copy];
}

#pragma mark - Handle Formation Folder Name Conflicts

- (void) handleFormationFolderNameConflicts:(NSArray *) folderNames
{
    NSSet *currentFormationFolders = [self fetchFormationFolders];
    
    NSMutableArray *duplicateFormationFolderNames = nil;
    
    for (NSString *toAdd in folderNames) {
        if ([currentFormationFolders containsObject:toAdd]) {
            [duplicateFormationFolderNames addObject:toAdd];
        }
    }
    
    //call program... pass errors and duplicateFolderNames... get array of folder names to save and append
    NSArray *folderNamesToSave = nil;
    NSArray *databaseFormationFolders = [currentFormationFolders allObjects];
    NSArray *saveFormationFolders = [folderNamesToSave arrayByAddingObjectsFromArray:databaseFormationFolders];
    
    TransientManagedObject *managedObject = [[TransientManagedObject alloc] init];
    NSManagedObjectContext *context = [self.database managedObjectContext];
    [managedObject saveToManagedObjectContext:context completion:^(NSManagedObject *object){}];
}

- (NSSet *) fetchFormationFolders
{
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationFolder.folderName" ascending:YES]];
    NSFetchedResultsController *fetchedResults =[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSArray *fetchedFormations = fetchedResults.fetchedObjects;
    NSMutableSet *currentFolders = nil;
    
    for (Record *r in fetchedFormations) {
        [currentFolders addObject:r.folder.folderName];
    }
    
    return [currentFolders copy];
}

@end
