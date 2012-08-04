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

#import "GDVResourceManagerNotificationNames.h"

#import "Group.h"
#import "Folder.h"
#import "Record.h"
#import "Formation_Folder.h"
#import "Formation.h"
#import "Answer.h"

@interface GDVResourceManager : NSObject

@property (nonatomic,strong) UIManagedDocument *database;

@property (nonatomic,strong) GDVIEEngine *engine;
@property (nonatomic,strong) GDVServerCommunicator *server;

+ (GDVResourceManager *)defaultResourceManager;

#pragma mark - Import Mechanisms

- (void)importRecordCSVFiles:(NSArray *)csvFiles;
- (void)importFormationCSVFiles:(NSArray *)csvFiles;
- (void)importFeedbackCSVFiles:(NSArray *)csvFiles;

#pragma mark - Data

typedef void (^data_completion_handler_t)(NSArray *data);

- (void)fetchStudentGroupsWithCompletionHandler:(data_completion_handler_t)completionHandler;
- (void)fetchFoldersForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler;
- (void)fetchRecordsForFolder:(Folder *)folder completion:(data_completion_handler_t)completionHandler;
- (void)fetchFormationFoldersWithCompletionHandler:(data_completion_handler_t)completionHandler;
- (void)fetchFormationsForFormationFolder:(Formation_Folder *)formationFolder completion:(data_completion_handler_t)completionHandler;
- (void)fetchStudentResponsesForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler;

@end
