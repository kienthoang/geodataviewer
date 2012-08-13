//
//  Answer.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question, Response_Record;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfRecords;
@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) Response_Record *responseRecord;

@end
