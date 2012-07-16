//
//  ExportRecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeRecordTableViewController.h"
#import "UIDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

@interface ExportRecordTableViewController : PrototypeRecordTableViewController <UIDoubleTableViewControllerChildren>

@property (nonatomic,strong) NSSet *selectedRecords;

@end
