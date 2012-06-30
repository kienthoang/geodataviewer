//
//  Record+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Creation.h"
#import "Record+Types.h"

@implementation Record (Creation)

+ (Record *)recordForRecordType:(NSString *)recordType 
                  andFolderName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Record *record=nil;
    
    //If the record type is known, proceed
    if ([[Record allRecordTypes] containsObject:recordType]) {
        //Query for the folder name
        NSFetchRequest *folderRequest=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
        folderRequest.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
        folderRequest.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
        NSArray *results=[context executeFetchRequest:folderRequest error:NULL];
        
        //If there is a folder with that name, proceed
        Folder *folder=[results lastObject];
        if (folder) {
            //Handle different record types
            if ([recordType isEqualToString:@"Contact"]) {
                record=[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
            } else if ([recordType isEqualToString:@"Bedding"]) {
                record=[NSEntityDescription insertNewObjectForEntityForName:@"Bedding" inManagedObjectContext:context];
            } else if ([recordType isEqualToString:@"Joint Set"]) {
                record=[NSEntityDescription insertNewObjectForEntityForName:@"JointSet" inManagedObjectContext:context];
            } else if ([recordType isEqualToString:@"Other"]) {
                record=[NSEntityDescription insertNewObjectForEntityForName:@"Other" inManagedObjectContext:context];
            } else if ([recordType isEqualToString:@"Fault"]) {
                record=[NSEntityDescription insertNewObjectForEntityForName:@"Fault" inManagedObjectContext:context];
            }
            
            //Set the name of the record
            record.name=@"";
            record.folder=folder;
            record.image=nil;
        }
    }
    
    return record;
}

@end
