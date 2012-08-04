//
//  Question.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * prompt;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *questions;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Answer *)value;
- (void)removeQuestionsObject:(Answer *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
