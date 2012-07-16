//
//  FolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrototypeFolderTableViewController.h"

@interface FolderTableViewController : PrototypeFolderTableViewController 

@property (nonatomic,readonly) NSArray *selectedFolders;

@property (nonatomic) BOOL willFilterByFolder;

- (void)reloadVisibleCells;

@end
