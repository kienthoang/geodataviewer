//
//  Fault+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Fault+Creation.h"

@implementation Fault (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Add the record type to the info dictionary
    NSMutableDictionary *updatedRecordInfo=recordInfo.mutableCopy;
    [updatedRecordInfo setObject:@"Fault" forKey:RECORD_TYPE];
        
    //Call super to get a record
    Fault *record=(Fault *)[Record recordForInfo:updatedRecordInfo.copy inManagedObjectContext:context];
            
    //Set the formation
    //record.formation=[Formation formationWithName:[recordInfo objectForKey:RECORD_FORMATION] inManagedObjectContext:context];
            
    //Set the plunge and trend
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    record.trend=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_TREND]];
    record.plunge=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_PLUNGE]];
    return record;
}

@end
