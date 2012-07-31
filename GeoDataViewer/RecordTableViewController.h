//
//  RecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "PrototypeRecordTableViewController.h"
#import "Record+Modification.h"
#import "CustomRecordCell.h"

#import "RecordTableViewControllerDelegate.h"

@interface RecordTableViewController : PrototypeRecordTableViewController

@property (nonatomic) BOOL willShowCheckboxes;

@property (nonatomic,weak) id <RecordTableViewControllerDelegate> delegate;

#pragma mark - Currently active record

@property (nonatomic,strong) Record *chosenRecord;
@property (nonatomic,readonly) NSArray *records;

#pragma mark - Record Manipulators

- (void)modifyRecord:(Record *)record withNewInfo:(NSDictionary *)recordInfo;

#pragma mark - Filter related properties

@property (nonatomic,strong) NSArray *selectedRecordTypes;

#pragma mark - Change active records

- (BOOL)hasNextRecord;
- (BOOL)hasPrevRecord;
- (void)forwardToNextRecord;
- (void)backToPrevRecord;

@end
