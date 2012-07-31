//
//  Record+Validation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Validation.h"

@implementation Record (Validation)

- (NSArray *)validatesMandatoryPresenceOfRecordInfo:(NSDictionary *)recordInfo {
    //Create an array to hold the keys that correspond to missing or invalid mandatory information
    NSMutableArray *invalidInformationKeys=[NSMutableArray array];
    
    //Validates the presence of location, date, and dip direction information
    NSMutableArray *mandatoryFields=[NSMutableArray arrayWithObjects:RECORD_LATITUDE,RECORD_LONGITUDE,RECORD_DATE, nil];
    for (NSString *field in mandatoryFields) {
        if (![recordInfo objectForKey:field])
            [invalidInformationKeys addObject:field];
    }
        
    return invalidInformationKeys.copy;
}

@end
