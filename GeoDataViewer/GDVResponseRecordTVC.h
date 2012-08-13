//
//  GDVResponseRecordTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"

#import "Group.h"
#import "Response_Record.h"

@interface GDVResponseRecordTVC : PrototypeLoadingTableViewController

@property (nonatomic,strong) Group *studentGroup;
@property (nonatomic,strong) NSArray *responseRecords;

@end
