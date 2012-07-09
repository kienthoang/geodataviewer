//
//  RecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Record+Modification.h"
#import "CustomRecordCell.h"

#import "RecordTableViewControllerDelegate.h"

@interface RecordTableViewController : CoreDataTableViewController

@property (nonatomic,strong) Folder *folder;
@property (nonatomic,strong) UIManagedDocument *database;

@property (nonatomic) BOOL willShowCheckboxes;

@property (nonatomic,weak) id <RecordTableViewControllerDelegate> delegate;

#pragma mark - Currently active record

@property (nonatomic,strong) Record *chosenRecord;
@property (nonatomic,readonly) NSArray *selectedRecords;

- (void)modifyRecord:(Record *)record withNewInfo:(NSDictionary *)recordInfo;

#pragma mark - Filter related properties

@property (nonatomic,strong) NSArray *selectedRecordTypes;


@end
