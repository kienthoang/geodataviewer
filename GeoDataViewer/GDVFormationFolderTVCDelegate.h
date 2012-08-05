//
//  GDVFormationFolderTVCDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVFormationFolderTVC;
@class GDVFormationTableViewController;

@protocol GDVFormationFolderTVCDelegate <NSObject>

- (void)formationFolderTVC:(GDVFormationFolderTVC *)sender preparedToSegueToFormationTVC:(GDVFormationTableViewController *)formationTVC;

- (void)updateFormationFoldersForFormationFolderTVC:(GDVFormationFolderTVC *)sender;

@end
