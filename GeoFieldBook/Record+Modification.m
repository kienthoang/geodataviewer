//
//  Record+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Modification.h"

@implementation Record (Modification)

- (BOOL)updateWithNewRecordInfo:(NSDictionary *)recordInfo 
{
    if (![recordInfo count])
        return NO;
    
    //Update info
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    self.name=[recordInfo objectForKey:RECORD_NAME];
    self.latitude=[recordInfo objectForKey:RECORD_LATITUDE];
    self.longitude=[recordInfo objectForKey:RECORD_LONGITUDE];
    self.dip=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_DIP]];
    self.strike=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_STRIKE]];
    self.dipDirection=[recordInfo objectForKey:RECORD_DIP_DIRECTION];
    self.fieldOservations=[recordInfo objectForKey:RECORD_FIELD_OBSERVATION];
    //self.date=[recordInfo objectForKey:RECORD_DATE];
    
    return YES;
}

@end
