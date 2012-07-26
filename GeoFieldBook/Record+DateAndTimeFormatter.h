//
//  Record+DateAndTimeFormatter.h
//  GeoFieldBook
//
//  Created by excel 2011 on 6/28/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"

@interface Record (DateAndTimeFormatter)

+ (NSString *)dateFromNSDate:(NSDate *)date;
+ (NSString *)timeFromNSDate:(NSDate *)time;

@end
