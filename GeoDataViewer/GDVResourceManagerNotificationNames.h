//
//  GDVResourceManagerNotificationNames.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GDVResourceManagerNotificationNames <NSObject>

#define GDVResourceManagerRecordDatabaseDidUpdate @"GDVResourceManager.Notifications.RecordDatabase.DidUpdate"
#define GDVResourceManagerFormationDatabaseDidUpdate @"GDVResourceManager.Notifications.FormationDatabase.DidUpdate"
#define GDVResourceManagerStudentResponseDatabaseDidUpdate @"GDVResourceManager.Notifications.StudentResponseDatabase.DidUpdate"

#define GDVResourceManagerUserInfoUpdateMechanismKey @"GDVResourceManager.Notifications.UserInfo.UpdateMechanismKey"
#define GDVResourceManagerUpdateByImporting @"GDVResourceManager.Notifications.UpdateMechanism.ByImporting"
#define GDVResourceManagerUpdateBySynchronizingWithServer @"GDVResourceManager.Notifications.UpdateMechanism.BySynchronizingWithServer"
#define GDVResourceManagerUpdateByUser @"GDVResourceManager.Notifications.UpdateMechanism.ByUser"

@end
