//
//  Answer+DateFormatter.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer.h"

@interface Answer (DateFormatter)

+ (NSString *)dateFromNSDate:(NSDate *)date;
+ (NSString *)timeFromNSDate:(NSDate *)date;

@end
