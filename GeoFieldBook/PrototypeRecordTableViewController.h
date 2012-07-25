//
//  PrototypeRecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "GeoDatabaseManager.h"

#import "Folder.h"
#import "Record.h"

#import "CustomRecordCell.h"

@interface PrototypeRecordTableViewController : CoreDataTableViewController

@property (nonatomic,strong) Folder *folder;
@property (nonatomic,strong) UIManagedDocument *database;

- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message;
- (void)loadImagesForCells:(NSArray *)cells;

#define ImageCacheCapacity 50

@end
