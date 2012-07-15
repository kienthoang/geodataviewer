//
//  CSVTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ImportTableViewController.h"
#import "CSVTableViewControllerDelegate.h"

@interface CSVTableViewController : ImportTableViewController

@property (nonatomic,strong) NSArray *blacklistedExtensions;

@property (nonatomic,weak) id <CSVTableViewControllerDelegate> delegate;

@end
