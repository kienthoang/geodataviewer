//
//  GDVFolderTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFolderTVC.h"
#import "GDVRecordTVC.h"

#import "CustomFolderCell.h"

@interface GDVFolderTVC ()

@end

@implementation GDVFolderTVC

@synthesize studentGroup=_studentGroup;
@synthesize folders=_folders;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setFolders:(NSArray *)folders {
    if (folders) {
        _folders=folders;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //sort folders
        _folders=[_folders sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.folders)
        [self showLoadingScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Prepare For Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Records"]) {
        //Get the selected folder
        UITableViewCell *cell=(UITableViewCell *)sender;
        Folder *selectedFolder=[self.folders objectAtIndex:[self.tableView indexPathForCell:cell].row];
        [segue.destinationViewController setFolder:selectedFolder];
        
        //Notify the delegate
        [self.delegate folderTVC:self preparedToSegueToRecordTVC:segue.destinationViewController];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    CustomFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Folder *folder=[self.folders objectAtIndex:indexPath.row];
    cell.folder=folder;
    
    return cell;
}

@end
