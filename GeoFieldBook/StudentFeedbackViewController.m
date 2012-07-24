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
#import "Question+Seed.h"

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

- (void)createSeedQuestionsInManagedObjectContext:(NSManagedObjectContext *)context {
    //If there is no question in the core data database, initialize seed questions 
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Question"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (!results.count) {
        //Seed data
        [Question seedDataInContext:context];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up the database
    if (!self.database)
        self.database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
    
    //Create seed questions if there's none
    [self createSeedQuestionsInManagedObjectContext:self.database.managedObjectContext];
    
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
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
