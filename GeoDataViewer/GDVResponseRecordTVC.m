//
//  GDVResponseRecordTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVResponseRecordTVC.h"
#import "GDVStudentResponseTVC.h"

#import "Answer.h"

@interface GDVResponseRecordTVC ()

@end

@implementation GDVResponseRecordTVC

@synthesize studentGroup=_studentGroup;
@synthesize responseRecords=_responseRecords;

- (void)setResponseRecords:(NSArray *)responseRecords {
    if (responseRecords) {
        _responseRecords=responseRecords;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Sort the response records
        _responseRecords=[_responseRecords sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
        
        //Reload table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.responseRecords)
        [self showLoadingScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Responses"]) {
        UITableViewCell *cell=(UITableViewCell *)sender;
        NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
        Response_Record *responseRecord=[self.responseRecords objectAtIndex:indexPath.row];
        [segue.destinationViewController setStudentResponses:responseRecord.responses.allObjects];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.responseRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Student Response Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text=[NSString stringWithFormat:@"Response # %d",indexPath.row+1];
    
    return cell;
}

@end
