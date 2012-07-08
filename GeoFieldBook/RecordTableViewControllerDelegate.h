//
//  RecordTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "Folder.h"

@class RecordTableViewController;

@protocol RecordTableViewControllerDelegate <NSObject>

@optional

- (void)userDidSelectRecord:(Record *)record;

- (void)recordTableViewController:(RecordTableViewController *)sender 
                needsUpdateFolder:(Folder *)folder 
           setFormationFolderName:(NSString *)formationFolder;

@end
