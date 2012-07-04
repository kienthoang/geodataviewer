//
//  InitialMapSegmentViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoSegmentViewController.h"
#import "InitialDetailViewController.h"
#import "UISplitViewBarButtonPresenter.h"
#import "GeoMapAnnotationProvider.h"
#import "RecordMapViewController.h"

@interface InitialMapSegmentViewController : GeoSegmentViewController <UISplitViewBarButtonPresenter>

#define INITIAL_DETAIL_VIEW_CONTROLLER_IDENTIFIER @"Initial Detail View Controller"
#define RECORD_MAP_VIEW_CONTROLLER_IDENTIFIER @"Record Map View Controller"

- (void)setRecordMapViewControllerMapDelegate:(id <GeoMapAnnotationProvider>)mapDelegate;
- (void)updateMapWithRecords:(NSArray *)records;

@end
