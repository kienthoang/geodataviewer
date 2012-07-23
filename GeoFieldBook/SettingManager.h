//
//  SettingManager.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingManagerNotificationNames.h"

@interface SettingManager : NSObject

+ (SettingManager *)standardSettingManager;

#pragma mark - Color Group

@property (nonatomic) BOOL formationColorEnabled;
@property (nonatomic,strong) UIColor *defaultFormationColor;
@property (nonatomic,strong) UIColor *defaultSymbolColor;

#pragma mark - Gestures Group

@property (nonatomic) BOOL longGestureEnabled;
@property (nonatomic) BOOL swipeToTurnRecordEnabled;
@property (nonatomic,strong) NSNumber *recordSwipeGestureNumberOfFingersRequired;

#define NSUserDefaultsFormationColorEnabled @"color_formation_color_enabled"
#define NSUserDefaultsDefaultFormationColor @"color_default_formation_color"
#define NSUserDefaultsDefaultSymbolColor @"color_default_symbol_color"
#define NSUserDefaultsLongPressEnabled @"gestures_long_press_enabled"
#define NSUserDefaultsSwipeRecordEnabled @"gestures_swipe_record_enabled"
#define NSUserDefaultsSwipeRecord @"gestures_swipe_record"

@end