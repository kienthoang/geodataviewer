//
//  CustomQuestionCell.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomQuestionCell.h"
#import "UICustomSwitch.h"

@interface CustomQuestionCell()

@property (nonatomic,weak) IBOutlet UICustomSwitch *answerSwitch;
@property (nonatomic,weak) IBOutlet UITextView *answerTextView;
@property (nonatomic,weak) IBOutlet UILabel *questionPrompt;

@end

@implementation CustomQuestionCell

@synthesize answerSwitch=_answerSwitch;
@synthesize answerTextView=_answerTextView;
@synthesize questionPrompt=_questionPrompt;

@synthesize question=_question;

#pragma mark - Getters and Setters

- (void)updateSubviews {
    if (self.question) {
        self.questionPrompt.text=self.question.prompt;
        self.answerSwitch.leftLabel.text=@"Yes";
        self.answerSwitch.rightLabel.text=@"No";
        self.answerSwitch.on=YES;
        [self.answerSwitch scaleSwitch:CGSizeMake(0.9, 1)];
    }
}

- (void)setQuestion:(Question *)question {
    if (_question!=question) {
        _question=question;
        
        //Update subviews
        [self updateSubviews];
    }
}

@end
