//
//  GDVResourceManagerNotificationNames.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GDVResourceManagerNotificationNames <NSObject>

#define GDVResourceManagerRecordDatabaseDidUpdate @"GDVresourceManager.Notifications.RecordDatabase.DidUpdate"
#define GDVResourceManagerFormationDatabaseDidUpdate @"GDVresourceManager.Notifications.FormationDatabase.DidUpdate"
#define GDVResourceManagerStudentResponseDatabaseDidUpdate @"GDVresourceManager.Notifications.StudentResponseDatabase.DidUpdate"

@end
