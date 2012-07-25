//
//  AnswerTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "AnswerTableViewController.h"

#import "Answer.h"

#import "GeoDatabaseManager.h"

@interface AnswerTableViewController ()

@property (nonatomic,strong) UIManagedDocument *database;

@end

@implementation AnswerTableViewController

@synthesize database=_database;

#pragma mark - View Controller Lifecycle

- (void)setupFetchedResultsController {
    if (self.database.documentState==UIDocumentStateNormal) {
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Answer"];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"question.title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Answer Cell"];
    if (!cell)
        cell=[[UITableViewCell alloc] init];
    
    //Configure cell
    Answer *answer=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=answer.content;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Latitude: %@. Longitude: %@",answer.latitude,answer.longitude];
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup database
    self.database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
    [self setupFetchedResultsController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
