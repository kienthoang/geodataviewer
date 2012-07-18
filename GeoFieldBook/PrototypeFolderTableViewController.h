//
//  PrototypeFolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "GeoDatabaseManager.h"

#import "CustomFolderCell.h"

#import "Folder.h"

@interface PrototypeFolderTableViewController : CoreDataTableViewController

@property (nonatomic,strong) UIManagedDocument *database;   //The database to fetch folders from

- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message;

@end
