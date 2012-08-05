//
//  Answer+DateFormatter.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer+DateFormatter.h"

@implementation Answer (DateFormatter)

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
