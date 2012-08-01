//
//  ImportTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImportTableViewController;

@protocol ImportTableViewControllerDelegate <NSObject>

@optional

- (void)userDidSelectRecordCSVFiles:(NSArray *)records forImportingInImportTVC:(ImportTableViewController *)sender;
- (void)userDidSelectFormationCSVFiles:(NSArray *)formations forImportingInImportTVC:(ImportTableViewController *)sender;
- (void)userDidSelectFeedbackCSVFiles:(NSArray *)feedbacks forImportingInImportTVC:(ImportTableViewController *)sender;

@end
