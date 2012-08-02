//
//  GDVResourceManager.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeoDatabaseManager.h"

#import "GDVIEEngine.h"
#import "GDVServerCommunicator.h"
#import "GDVTransientDataProcessor.h"

#import "GDVResourceManagerNotificationNames.h"

@interface GDVResourceManager : NSObject

@property (nonatomic,strong) UIManagedDocument *database;

@property (nonatomic,strong) GDVIEEngine *engine;
@property (nonatomic,strong) GDVServerCommunicator *server;
@property (nonatomic,strong) GDVTransientDataProcessor *serverProcessor;
@property (nonatomic,strong) GDVTransientDataProcessor *engineProcessor;

+ (GDVResourceManager *)defaultResourceManager;

#pragma mark - Import Mechanisms

- (void)importRecordCSVFiles:(NSArray *)csvFiles;
- (void)importFormationCSVFiles:(NSArray *)csvFiles;
- (void)importFeedbackCSVFiles:(NSArray *)csvFiles;

@end
