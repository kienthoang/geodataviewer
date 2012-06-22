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

@property (nonatomic,strong) UIManagedDocument *geoFieldBookDatabase;      //Return the UIManagedDocument for the entire database, which will be shared throughout the app

#define DATABASE_FILE_LOCALIZED_NAME @"GeoFieldBook_Database"

@end
