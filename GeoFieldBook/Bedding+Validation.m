//
//  Bedding+Validation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Bedding+Validation.h"

@implementation Bedding (Validation)

- (NSArray *)validatesMandatoryPresenceOfRecordInfo:(NSDictionary *)recordInfo {
    //Create an array to hold the keys that correspond to missing or invalid mandatory information
    NSMutableArray *invalidInformationKeys=[super validatesMandatoryPresenceOfRecordInfo:recordInfo].mutableCopy;
    
    //Validates the presence of location, date, and dip direction information
    NSMutableArray *mandatoryFields=[NSMutableArray arrayWithObjects:RECORD_DIP_DIRECTION, nil];
    for (NSString *field in mandatoryFields) {
        if (![recordInfo objectForKey:field])
            [invalidInformationKeys addObject:field];
    }
    
    return invalidInformationKeys.copy;
}

@end
