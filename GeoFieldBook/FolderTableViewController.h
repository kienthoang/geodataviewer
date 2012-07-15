//
//  FolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "FolderTableViewControllerPrototype.h"

@interface FolderTableViewController : FolderTableViewControllerPrototype 

@property (nonatomic,readonly) NSArray *selectedFolders;

@property (nonatomic) BOOL willFilterByFolder;

@end
