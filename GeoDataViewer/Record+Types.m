//
//  Record+Types.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Types.h"

@implementation Record (Types)

+ (NSArray *)allRecordTypes {
    return [NSArray arrayWithObjects:@"Bedding",@"Contact",@"Joint Set",@"Fault",@"Other", nil];
}

@end