//
//  GeoDatabaseManager.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoDatabaseManager : NSObject

+ (GeoDatabaseManager *)standardDatabaseManager;   //Return the singleton instance of this class

typedef void (^completion_handler_t)(BOOL success);

- (UIManagedDocument *)fetchDatabaseFromDisk:(id)sender completion:(completion_handler_t)completionBlock;

@property (nonatomic,strong) UIManagedDocument *geoFieldBookDatabase;      //Return the UIManagedDocument for the entire database, which will be shared throughout the app

@property (nonatomic,readonly) NSURL *appSupportDirectoryURL;
@property (nonatomic,readonly) NSURL *databaseURL;

#define DATABASE_FILE_LOCALIZED_NAME @"GeoFieldBook_Database"

@end
