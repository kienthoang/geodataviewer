//
//  ExportFormationTableViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/18/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ExportFormationTableViewController;

@protocol ExportFormationTableViewControllerDelegate <NSObject>

- (void)exportTVC:(ExportFormationTableViewController *)sender userDidSelectFormations:(NSSet *)formations forFolder:(Formation_Folder *)folder;

@end
