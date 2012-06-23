//
//  RecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Record+Modification.h"

@interface RecordTableViewController : CoreDataTableViewController

@property (nonatomic,strong) NSString *folderName;
@property (nonatomic,strong) UIManagedDocument *database;

@end
