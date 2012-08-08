//
//  GDVResourceManager.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVResourceManager.h"

#import "TextInputFilter.h"
#import "Formation+Modification.h"

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

#pragma mark - Alert Generators

- (void)putUpAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    NSString *message=[NSString stringWithFormat:@"A formation with the name '%@' already exists in this folder!",duplicateName];
    [self putUpAlertWithTitle:@"Name Duplicate" andMessage:message];
}

#pragma mark - Import Mechanisms

- (void)importRecordCSVFiles:(NSArray *)csvFiles {
    //Import the record csv files
    [self.engine createRecordsFromCSVFiles:csvFiles];
}

- (void)importFormationCSVFiles:(NSArray *)csvFiles {
    //Import the formation csv files
    [self.engine createFormationsWithColorFromCSVFiles:csvFiles];
}

- (void)importStudentResponseCSVFiles:(NSArray *)csvFiles {
    //Import the record csv files
    [self.engine createStudentResponsesFromCSVFiles:csvFiles];
}

#pragma mark - Notification Management Mechanisms

- (void)postNotificationWithName:(NSString *)notificationName andUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

- (NSDictionary *)userInfoWithUpdateMechanism:(NSString *)updateMechanism {
    return [NSDictionary dictionaryWithObject:updateMechanism forKey:GDVResourceManagerUserInfoUpdateMechanismKey];
}

#pragma mark - GDVIEEngineDelegate Protocol Methods

- (void)engineDidFinishProcessingRecords:(GDVIEEngine *)engine {
    //Post notification
    NSDictionary *userInfo=[self userInfoWithUpdateMechanism:GDVResourceManagerUpdateByImporting];
    [self postNotificationWithName:GDVResourceManagerRecordDatabaseDidUpdate andUserInfo:userInfo];
}

- (void)engineDidFinishProcessingFormations:(GDVIEEngine *)engine {
    //Post notification
    NSDictionary *userInfo=[self userInfoWithUpdateMechanism:GDVResourceManagerUpdateByImporting];
    [self postNotificationWithName:GDVResourceManagerFormationDatabaseDidUpdate andUserInfo:userInfo];
}

- (void)engineDidFinishProcessingStudentResponses:(GDVIEEngine *)engine {
    //Post notification
    NSDictionary *userInfo=[self userInfoWithUpdateMechanism:GDVResourceManagerUpdateByImporting];
    [self postNotificationWithName:GDVResourceManagerStudentResponseDatabaseDidUpdate andUserInfo:userInfo];
}

#pragma mark - Data

- (void)fetchStudentGroupsWithCompletionHandler:(data_completion_handler_t)completionHandler {
    //Fetch all the student group in the database
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    completionHandler(results);
}

- (void)fetchFoldersForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler {
    //Fetch all the folders for the given student group
    [self fetchFoldersForStudentGroups:[NSArray arrayWithObject:studentGroup] scompletion:completionHandler];
}

- (void)fetchFoldersForStudentGroups:(NSArray *)studentGroups scompletion:(data_completion_handler_t)completionHandler {
    NSMutableArray *folders=[NSMutableArray array];
    
    //Take all the folders in the student groups
    for (Group *studentGroup in studentGroups) {
        BOOL faulty=studentGroup.faulty.boolValue;
        if (faulty) {
            //Data is faulty, fetch folders from server
        }
        else {
            [folders addObjectsFromArray:studentGroup.folders.allObjects];
        }
    }
    
    //Execute the completion handler
    completionHandler(folders.copy);
}

- (void)fetchRecordsForFolder:(Folder *)folder completion:(data_completion_handler_t)completionHandler {
    //Fetch all the folders for the given student group
    [self fetchRecordsForFolders:[NSArray arrayWithObject:folder] completion:completionHandler];
}

- (void)fetchRecordsForFolders:(NSArray *)folders completion:(data_completion_handler_t)completionHandler {
    NSMutableArray *records=[NSMutableArray array];
    
    //Take all the records in the groups
    for (Folder *folder in folders) {
        BOOL faulty=folder.faulty.boolValue;
        if (faulty) {
            //Data is faulty, fetch records from server
        }
        else {
            [records addObjectsFromArray:folder.records.allObjects];
        }
    }
    
    //Execute the completion handler
    completionHandler(records.copy);
}

- (void)fetchFormationFoldersWithCompletionHandler:(data_completion_handler_t)completionHandler {
    //Fetch all the formation folders in the database
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Formation_Folder"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    completionHandler(results);    
}

- (void)fetchFormationsForFormationFolder:(Formation_Folder *)formationFolder completion:(data_completion_handler_t)completionHandler {
    //Fetch all the formations for the given folder
    BOOL faulty=formationFolder.faulty.boolValue;
    if (faulty) {
        //Data is faulty, fetch formations from server
    }
    else {
        completionHandler(formationFolder.formations.allObjects);
    }
}

- (void)fetchStudentResponsesForStudentGroup:(Group *)studentGroup completion:(data_completion_handler_t)completionHandler {
    //Fetch all the student responses for the given student group
    [self fetchStudentResponsesForStudentGroups:[NSArray arrayWithObject:studentGroup] completion:completionHandler];
}

- (void)fetchStudentResponsesForStudentGroups:(NSArray *)studentGroups completion:(data_completion_handler_t)completionHandler {
    NSMutableArray *responses=[NSMutableArray array];
    
    //Take all the responses in the student groups
    for (Group *studentGroup in studentGroups) {
        BOOL faulty=studentGroup.faulty.boolValue;
        if (faulty) {
            //Data is faulty, fetch responses from server
        }
        else {
            [responses addObjectsFromArray:studentGroup.responses.allObjects];
        }
    }
    
    //Execute the completion handler
    completionHandler(responses.copy);
}

#pragma mark - Data Manipulators

typedef void (^database_save_t)(UIManagedDocument *database);

- (void)saveDatabaseWithCompletionHandler:(database_save_t)completionHandler {
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success)
            completionHandler(self.database);
        else
            NSLog(@"Failed to save changes to database!");
    }];
}

- (void)deleteStudentGroups:(NSArray *)studentGroups {
    //Destroy the given student groups
    for (Group *group in studentGroups)
        [self.database.managedObjectContext deleteObject:group];
    
    //Save changes to database
    [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){}];
}

- (BOOL)updateFormation:(Formation *)formation withNewInfo:(NSDictionary *)formationInfo {
    //Filter formation name
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    
    //Update the formation, if that returns NO (i.e. the update failed because of name duplication), put up an alert
    if (![formation updateFormationWithFormationInfo:formationInfo]) {
        [self putUpDuplicateNameAlertWithName:formationName];
        return NO;
    }
    
    //Save changes to database
    [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){
        //Broadcast changes
        NSDictionary *userInfo=[self userInfoWithUpdateMechanism:GDVResourceManagerUpdateByUser];
        [self postNotificationWithName:GDVResourceManagerFormationDatabaseDidUpdate andUserInfo:userInfo];
    }];
    
    return YES;
}

@end
