//
//  GDVIEEngine.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDVTransientDataProcessor.h"

@interface GDVIEEngine : NSObject

+ (GDVIEEngine *)engineWithDataProcessor:(GDVTransientDataProcessor *)processor;

@property (nonatomic,strong) GDVTransientDataProcessor *processor;

#pragma mark - Import

- (void)createRecordsFromCSVFiles:(NSArray *)files; //passes the array of records
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files; //this reads the new version of formation files with colors.
- (void)createFormationsFromCSVFiles:(NSArray *)files; //passes the array of formations
- (void)createFeedbacksFromCSVFiles:(NSArray *)files; //passes the array of feedbacks

#define NUMBER_OF_COLUMNS_PER_RECORD_LINE 16
#define GROUP_INFO_HEADER @"Group Information"

@end
