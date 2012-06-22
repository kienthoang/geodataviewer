//
//  RecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class RecordTableViewController;

@protocol RecordTableViewControllerDelegate <NSObject>

- (void)recordTableViewController:(RecordTableViewController *)sender 
               addNewRecordOfType:(NSString *)recordType 
                         inFolder:(NSString *)folderName;

@end

@interface RecordTableViewController : CoreDataTableViewController

@property (nonatomic,strong) NSString *folderName;

@property (nonatomic,weak) id <RecordTableViewControllerDelegate> delegate;

@end
