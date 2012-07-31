//
//  RecordMapViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Record;
@class RecordMapViewController;

@protocol RecordMapViewControllerDelegate <NSObject>

- (NSArray *)recordsForMapViewController:(RecordMapViewController *)mapViewController;

@optional

- (void)userDidChooseToDisplayRecordTypes:(NSArray *)selectedRecordTypes;

@end
