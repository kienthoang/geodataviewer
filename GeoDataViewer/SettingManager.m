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

@synthesize defaultFormationColorName=_defaultFormationColorName;

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

- (void)userDefaultsSetObject:(id)object forKey:(NSString *)key {
    [self.userDefaults setObject:object forKey:key];
    [self.userDefaults synchronize];
}

- (void)userDefaultsSetBool:(BOOL)flag forKey:(NSString *)key {
    [self.userDefaults setBool:flag forKey:key];
    [self.userDefaults synchronize];
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
    [self postNotificationWithName:SettingManagerUserPreferencesDidChange andUserInfo:userInfo];
}

#pragma mark - Color Group

-(NSString *) defaultFormationColorName {
    return [self.userDefaults objectForKey:NSUserDefaultsDefaultFormationColor];
}

- (BOOL)colorByGroup {
    return [[self.userDefaults objectForKey:NSUserDefaultsSymbolColor] isEqualToString:NSUserDefaultsColorByGroup];
}

- (BOOL)colorByFormation {
    return [[self.userDefaults objectForKey:NSUserDefaultsSymbolColor] isEqualToString:NSUserDefaultsColorByFormation];
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
    [self userDefaultsSetObject:defaultFormationColor forKey:NSUserDefaultsDefaultFormationColor];
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
    [self userDefaultsSetObject:defaultSymbolColor forKey:NSUserDefaultsDefaultSymbolColor];
}

#pragma mark - Dip Strike Symbol Group

- (BOOL)dipNumberEnabled {
    return [self.userDefaults boolForKey:NSUserDefaultsDipNumberEnabled];
}

- (void)setDipNumberEnabled:(BOOL)dipNumberEnabled {
    [self userDefaultsSetBool:dipNumberEnabled forKey:NSUserDefaultsDipNumberEnabled];
}

- (NSString *)defaultContactFormation {
    return [self.userDefaults objectForKey:NSUserDefaultsContactDefaultFormation];
}

- (void)setDefaultContactFormation:(NSString *)defaultContactFormation {
    [self userDefaultsSetObject:defaultContactFormation forKey:NSUserDefaultsContactDefaultFormation];
}

@end
