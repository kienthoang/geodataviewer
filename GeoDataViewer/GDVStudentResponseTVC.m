//
//  GDVStudentResponseTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVStudentResponseTVC.h"

#import "CustomQuestionCell.h"
#import "Question+Types.h"

#import "Answer.h"

#import "GeoDatabaseManager.h"

@interface GDVStudentResponseTVC()

@end

@implementation GDVStudentResponseTVC

@synthesize studentResponses=_studentResponses;

#pragma mark - Getters and Setters

- (void)setStudentResponses:(NSArray *)studentResponses {
    if (_studentResponses!=studentResponses) {
        _studentResponses=studentResponses;
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentResponses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"";
    
    //Get the corresponding question
    Answer *response=[self.studentResponses objectAtIndex:indexPath.row];
    Question *question=response.question;
    
    // Determine the cell type
    //QuestionType questionType=[Question questionTypeForTypeName:question.type]; 
    //if (questionType==BooleanQuestionType)
        //CellIdentifier=FeedbackQuestionBooleanType;
   // else if (questionType==TextQuestionType)
        CellIdentifier=FeedbackQuestionTextType;
    //else
        //CellIdentifier=@"Unrecognized Type";
    
    CustomQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell=[[CustomQuestionCell alloc] init];
    
    //Configure the cell
    cell.question=question;
    cell.response=response;
    
    NSLog(@"Question: %@",question);
    
    return cell;
}

@end
