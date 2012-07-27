//
//  SettingManagerNotificationNames.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingManagerNotificationNames <NSObject>

#define SettingManagerUserPreferencesDidChange @"GeoFieldBook.SettingManager.UserPreferencesDidChange"

#define SettingManagerFormationColorEnabledDidChange @"GeoFieldBook.SettingManager.FormationColorEnabledDidChange"
#define SettingManagerDefaultFormationColorDidChange @"GeoFieldBook.SettingManager.DefaultFormationColorDidChange"
#define SettingManagerDefaultSymbolColorDidChange @"GeoFieldBook.SettingManager.DefaultSymbolColorDidChange"
#define SettingManagerLongPressEnabledDidChange @"GeoFieldBook.SettingManager.LongPressEnabledDidChange"
#define SettingManagerSwipeRecordEnabledDidChange @"GeoFieldBook.SettingManager.SwipeRecordEnabledDidChange"
#define SettingManagerSwipeRecordDidChange @"GeoFieldBook.SettingManager.SwipeRecordDidChange"
#define SettingManagerFeedbackTimeout @"GeoFieldBook.SettingManager.FeedbackTimeout"
#define SettingManagerDipNumberEnabledDidChange @"GeoFieldBook.SettingManager.DipNumberEnabledDidChange"
#define SettingManagerContactDefaultFormationDidChange @"GeoFieldBook.SettingManager.ContactDefaultFormationDidChange"

@end
