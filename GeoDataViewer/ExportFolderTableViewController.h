//
//  ExportFolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeFolderTableViewController.h"
#import "ExportDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

#import "ExportRecordTableViewControllerDelegate.h"

@interface ExportFolderTableViewController : PrototypeFolderTableViewController <UIDoubleTableViewControllerChildren,ExportRecordTableViewControllerDelegate>

@property (nonatomic,readonly) NSArray *selectedRecords;

@property (nonatomic,weak) id <ExportButtonOwner> exportButtonOwner;

@end
