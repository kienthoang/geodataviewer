//
//  Bedding+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Bedding+Creation.h"

@implementation Bedding (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Bedding" forKey:RECORD_TYPE];
        
    //Call super to get a record
    Bedding *record=(Bedding *)[Record recordForInfo:updatedRecordInfo.copy inManagedObjectContext:context];
                    
    //Set the formation
    //record.formation=[Formation formationWithName:[recordInfo objectForKey:RECORD_FORMATION] inManagedObjectContext:context];
            
    return record;
}

@end
