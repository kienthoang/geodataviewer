//
//  ExportRecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeRecordTableViewController.h"
#import "ExportDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

#import "ExportRecordTableViewControllerDelegate.h"

@interface ExportRecordTableViewController : PrototypeRecordTableViewController <UIDoubleTableViewControllerChildren>

@property (nonatomic,strong) NSSet *selectedRecords;
@property (nonatomic,weak) id <ExportRecordTableViewControllerDelegate> delegate;

- (void)updateSelectedRecordsWith:(NSSet *)records;

@end
