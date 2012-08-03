//
//  GDVFolderTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFolderTVC.h"

@interface GDVFolderTVC ()

@end

@implementation GDVFolderTVC

@synthesize studentGroup=_studentGroup;
@synthesize folders=_folders;

#pragma mark - Getters and Setters

- (void)setFolders:(NSArray *)folders {
    if (folders) {
        _folders=folders;
        
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
    if (!self.folders)
        [self showLoadingScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Folder *folder=[self.folders objectAtIndex:indexPath.row];
    cell.textLabel.text=folder.folderName;
    int numRecords=folder.records.count;
    NSString *recordCounter=numRecords>1 ?[NSString stringWithFormat:@"%d Records",numRecords] : [NSString stringWithFormat:@"%d Record",numRecords];
    cell.detailTextLabel.text=recordCounter;
    
    return cell;
}

@end
