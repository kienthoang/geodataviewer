//
//  ImportTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ImportTableViewControllerDelegate.h"

@interface ImportTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *csvFileNames;
@property (nonatomic,strong) NSArray *selectedCSVFiles;

@property (nonatomic,strong) NSString *csvFileExtension;
@property (nonatomic,strong) NSArray *blacklistedExtensions;

#define SECTION_FOOTER_HEIGHT 30
#define SizeInPopover CGRectMake(0,0,400,500).size

- (IBAction)importPressed:(UIBarButtonItem *)sender;

- (void)synchronizeWithFileSystem;

typedef void (^handler_t)(NSArray *selectedCSVFiles);
- (void)startImportingWithHandler:(handler_t)handler;

- (void)putImportButtonBack;

@property (nonatomic,weak) id <ImportTableViewControllerDelegate> delegate;

@end
