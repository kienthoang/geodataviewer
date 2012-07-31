//
//  CustomQuestionCell.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Question.h"

@class CustomQuestionCell;

@protocol CustomQuestionCellDelegate

- (CLLocation *)locationForCell:(CustomQuestionCell *)cell;
- (void)customQuestionCell:(CustomQuestionCell *)cell 
        didCreateNewAnswer:(Answer *)answer 
               atIndexPath:(NSIndexPath *)indexPath;
- (void)customQuestionCell:(CustomQuestionCell *)cell 
           didUpdateAnswer:(Answer *)answer 
               withNewInfo:(NSDictionary *)answerInfo;

@end

@interface CustomQuestionCell : UITableViewCell

#define FeedbackQuestionBooleanType @"GeoFieldBook.Feedback.Question.BooleanType"
#define FeedbackQuestionTextType @"GeoFieldBook.Feedback.Question.TextType"

@property (nonatomic,strong) Question *question;
@property (nonatomic,strong) UIManagedDocument *database;

@property (nonatomic,strong) Answer *answer;
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,weak) id <CustomQuestionCellDelegate> delegate;

@end
