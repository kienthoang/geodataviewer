//
//  Record+DipDirectionValues.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/12/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+DipDirectionValues.h"

@implementation Record (DipDirectionValues)

+ (NSArray *)allDipDirectionValues {
    return [NSArray arrayWithObjects:@"N", @"NE", @"E",@"SE" , @"S", @"SW", @"W", @"NW", nil];
}

@end
