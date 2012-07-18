//
//  ExportRecordTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/18/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ExportRecordTableViewController;

@protocol ExportRecordTableViewControllerDelegate

- (void)exportTVC:(ExportRecordTableViewController *)sender userDidSelectRecords:(NSSet *)records forFolder:(Folder *)folder;

@end
