//
//  GeoDataViewerAppDelegate.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoDataViewerAppDelegate.h"

#import "GDVResourceManager.h"

@implementation GeoDataViewerAppDelegate

@synthesize window = _window;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    //Initialize database for resource manager
    [GDVResourceManager defaultResourceManager];
    
    // Override point for customization after application launch.
    return YES;
}

@end
