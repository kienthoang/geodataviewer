//
//  ModelGroupNotificationNames.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelGroupNotificationNames <NSObject>
 
#define GeoNotificationModelGroupFolderDatabaseDidChange @"ModelGroup.FolderTableViewController.DatabaseDidChange"
#define GeoNotificationModelGroupDidCreateNewRecord @"ModelGroup.RecordTableViewController.DidCreateNewRecord"
#define GeoNotificationModelGroupRecordDatabaseDidChange @"ModelGroup.RecordTableViewController.DatabaseDidChange"
#define GeoNotificationModelGroupRecordDatabaseDidUpdate @"ModelGroup.RecordTableViewController.DatabaseDidUpdate"
#define GeoNotificationModelGroupFormationDatabaseDidChange @"ModelGroup.FormationTableViewController.DatabaseDidChange"
#define GeoNotificationModelGroupDidSelectRecord @"ModelGroup.RecordTableViewController.DidSelectRecord"

#define GeoNotificationKeyModelGroupSelectedRecord @"ModelGroup.NotificationKey.SelectedRecord"

@end
