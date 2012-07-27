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

#import "Answer.h"
#import "Answer+Modification.h"

#import "GeoDatabaseManager.h"
#import "SettingManager.h"
#import "IEEngine.h"

@interface StudentFeedbackViewController() <CustomQuestionCellDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *answerLocation;

@end

@implementation StudentFeedbackViewController

@synthesize database=_database;
@synthesize answers=_answers;

@synthesize locationManager=_locationManager;
@synthesize answerLocation=_answerLocation;

#pragma mark - Getters and Setters

- (CLLocation *)answerLocation {
    if (!_answerLocation)
        _answerLocation=self.locationManager.location;
    
    return _answerLocation;
}

- (NSArray *)answers {
    if (!_answers) {
        NSMutableArray *mutableAnswers=[NSMutableArray array];
        for (Question *question in self.fetchedResultsController.fetchedObjects) {
            Answer *answer=[NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:self.database.managedObjectContext];
            answer.question=question;
            answer.numberOfRecords=[SettingManager standardSettingManager].feedbackInterval;
            CLLocationCoordinate2D coordinate=self.answerLocation.coordinate;
            answer.longitude=[NSNumber numberWithFloat:coordinate.longitude];
            answer.latitude=[NSNumber numberWithFloat:coordinate.latitude];
            [mutableAnswers addObject:answer];
        }
        
        _answers=mutableAnswers.copy;
    }
    
    return _answers;
}

#pragma mark - State Initialization Methods

-(void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    CLLocationManager *locationManager=self.locationManager;
    locationManager.distanceFilter = kCLDistanceFilterNone; 
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; //accuracy in 100 meters 
    
    //stop the location manager
    [locationManager stopUpdatingHeading];
    if ([CLLocationManager locationServicesEnabled])
        [locationManager startUpdatingLocation];
}

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
    
    //Setup the location manager
    [self setupLocationManager];
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
    
    //Give the answer corresponding to the current question to the cell
    if (indexPath.row<self.answers.count)
        cell.answer=[self.answers objectAtIndex:indexPath.row];
    
    //Configure the cell
    cell.indexPath=indexPath;
    cell.question=question;
    cell.delegate=self;
    cell.database=self.database;
    
    return cell;
}

#pragma mark - Target-Action Handlers

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    //Write the responses to csv file
    IEEngine *exportEngine=[[IEEngine alloc] init];
    [exportEngine createCSVFilesFromStudentResponses:self.answers];
    
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - CustomQuestionDelegate Protocol Methods

- (CLLocation *)locationForCell:(CustomQuestionCell *)cell {
    return self.answerLocation;
}

- (void)customQuestionCell:(CustomQuestionCell *)cell 
        didCreateNewAnswer:(Answer *)answer 
               atIndexPath:(NSIndexPath *)indexPath
{
    //Add the new answer to the array of answers
    NSMutableArray *answers=self.answers.mutableCopy;
    [answers replaceObjectAtIndex:indexPath.row withObject:answer];
    self.answers=answers.copy;
}

- (void)customQuestionCell:(CustomQuestionCell *)cell 
           didUpdateAnswer:(Answer *)answer 
               withNewInfo:(NSDictionary *)answerInfo
{
    //Update the answer
    [answer updateWithInfo:answerInfo];
    
    //Save changes to database
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL completed){}];
}

@end
