//
//  StudentFeedbackViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "StudentFeedbackViewController.h"

#import "CustomQuestionCell.h"
#import "Question+Types.h"

#import "GeoDatabaseManager.h"

@interface StudentFeedbackViewController ()

@end

@implementation StudentFeedbackViewController

@synthesize database=_database;

- (void)setupFetchedResultsController {
    if (self.database.documentState==UIDocumentStateNormal) {
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Question"];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up the database
    if (!self.database)
        self.database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
    
    //Setup fetched results controller to get questions
    [self setupFetchedResultsController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"";
    
    //Get the corresponding question
    Question *question=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Determine the cell type
    QuestionType questionType=[Question questionTypeForTypeName:question.type]; 
    if (questionType==BooleanQuestionType)
        CellIdentifier=FeedbackQuestionBooleanType;
    else if (questionType==TextQuestionType)
        CellIdentifier=FeedbackQuestionTextType;
    else
        CellIdentifier=@"Unrecognized Type";
    
    CustomQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell=[[CustomQuestionCell alloc] init];
    
    //Configure the cell
    cell.question=question;
    
    return cell;
}

#pragma mark - Target-Action Handlers

- (IBAction)donePressed:(UIBarButtonItem *)sender {
//    Question *question1=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.database.managedObjectContext];
//    question1.prompt=@"Does what I have collected make sense?";
//    question1.type=[Question nameForQuestionType:BooleanQuestionType];
//    question1.title=@"Question 1";
//    
//    Question *question2=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.database.managedObjectContext];
//    question2.prompt=@"How might I modify my working hypothesis?";
//    question2.type=[Question nameForQuestionType:TextQuestionType];
//    question2.title=@"Question 2";
//    
//    Question *question3=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:self.database.managedObjectContext];
//    question3.prompt=@"How might I change my field program to maximize the field data to test my hypothesis?";
//    question3.type=[Question nameForQuestionType:TextQuestionType];
//    question3.title=@"Question 3";
//    
//    NSLog(@"Database: %@",self.database);
//    
//    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
//        NSLog(@"Success");
//    }];
//    
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
