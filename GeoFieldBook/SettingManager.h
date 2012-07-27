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

#define NSUserDefaultsFormationColorEnabled @"color_formation_color_enabled"
#define NSUserDefaultsDefaultFormationColor @"color_default_formation_color"
#define NSUserDefaultsDefaultSymbolColor @"color_default_symbol_color"

@property (nonatomic) BOOL formationColorEnabled;
@property (nonatomic,strong) UIColor *defaultFormationColor;
@property (nonatomic,strong) UIColor *defaultSymbolColor;
@property (nonatomic, strong) NSString *defaultFormationColorName;

#pragma mark - Gestures Group

#define NSUserDefaultsLongPressEnabled @"gestures_long_press_enabled"
#define NSUserDefaultsSwipeRecordEnabled @"gestures_swipe_record_enabled"
#define NSUserDefaultsSwipeRecord @"gestures_swipe_record"

@property (nonatomic) BOOL longGestureEnabled;
@property (nonatomic) BOOL swipeToTurnRecordEnabled;
@property (nonatomic,strong) NSNumber *recordSwipeGestureNumberOfFingersRequired;

#pragma mark - Feedback Group

#define NSUserDefaultsFeedbackEnabled @"feedback_enabled"
#define NSUserDefaultsFeedbackInterval @"feedback_interval"
#define NSUserDefaultsFeedbackCounter @"feedback_counter"

@property (nonatomic) BOOL feedbackEnabled;
@property (nonatomic,strong) NSNumber *feedbackInterval;
@property (nonatomic,strong) NSNumber *feedbackCounter;

#pragma mark - Dip Strike Symbol Group

#define NSUserDefaultsDipNumberEnabled @"dip_number_enabled"
#define NSUserDefaultsContactDefaultFormation @"contact_default_formation"

@property (nonatomic) BOOL dipNumberEnabled;
@property (nonatomic,strong) NSString *defaultContactFormation;

@end