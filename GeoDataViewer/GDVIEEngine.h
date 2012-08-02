//
//  GDVIEEngine.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDVIEEngine : NSObject

#pragma mark - Import

- (void)createRecordsFromCSVFiles:(NSArray *)files; //passes the array of records to the ConflictaHandler
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files; //this reads the new version of formation files with colors.
- (void)createFormationsFromCSVFiles:(NSArray *)files; //passes the array of formations to the ConflictHandler

#define NUMBER_OF_COLUMNS_PER_RECORD_LINE 16

@end
