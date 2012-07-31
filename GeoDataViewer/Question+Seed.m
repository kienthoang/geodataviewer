//
//  Question+Seed.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question+Seed.h"

#import "Question+Types.h"

@implementation Question (Seed)

+ (void)seedDataInContext:(NSManagedObjectContext *)context {
    Question *question1=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    question1.prompt=@"Does what I have collected make sense?";
    question1.type=[Question nameForQuestionType:BooleanQuestionType];
    question1.title=@"Question 1";
    
    Question *question2=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    question2.prompt=@"How might I modify my working hypothesis?";
    question2.type=[Question nameForQuestionType:TextQuestionType];
    question2.title=@"Question 2";
    
    Question *question3=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    question3.prompt=@"How might I change my field program to maximize the field data to test my hypothesis?";
    question3.type=[Question nameForQuestionType:TextQuestionType];
    question3.title=@"Question 3";
}

@end
