//
//  GDVStudentGroupTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVStudentGroupTVC.h"

@interface GDVStudentGroupTVC ()

@property (nonatomic,weak) SSLoadingView *loadingView;

@end

@implementation GDVStudentGroupTVC

@synthesize loadingView=_loadingView;

@synthesize studentGroups=_studentGroups;

- (void)showLoadingScreen {
    if (!self.loadingView) {
        CGSize size = self.view.frame.size;
        
        SSLoadingView *loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        [self.view addSubview:loadingView];
        self.loadingView=loadingView;
    }
}

- (void)stopLoadingScreen {
    if (self.loadingView)
        [self.loadingView removeFromSuperview];
}

#pragma mark - Getters and Setters

- (void)setStudentGroups:(NSArray *)studentGroups {
    if (studentGroups) {
        _studentGroups=studentGroups;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //Show loading screen while asking for data
    if (!self.studentGroups)
        [self showLoadingScreen];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Folders"]) {
        
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.studentGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Student Group Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Group *group=[self.studentGroups objectAtIndex:indexPath.row];
    cell.textLabel.text=group.name;
    
    return cell;
}

@end
