//
//  SettingManager.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SettingManager.h"

@interface SettingManager()

@property (nonatomic,readonly) NSUserDefaults *userDefaults;

@end

@implementation SettingManager

static SettingManager *settingManager;

+ (void)initialize {
    [super initialize];
    
    //Set up the singleton instance
    if (!settingManager)
        settingManager=[[SettingManager alloc] init];
}

+ (SettingManager *)standardSettingManager {
    return settingManager;
}

- (SettingManager *)init {
    if (self=[super init]) {
        //Register to hear changes from the setting program
        NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(userPreferencesDidChange:)
													 name:NSUserDefaultsDidChangeNotification
												   object:[NSUserDefaults standardUserDefaults]];
    }
    
    return self;
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Notification Center

- (void)postNotificationWithName:(NSString *)name andUserInfo:(NSDictionary *)userInfo {
    //Post the notification
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:self userInfo:userInfo];    
}

- (void)userPreferencesDidChange:(NSNotification *)notification {
    //Post notifications
    NSDictionary *userInfo=[NSDictionary dictionary];
    [self postNotificationWithName:SettingManagerFormationColorEnabledDidChange andUserInfo:userInfo];
    [self postNotificationWithName:SettingManagerDefaultFormationColorDidChange andUserInfo:userInfo];
    [self postNotificationWithName:SettingManagerDefaultSymbolColorDidChange andUserInfo:userInfo];
    [self postNotificationWithName:SettingManagerLongPressEnabledDidChange andUserInfo:userInfo];
    [self postNotificationWithName:SettingManagerSwipeRecordEnabledDidChange andUserInfo:userInfo];
    [self postNotificationWithName:SettingManagerSwipeRecordDidChange andUserInfo:userInfo];
}

#pragma mark - Color Group

- (BOOL)formationColorEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsFormationColorEnabled];
}

- (void)setFormationColorEnabled:(BOOL)formationColorEnabled {
    [self.userDefaults setBool:formationColorEnabled forKey:NSUserDefaultsFormationColorEnabled];
    [self.userDefaults synchronize];
}

- (UIColor *)defaultFormationColor {
    UIColor *defaultFormationColor=nil;
    NSString *defaultFormationColorPreference=[self.userDefaults objectForKey:NSUserDefaultsDefaultFormationColor];
    if ([defaultFormationColorPreference isEqualToString:@"Red"])
        defaultFormationColor=[UIColor redColor];
    else if ([defaultFormationColorPreference isEqualToString:@"Blue"])
        defaultFormationColor=[UIColor blueColor];
    else if ([defaultFormationColorPreference isEqualToString:@"Green"])
        defaultFormationColor=[UIColor greenColor];
    
    return defaultFormationColor;
}

- (void)setDefaultFormationColor:(NSString *)defaultFormationColor {
    [self.userDefaults setObject:defaultFormationColor forKey:NSUserDefaultsDefaultFormationColor];
    [self.userDefaults synchronize];
}


- (UIColor *)defaultSymbolColor {
    UIColor *defaultSymbolColor=nil;
    NSString *defaultSymbolColorPreference=[self.userDefaults objectForKey:NSUserDefaultsDefaultSymbolColor];
    if ([defaultSymbolColorPreference isEqualToString:@"Red"])
        defaultSymbolColor=[UIColor redColor];
    else if ([defaultSymbolColorPreference isEqualToString:@"Blue"])
        defaultSymbolColor=[UIColor blueColor];
    else if ([defaultSymbolColorPreference isEqualToString:@"Black"])
        defaultSymbolColor=[UIColor blackColor];
    
    return defaultSymbolColor;
}

- (void)setDefaultSymbolColor:(NSString *)defaultSymbolColor {
    [self.userDefaults setObject:defaultSymbolColor forKey:NSUserDefaultsDefaultSymbolColor];
    [self.userDefaults synchronize];
}

#pragma mark - Gestures Group

- (BOOL)longGestureEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsLongPressEnabled];
}

- (void)setLongGestureEnabled:(BOOL)longGestureEnabled {
    [self.userDefaults setBool:longGestureEnabled forKey:NSUserDefaultsLongPressEnabled];
    [self.userDefaults synchronize];
}

- (BOOL)swipeToTurnRecordEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsSwipeRecordEnabled];
}

- (void)setSwipeToTurnRecordEnabled:(BOOL)swipeToTurnRecordEnabled {
    return [self.userDefaults setBool:swipeToTurnRecordEnabled forKey:NSUserDefaultsSwipeRecordEnabled];
    [self.userDefaults synchronize];
}

-(NSNumber *)recordSwipeGestureNumberOfFingersRequired {
    return [self.userDefaults objectForKey:NSUserDefaultsSwipeRecord];
}

- (void)setRecordSwipeGestureNumberOfFingersRequired:(NSNumber *)recordSwipeGestureNumberOfFingersRequired {
    [self.userDefaults setObject:recordSwipeGestureNumberOfFingersRequired forKey:NSUserDefaultsSwipeRecord];
    [self.userDefaults synchronize];
}

@end
