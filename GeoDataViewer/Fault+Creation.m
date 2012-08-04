//
//  Fault+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Fault+Creation.h"

@implementation Fault (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inFolder:(Folder *)folder {
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Joint Set" forKey:RECORD_TYPE];
    
    //Call super to get a record
    Fault *record=(Fault *)[Record recordForInfo:updatedRecordInfo.copy inFolder:folder];
    
    //Set the formation
    record.formation=[Formation formationWithName:[recordInfo objectForKey:RECORD_FORMATION] inManagedObjectContext:folder.managedObjectContext];
    
    //Set the plunge and trend
    record.trend=[recordInfo objectForKey:RECORD_TREND];
    record.plunge=[recordInfo objectForKey:RECORD_PLUNGE];
    
    return record;
}

@end
