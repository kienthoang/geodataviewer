//
//  GDVResourceManager.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVResourceManager.h"

@implementation GDVResourceManager

@synthesize database=_database;
@synthesize engine=_engine;
@synthesize server=_server;

static GDVResourceManager *defaultResourceManager;

+ (void)initialize {
    [super initialize];
    
    //Initialize the singleton
    if (!defaultResourceManager)
        defaultResourceManager=[[GDVResourceManager alloc] init];
}

+ (GDVResourceManager *)defaultResourceManager {
    return defaultResourceManager;
}

- (id)init {
    if (self=[super init]) {
        //Initialize the database
        GDVResourceManager *weakSelf=self;
        GeoDatabaseManager *databaseManager=[GeoDatabaseManager standardDatabaseManager];
        [databaseManager fetchDatabaseFromDisk:self completion:^(UIManagedDocument *database){
            weakSelf.database=database;
        }];
    }
    
    return self;
}

#pragma mark - Getters and Setters

- (GDVIEEngine *)engine {
    if (!_engine)
        _engine=[[GDVIEEngine alloc] init];
    
    return _engine;
}

- (GDVServerCommunicator *)server {
    if (!_server)
        _server=[[GDVServerCommunicator alloc] init];
    
    return _server;
}

@end
