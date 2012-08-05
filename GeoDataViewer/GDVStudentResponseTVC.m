//
//  GDVStudentResponseTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVStudentResponseTVC.h"

#import "Answer.h"

@interface GDVStudentResponseTVC ()

@end

@implementation GDVStudentResponseTVC

@synthesize studentGroup=_studentGroup;
@synthesize studentResponses=_studentResponses;

- (void)setStudentResponses:(NSArray *)studentResponses {
    if (studentResponses) {
        _studentResponses=studentResponses;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Sort the student responses
        _studentResponses=[_studentResponses sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"content" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
        
        //Reload table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.studentResponses)
        [self showLoadingScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.studentResponses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Student Response Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Answer *response=[self.studentResponses objectAtIndex:indexPath.row];
    cell.textLabel.text=response.content;
    
    return cell;
}

@end
