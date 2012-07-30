//
//  DataMapSegmentViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SegmentViewController.h"
#import "RecordMapViewController.h"
#import "InitialDetailViewController.h"
#import "RecordViewController.h"
#import "Record.h"

#import "RecordViewControllerDelegate.h"
#import "RecordMapViewControllerDelegate.h"

#import "DataMapSegmentControllerDelegate.h"

@interface DataMapSegmentViewController : SegmentViewController

#define INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Initial Detail View Controller"
#define RECORD_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Record Detail View Controller"
#define RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER @"Record Map View Controller"

typedef void (^push_completion_handler_t)(void);


- (void)setRecordViewControllerDelegate:(id <RecordViewControllerDelegate>)delegate;
- (void)updateRecordDetailViewWithRecord:(Record *)record;
- (void)putRecordViewControllerIntoEditingMode;
- (void)cancelRecordViewControllerEditingMode;

- (void)setMapViewDelegate:(id <RecordMapViewControllerDelegate>)mapDelegate;
- (void)updateMapWithRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion;
- (void)setMapSelectedRecord:(Record *)selectedRecord;
- (void)reloadMapAnnotationViews;

- (void)pushInitialViewController;
- (void)pushRecordViewController;

- (void)dismissKeyboardInDataSideView;

- (void)pushRecordViewControllerWithTransitionAnimation:(TransionAnimationOption)animationOption 
                                                  setup:(push_completion_handler_t)setupHandler 
                                             completion:(push_completion_handler_t)completionHandler;

@property (nonatomic,readonly) UIViewController *detailSideViewController;

@property (nonatomic,weak) id <DataMapSegmentControllerDelegate> delegate;

@end
