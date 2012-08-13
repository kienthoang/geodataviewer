//
//  Response_Record.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Group;

@interface Response_Record : NSManagedObject

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *responses;
@property (nonatomic, retain) Group *group;
@end

@interface Response_Record (CoreDataGeneratedAccessors)

- (void)addResponsesObject:(Answer *)value;
- (void)removeResponsesObject:(Answer *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

@end
