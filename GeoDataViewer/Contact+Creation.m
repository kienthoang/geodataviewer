//
//  Contact+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Contact+Creation.h"

@implementation Contact (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inFolder:(Folder *)folder {
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Joint Set" forKey:RECORD_TYPE];
    
    //Call super to get a record
    Contact *record=(Contact *)[Record recordForInfo:updatedRecordInfo.copy inFolder:folder];
    
    //Set the upper and lower formations
    record.upperFormation=[Formation formationWithName:[recordInfo objectForKey:RECORD_UPPER_FORMATION] inManagedObjectContext:folder.managedObjectContext];
    record.lowerFormation=[Formation formationWithName:[recordInfo objectForKey:RECORD_LOWER_FORMATION] inManagedObjectContext:folder.managedObjectContext];
    
    return record;
}

@end
