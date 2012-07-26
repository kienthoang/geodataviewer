//
//  Record+DateAndTimeFormatter.m
//  GeoFieldBook
//
//  Created by excel 2011 on 6/28/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+DateAndTimeFormatter.h"

@implementation Record (DateAndTimeFormatter)

+ (NSString *)dateFromNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
     
}
+ (NSString *)timeFromNSDate:(NSDate *)date {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    return [timeFormatter stringFromDate:date];
}

@end
