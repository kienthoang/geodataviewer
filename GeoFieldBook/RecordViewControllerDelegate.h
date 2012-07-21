//
//  RecordViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordViewController.h"

@class RecordViewController;

@protocol RecordViewControllerDelegate <NSObject>

- (void)recordViewController:(RecordViewController *)sender 
         userDidModifyRecord:(Record *)record 
           withNewRecordInfo:(NSDictionary *)recordInfo;

- (void)userDidNavigateAwayFrom:(RecordViewController *)sender 
           whileModifyingRecord:(Record *)record 
                    withNewInfo:(NSDictionary *)newInfo;

@optional

- (void)userDidSwipeDownInRecordViewController:(RecordViewController *)sender;
- (void)userDidSwipeUpInRecordViewController:(RecordViewController *)sender;

- (void)userDidCancelEditingMode:(RecordViewController *)sender;
- (void)userDidStartEditingMode:(RecordViewController *)sender;
- (void)userWantsToCancelEditingMode:(RecordViewController *)sender;

@end
