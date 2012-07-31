//
//  CustomQuestionCell.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomQuestionCell.h"
#import "UICustomSwitch.h"

#import "Answer+Creation.h"
#import "Answer+Modification.h"
#import "SettingManager.h"

@interface CustomQuestionCell() <UITextViewDelegate>

@property (nonatomic,weak) IBOutlet UICustomSwitch *answerSwitch;
@property (nonatomic,weak) IBOutlet UITextView *answerTextView;
@property (nonatomic,weak) IBOutlet UILabel *questionPrompt;

@property (nonatomic,readonly) NSDictionary *answerInfo;

@end

@implementation CustomQuestionCell

@synthesize answerSwitch=_answerSwitch;
@synthesize answerTextView=_answerTextView;
@synthesize questionPrompt=_questionPrompt;

@synthesize database=_database;
@synthesize question=_question;
@synthesize answer=_answer;

@synthesize delegate=_delegate;

@synthesize indexPath=_indexPath;

#pragma mark - Getters and Setters

- (NSDictionary *)answerInfo {
    SettingManager *settingManager=[SettingManager standardSettingManager];
    NSMutableDictionary *answerInfo=[NSMutableDictionary dictionary];
    [answerInfo setObject:self.answerTextView.text forKey:ANSWER_CONTENT];
    [answerInfo setObject:[NSDate date] forKey:ANSWER_DATE];
    [answerInfo setObject:self.question forKey:ANSWER_QUESTION];
    [answerInfo setObject:settingManager.feedbackInterval forKey:ANSWER_NUM_RECORDS];
    CLLocation *currentLocation=[self.delegate locationForCell:self];
    [answerInfo setObject:currentLocation forKey:ANSWER_LOCATION];
    
    return answerInfo.copy;
}

- (Answer *)answer {
    if (!_answer && self.database.documentState==UIDocumentStateNormal) {
        //Create a new answer
            _answer=[NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:self.database.managedObjectContext];
        
        //Notify delegate
        [self.delegate customQuestionCell:self 
                       didCreateNewAnswer:self.answer 
                              atIndexPath:self.indexPath];
    }
    
    return _answer;
}

- (void)setAnswer:(Answer *)answer {
    _answer=answer;
    if (answer.content) {
        //Update the text view
        self.answerTextView.text=answer.content;
    }
}

- (void)updateSubviews {
    if (self.question) {
        //Update the text
        self.questionPrompt.text=self.question.prompt;
        self.answerSwitch.leftLabel.text=@"Yes";
        self.answerSwitch.rightLabel.text=@"No";
        self.answerSwitch.on=YES;
        [self.answerSwitch scaleSwitch:CGSizeMake(0.9, 1)];
        
        //Update delegate
        self.answerTextView.delegate=self;
    }
}

- (void)setQuestion:(Question *)question {
    if (_question!=question) {
        _question=question;
        
        //Update subviews
        [self updateSubviews];
    }
}

#pragma mark - UITextViewDelegate Protocol Methods

- (void)textViewDidChange:(UITextView *)textView {
    //Notify the delegate
    [self.delegate customQuestionCell:self didUpdateAnswer:self.answer withNewInfo:self.answerInfo];
}

@end
