//
//  GeoDatabaseManager.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoDatabaseManager.h"

@interface GeoDatabaseManager()

- (void)synchronizeWithMainDatabase;                                    //synchronize the database with the main database
- (void)createMainDatabaseWithURL:(NSURL *)databaseURL;                  //create the main database if it does not exist on disk

@property (nonatomic,strong) database_completion_handler_t completionBlockForFetchingDatabase;

@end

@implementation GeoDatabaseManager

@synthesize mainDatabase=_mainDatabase;
@synthesize completionBlockForFetchingDatabase=_completionBlockForFetchingDatabase;

static GeoDatabaseManager *standardDatabaseManager;

+ (void)initialize {
    [super initialize];
    
    //Set up the singleton instance
    if (!standardDatabaseManager)
        standardDatabaseManager=[[GeoDatabaseManager alloc] init];
}

+ (GeoDatabaseManager *)standardDatabaseManager {
    return standardDatabaseManager;
}

//Designate initializer for the manager
- (GeoDatabaseManager *)init {
    if (self=[super init]) {
        //Synchronize with the database
        [self synchronizeWithMainDatabase];
    }
    
    return self;
}

- (NSURL *)appSupportDirectoryURL {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *appSupportDirURL=[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    if (![fileManager fileExistsAtPath:appSupportDirURL.path])
        [fileManager createDirectoryAtPath:appSupportDirURL.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return appSupportDirURL;
}

- (NSURL *)databaseURL {
    NSURL *appSupportDirURL=self.appSupportDirectoryURL;
    NSURL *databaseURL=[appSupportDirURL URLByAppendingPathComponent:DATABASE_FILE_LOCALIZED_NAME];
    return databaseURL;
}

- (void)createMainDatabaseWithURL:(NSURL *)databaseURL {
    //Create a UIManagedDocument with the database URL and save it first before keeping it as a property in case the user accesses the property in the middle of the saving process
    UIManagedDocument *mainDatabase=[[UIManagedDocument alloc] initWithFileURL:databaseURL];
    __weak GeoDatabaseManager *weakSelf=self;
    [mainDatabase saveToURL:databaseURL
                   forSaveOperation:UIDocumentSaveForCreating 
                  completionHandler:^(BOOL success){
                      if (success) {
                          weakSelf.mainDatabase=mainDatabase;
                          
                          //Execute any waiting completion handler
                          if (self.completionBlockForFetchingDatabase)
                              self.completionBlockForFetchingDatabase(mainDatabase);
                      } else {
                          //Execute any waiting completion handler
                          if (self.completionBlockForFetchingDatabase)
                              self.completionBlockForFetchingDatabase(nil);
                      }
                      
                      //Nillify any waiting completion handler
                      self.completionBlockForFetchingDatabase=nil;
                  }];
}

//Synchronize with the main database of the app
- (void)synchronizeWithMainDatabase {
    //If the main database doesn't exist on disk yet, create it
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *databaseURL=self.databaseURL;
    if (![fileManager fileExistsAtPath:databaseURL.path]) {
        //Create the main database
        [self createMainDatabaseWithURL:databaseURL];
    }
    
    //Else if it already exists, assign it to the property geoFieldBookDatabase
    else {
        self.mainDatabase=[[UIManagedDocument alloc] initWithFileURL:databaseURL];
    }
}

//Fetch the database
- (void)fetchDatabaseFromDisk:(id)sender completion:(database_completion_handler_t)completionBlock {
    UIManagedDocument *mainDatabase=self.mainDatabase;
    
    if (self.mainDatabase) {
        if (mainDatabase.documentState==UIDocumentStateClosed) {
            [mainDatabase openWithCompletionHandler:^(BOOL success){
                completionBlock(mainDatabase);
            }];
        } else if (mainDatabase.documentState==UIDocumentStateNormal) {
            completionBlock(mainDatabase);
        }
    } else {
        self.completionBlockForFetchingDatabase=completionBlock;
    }
}

@end
