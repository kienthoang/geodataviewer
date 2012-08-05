//
//  GDVIEEngine.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Group.h"
#import "Group+Creation.h"
#import "Folder.h"
#import "Folder+Creation.h"
#import "Record.h"
#import "Formation_Folder.h"
#import "Formation.h"
#import "Answer.h"

#import "GDVIEEngineDelegate.h"

@interface GDVIEEngine : NSObject

typedef void(^save_completion_handler_t)(BOOL success);


@property (nonatomic,strong) UIManagedDocument *database;
@property (nonatomic,weak) id <GDVIEEngineDelegate> delegate;

#pragma mark - Import

- (void)createRecordsFromCSVFiles:(NSArray *)files; //passes the array of records
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files; //this reads the new version of formation files with colors.
- (void)createFormationsFromCSVFiles:(NSArray *)files; //passes the array of formations
- (void)createFeedbacksFromCSVFiles:(NSArray *)files; //passes the array of feedbacks

#define NUMBER_OF_COLUMNS_PER_RECORD_LINE 16
#define METADATA_HEADER @">>>>>> Metadata <<<<<<<"

@end
