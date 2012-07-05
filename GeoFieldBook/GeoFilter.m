//
//  GeoFilter.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFilter.h"

#import "Record.h"
#import "Record+Types.h"

#import "Folder.h"

#import "GeoDatabaseManager.h"

@interface GeoFilter()

@end

@implementation GeoFilter

@synthesize selectedRecordTypes=_selectedRecordTypes;
@synthesize selectedFolderNames=_selectedFolderNames;

#pragma mark - Getters and Setters

- (NSArray *)allRecordTypes {
    return [Record allRecordTypes];
}

- (NSArray *)selectedRecordTypes {
    if (!_selectedRecordTypes)
        _selectedRecordTypes=self.allRecordTypes;
    
    return _selectedRecordTypes;
}

- (NSArray *)selectedFolderNames {
    if (!_selectedFolderNames) {
        //Get all the folders' names
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
        UIManagedDocument *sharedDatabase=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
        NSArray *results=[sharedDatabase.managedObjectContext executeFetchRequest:request error:NULL];
        NSMutableArray *selectedFolderNames=[NSMutableArray arrayWithCapacity:[results count]];
        for (Folder *folder in results)
            [selectedFolderNames addObject:folder.folderName];
        _selectedFolderNames=[selectedFolderNames copy];        
    }
    
    return _selectedFolderNames;
}

- (void)changeFolderName:(NSString *)originalName toFolderName:(NSString *)newName {
    if ([self.selectedFolderNames containsObject:originalName]) {
        NSMutableArray *selectedFolderNames=[self.selectedFolderNames mutableCopy];
        [selectedFolderNames removeObject:originalName];
        [selectedFolderNames addObject:newName];
        self.selectedFolderNames=[selectedFolderNames copy];
    }    
}

#pragma mark - Select/Deselect Record Types

- (void)userDidSelectRecordType:(NSString *)recordType {
    //Add the selected record type to the array of selected record types
    if (![self.selectedRecordTypes containsObject:recordType]) {
        NSMutableArray *selectedRecordTypes=[self.selectedRecordTypes mutableCopy];
        [selectedRecordTypes addObject:recordType];
        self.selectedRecordTypes=[selectedRecordTypes copy];
    }
}

- (void)userDidDeselectRecordType:(NSString *)recordType {
    //Remove the selected record type from the array of selected record types
    if ([self.selectedRecordTypes containsObject:recordType]) {
        NSMutableArray *selectedRecordTypes=[self.selectedRecordTypes mutableCopy];
        [selectedRecordTypes removeObject:recordType];
        self.selectedRecordTypes=[selectedRecordTypes copy];
    }
}

#pragma mark - Select/Deselect Folders

- (void)userDidSelectFolderWithName:(NSString *)folderName {
    //Add the folder name to the array of selected folder names
    if (![self.selectedFolderNames containsObject:folderName]) {
        NSMutableArray *selectedFolderNames=[self.selectedFolderNames mutableCopy];
        [selectedFolderNames addObject:folderName];
        self.selectedFolderNames=[selectedFolderNames copy];
    }    
}

- (void)userDidDeselectFolderWithName:(NSString *)folderName {
    //Remove the folder name from the array of selected folder names
    if ([self.selectedFolderNames containsObject:folderName]) {
        NSMutableArray *selectedFolderNames=[self.selectedFolderNames mutableCopy];
        [selectedFolderNames removeObject:folderName];
        self.selectedFolderNames=[selectedFolderNames copy];
    }    
}

#pragma mark - Filter Mechanisms

- (NSArray *)filterRecordCollectionByRecordType:(NSArray *)records {
    //iterate through the given records and filter out records of types that were not selected by the user
    NSMutableArray *filteredRecords=[records mutableCopy];
    for (Record *record in records) {
        if (![self.selectedRecordTypes containsObject:[record.class description]])
            [filteredRecords removeObject:record];
    }
    
    return [filteredRecords copy];
}

- (NSArray *)filterRecordCollectionByFolder:(NSArray *)records {
    //iterate through the given records and filter out records that have folder name not included in the array of selected folder names
    NSMutableArray *filteredRecords=[records mutableCopy];
    for (Record *record in records) {
        if (![self.selectedFolderNames containsObject:record.folder.folderName])
            [filteredRecords removeObject:record];
    }
    
    return [filteredRecords copy];
}

@end
