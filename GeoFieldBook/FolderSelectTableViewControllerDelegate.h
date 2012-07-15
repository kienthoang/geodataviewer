//
//  FolderSelectTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FolderSelectTableViewController;

@protocol FolderSelectTableViewControllerDelegate

- (void)folderSelectTVC:(FolderSelectTableViewController *)sender userDidSelectFolder:(Folder *)folder;

@end
