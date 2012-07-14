//
//  ImportTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImportTableViewController;

@protocol ImportTableViewControllerDelegate

- (void)importTableViewControllerDidStartImporting:(ImportTableViewController *)sender;
- (void)importTableViewControllerDidEndImporting:(ImportTableViewController *)sender;
- (void)importTableViewControllerDidCancelImporting:(ImportTableViewController *)sender;

@end
