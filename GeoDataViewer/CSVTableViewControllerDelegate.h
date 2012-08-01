//
//  CSVTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSVTableViewController;

@protocol CSVTableViewControllerDelegate

- (void)csvTableViewController:(CSVTableViewController *)sender 
   userDidChooseFilesWithNames:(NSArray *)fileNames;

@end
