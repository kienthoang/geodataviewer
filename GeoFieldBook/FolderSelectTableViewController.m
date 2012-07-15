//
//  FolderSelectTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FolderSelectTableViewController.h"
#import "Folder.h"

@interface FolderSelectTableViewController ()

@end

@implementation FolderSelectTableViewController

@synthesize delegate=_delegate;

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Call the delegate
    Folder *folder=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate folderSelectTVC:self userDidSelectFolder:folder];
}

@end
