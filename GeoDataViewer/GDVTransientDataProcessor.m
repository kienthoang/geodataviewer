//
//  GDVTransientDataProcessor.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVTransientDataProcessor.h"
#import "GeoDatabaseManager.h"
#import "Group.h"
#import "Record.h"
#import "Folder.h"
#import "Formation.h"
#import "Formation_Folder.h"
#import "TransientProject.h"//Folder
#import "TransientGroup.h"
#import "TransientRecord.h"
#import "TransientFormation.h"
#import "TransientFormation_Folder.h"

@interface GDVTransientDataProcessor()

@property (nonatomic, strong) GeoDatabaseManager *database;

@end

@implementation GDVTransientDataProcessor

@synthesize delegate=_delegate;

@synthesize database=_database;


#pragma mark - getters
-(GeoDatabaseManager *) database {
    if(!_database)
        _database = [GeoDatabaseManager standardDatabaseManager];
    return _database;
}
#pragma mark - database access
-(Record *) queryDatabaseForRecordWithName:(NSString *) name {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.predicate = [NSPredicate predicateWithFormat:@"folderName=%@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
//    NSArray *results = [self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is anything returned, return it
//    return results.count>0 ? [results lastObject] : nil;
}

#pragma mark - public methods to process the data into the database
-(void) updateDatabaseWithRecords:(NSArray *)records withFolders:(NSArray *)folders withGroups:(NSArray *) groups {
    //return if no records were provided
    if(!records.count) return;
    
    //iterate through the records and save them to the database. replace if it already exists.
    for(TransientRecord *record in records) {
        Record *recordInDatabase = [self queryDatabaseForRecordWithName:record.name];
    }
    
    
}

-(void) updateDatabaseWithFormations:(NSArray *)formations withFormationFolders:(NSArray *)formationFolders {
    
}


@end
