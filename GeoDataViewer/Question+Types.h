//
//  Question+Types.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question.h"

@interface Question (Types)

typedef enum QuestionType {BooleanQuestionType,TextQuestionType,UnrecognizedQuestionType} QuestionType;

+ (NSString *)nameForQuestionType:(QuestionType)questionType;
+ (QuestionType)questionTypeForTypeName:(NSString *)questionTypeName;

@end
