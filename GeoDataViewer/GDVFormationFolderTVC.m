//
//  GDVFormationFolderTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFormationFolderTVC.h"
#import "GDVFormationTableViewController.h"

@interface GDVFormationFolderTVC()

@end

@implementation GDVFormationFolderTVC

@synthesize formationFolders=_formationFolders;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setFormationFolders:(NSArray *)formationFolders {
    if (formationFolders) {
        _formationFolders=formationFolders;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Load data
    NSLog(@"Delegate: %@",self.delegate);
    [self.delegate updateFormationFoldersForFormationFolderTVC:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.formationFolders)
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

#pragma mark - Prepare For Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Formations"]) {
        //Get the selected formation folder
        UITableViewCell *cell=(UITableViewCell *)sender;
        Formation_Folder *selectedFormationFolder=[self.formationFolders objectAtIndex:[self.tableView indexPathForCell:cell].row];
        [segue.destinationViewController setFormationFolder:selectedFormationFolder];
        
        //Notify the delegate
        [self.delegate formationFolderTVC:self preparedToSegueToFormationTVC:segue.destinationViewController];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.formationFolders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Folder Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Formation_Folder *folder=[self.formationFolders objectAtIndex:indexPath.row];
    cell.textLabel.text=folder.folderName;
    
    return cell;
}

@end
