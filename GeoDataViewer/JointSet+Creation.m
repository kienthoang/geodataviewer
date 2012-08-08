//
//  JointSet+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "JointSet+Creation.h"

@implementation JointSet (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context {    
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Joint Set" forKey:RECORD_TYPE];
        
    //Call super to get a record
    JointSet *record=(JointSet *)[Record recordForInfo:updatedRecordInfo.copy inManagedObjectContext:context];
        
    //Set the formation
    record.formation=[Formation formationWithName:[recordInfo objectForKey:RECORD_FORMATION] inManagedObjectContext:context];
        
    return record;
}

@end
