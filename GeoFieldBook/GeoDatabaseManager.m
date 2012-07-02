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

@property (nonatomic,strong) completion_handler_t completionBlockForFetchingDatabase;

@end

@implementation GeoDatabaseManager

@synthesize geoFieldBookDatabase=_geoFieldBookDatabase;
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

- (void)createMainDatabaseWithURL:(NSURL *)databaseURL {
    //Create a UIManagedDocument with the database URL and save it first before keeping it as a property in case the user accesses the property in the middle of the saving process
    self.geoFieldBookDatabase=[[UIManagedDocument alloc] initWithFileURL:databaseURL];
    [self.geoFieldBookDatabase saveToURL:databaseURL
                   forSaveOperation:UIDocumentSaveForCreating 
                  completionHandler:^(BOOL success){
                      if (success) {
                          if (self.completionBlockForFetchingDatabase)
                              self.completionBlockForFetchingDatabase(YES);
                      } else {
                          //handle errors
                          NSLog(@"Failed: %@",self.geoFieldBookDatabase);
                          if (self.completionBlockForFetchingDatabase)
                              self.completionBlockForFetchingDatabase(NO);
                      }
                  }];
}

//Synchronize with the main database of the app
- (void)synchronizeWithMainDatabase {
    //If the main database doesn't exist on disk yet, create it
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *databaseURL=[documentDirURL URLByAppendingPathComponent:DATABASE_FILE_LOCALIZED_NAME];
    if (![fileManager fileExistsAtPath:[databaseURL path]]) {
        //Create the main database
        [self createMainDatabaseWithURL:databaseURL];
    }
    
    //Else if it already exists, assign it to the property geoFieldBookDatabase
    else {
        self.geoFieldBookDatabase=[[UIManagedDocument alloc] initWithFileURL:databaseURL];
    }
}

//Fetch the database
- (UIManagedDocument *)fetchDatabaseFromDisk:(id)sender completion:(completion_handler_t)completionBlock {
    //Save the completion block
    self.completionBlockForFetchingDatabase=completionBlock;
    
    return self.geoFieldBookDatabase;
}

@end
