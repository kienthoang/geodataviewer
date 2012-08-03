//
//  GDVRecordTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"

#import "Folder.h"
#import "Record.h"

@interface GDVRecordTVC : PrototypeLoadingTableViewController

@property (nonatomic,strong) Folder *folder;
@property (nonatomic,strong) NSArray *records;

@end
