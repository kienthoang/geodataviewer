//
//  Answer.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Question;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfRecords;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Question *question;

@end
