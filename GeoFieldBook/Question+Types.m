//
//  Question+Types.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question+Types.h"

@implementation Question (Types)

+ (NSString *)nameForQuestionType:(QuestionType)questionType {
    NSString *questionTypeName=nil;
    if (questionType==BooleanQuestionType)
        questionTypeName=@"Boolean Question Type";
    else if (questionType==TextQuestionType)
        questionTypeName=@"Text Question Type";
    
    return questionTypeName;
}

+ (QuestionType)questionTypeForTypeName:(NSString *)questionTypeName {
    if ([questionTypeName isEqualToString:@"Boolean Question Type"])
        return BooleanQuestionType;
    else if ([questionTypeName isEqualToString:@"Text Question Type"])
        return TextQuestionType;
    
    return UnrecognizedQuestionType;
}

@end
