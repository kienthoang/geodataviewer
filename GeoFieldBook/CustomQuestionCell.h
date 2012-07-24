//
//  CustomQuestionCell.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Question.h"

@interface CustomQuestionCell : UITableViewCell

#define FeedbackQuestionBooleanType @"GeoFieldBook.Feedback.Question.BooleanType"
#define FeedbackQuestionTextType @"GeoFieldBook.Feedback.Question.TextType"

@property (nonatomic,strong) Question *question;

@end
