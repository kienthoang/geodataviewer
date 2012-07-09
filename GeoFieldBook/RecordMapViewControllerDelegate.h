//
//  RecordMapViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "RecordMapViewController.h"

@class RecordMapViewController;

@protocol RecordMapViewControllerDelegate <NSObject>

- (NSArray *)recordsForMapViewController:(RecordMapViewController *)mapViewController;

- (void)mapViewController:(RecordMapViewController *)mapVC userDidSelectAnnotationForRecord:(Record *)record 
         switchToDataView:(BOOL)willSwitchToDataView;

@optional

- (void)userDidChooseToDisplayRecordTypes:(NSArray *)selectedRecordTypes;

@end
