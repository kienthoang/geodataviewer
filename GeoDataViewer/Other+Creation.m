//
//  Other+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Other+Creation.h"

@implementation Other (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Other" forKey:RECORD_TYPE];
    
    //Call super to get a record
    Other *record=(Other *)[Record recordForInfo:updatedRecordInfo.copy inManagedObjectContext:context];
    
    return record;
}

@end
