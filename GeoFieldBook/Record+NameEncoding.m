//
//  Record+NameEncoding.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+NameEncoding.h"
#import "Record+DictionaryKeys.h"

@implementation Record (NameEncoding)

+ (NSString *)nameForDictionaryKey:(NSString *)dictionaryKey {
    static NSDictionary *nameEncodings;
    
    if (!nameEncodings) {
        nameEncodings=[NSDictionary dictionaryWithObjectsAndKeys:
                       @"Latitude",RECORD_LATITUDE,
                       @"Longitude",RECORD_LONGITUDE,
                       @"Date",RECORD_DATE,
                       @"Dip Direction",RECORD_DIP_DIRECTION, nil];
    }
    
    return [nameEncodings objectForKey:dictionaryKey];
}

@end
