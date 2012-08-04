//
//  GDVResourceManager.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVResourceManager.h"

@interface GDVResourceManager() <GDVIEEngineDelegate>

@end

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
        GeoDatabaseManager *databaseManager=[GeoDatabaseManager standardDatabaseManager];
        self.database=[databaseManager fetchDatabaseFromDisk:self completion:^(BOOL success){}];
        
        if (self.database.documentState==UIDocumentStateClosed) {
            [self.database openWithCompletionHandler:^(BOOL success){}];
        }
    }
    
    return self;
}

#pragma mark - Getters and Setters

- (GDVIEEngine *)engine {
    if (!_engine) {
        _engine=[[GDVIEEngine alloc] init];
        
        //Setup the enging
        _engine.database=self.database;
        _engine.delegate=self;
    }
        
    return _engine;
}

- (GDVServerCommunicator *)server {
    if (!_server)
        _server=[[GDVServerCommunicator alloc] init];
    
    return _server;
}

#pragma mark - Import Mechanisms

- (void)importRecordCSVFiles:(NSArray *)csvFiles {
    //Import the record csv files
    [self.engine createRecordsFromCSVFiles:csvFiles];
}

- (void)importFormationCSVFiles:(NSArray *)csvFiles {
    //Import the formation csv files
    [self.engine createFormationsFromCSVFiles:csvFiles];
}

- (void)importFeedbackCSVFiles:(NSArray *)csvFiles {
    //Import the record csv files
    [self.engine createFeedbacksFromCSVFiles:csvFiles];
}

#pragma mark - Notification Management Mechanisms

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

#pragma mark - GDVIEEngineDelegate Protocol Methods

- (void)engineDidFinishProcessingRecords:(GDVIEEngine *)engine {
    //Post notification
    [self postNotificationWithName:GDVResourceManagerRecordDatabaseDidUpdate withUserInfo:[NSDictionary dictionary]];
}

- (void)engineDidFinishProcessingFormations:(GDVIEEngine *)engine {
    //Post notification
    [self postNotificationWithName:GDVResourceManagerFormationDatabaseDidUpdate withUserInfo:[NSDictionary dictionary]];
}

- (void)engineDidFinishProcessingStudentResponses:(GDVIEEngine *)engine {
    //Post notification
    [self postNotificationWithName:GDVResourceManagerStudentResponseDatabaseDidUpdate withUserInfo:[NSDictionary dictionary]];
}

#pragma mark - Data

- (void)fetchStudentGroupsWithCompletionHandler:(data_completion_handler_t)completionHandler {
    //Fetch all the student group in the database
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    NSLog(@"Database: %@ Results: %@",self.database,results);
    completionHandler(results);
}

- (void)fetchFoldersForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler {
    
}

- (void)fetchRecordsForFolder:(Folder *)folder completion:(data_completion_handler_t)completionHandler {
    
}

- (void)fetchFormationFoldersWithCompletionHandler:(data_completion_handler_t)completionHandler {
    
}

- (void)fetchFormationsForFormationFolder:(Formation_Folder *)formationFolder completion:(data_completion_handler_t)completionHandler {
    
}

- (void)fetchStudentResponsesForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler {
    
}

@end
