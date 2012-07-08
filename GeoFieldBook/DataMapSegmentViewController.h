//
//  DataMapSegmentViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoSegmentViewController.h"
#import "RecordMapViewController.h"
#import "InitialDetailViewController.h"
#import "RecordViewController.h"
#import "Record.h"

#import "RecordViewControllerDelegate.h"
#import "RecordMapViewControllerDelegate.h"

#import "DataMapSegmentViewControllerDelegate.h"

@interface DataMapSegmentViewController : GeoSegmentViewController

#define INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Initial Detail View Controller"
#define RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Record Detail View Controller"
#define RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER @"Record Map View Controller"

- (void)setMapViewDelegate:(id <RecordMapViewControllerDelegate>)mapDelegate;
- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate;
- (void)updateMapWithRecords:(NSArray *)records;
- (void)updateRecordDetailViewWithRecord:(Record *)record;
- (void)putRecordViewControllerIntoEditingMode;
- (void)setMapSelectedRecord:(Record *)selectedRecord;

- (void)pushInitialViewController;
- (void)pushRecordViewController;

@property (nonatomic,readonly) UIViewController *detailSideViewController;
@property (nonatomic,weak) id <DataMapSegmentViewControllerDelegate> delegate;

@end
