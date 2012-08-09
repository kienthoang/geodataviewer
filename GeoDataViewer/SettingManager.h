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

#define NSUserDefaultsSymbolColor @"symbol_color"
#define NSUserDefaultsColorByGroup @"By Group"
#define NSUserDefaultsColorByFormation @"By Formation"
#define NSUserDefaultsDefaultFormationColor @"color_default_formation_color"
#define NSUserDefaultsDefaultSymbolColor @"color_default_symbol_color"

@property (nonatomic,readonly) BOOL colorByFormation;
@property (nonatomic,readonly) BOOL colorByGroup;
@property (nonatomic,strong) UIColor *defaultFormationColor;
@property (nonatomic,strong) UIColor *defaultSymbolColor;
@property (nonatomic, strong) NSString *defaultFormationColorName;

#pragma mark - Dip Strike Symbol Group

#define NSUserDefaultsDipNumberEnabled @"dip_number_enabled"
#define NSUserDefaultsContactDefaultFormation @"contact_default_formation"

@property (nonatomic) BOOL dipNumberEnabled;
@property (nonatomic,strong) NSString *defaultContactFormation;

@end