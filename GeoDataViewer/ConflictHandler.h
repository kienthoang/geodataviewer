//
//  ConflictHandler.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IEConflictHandlerNotificationNames.h"

@interface ConflictHandler : NSObject

typedef enum HandleOption {ConflictHandleReplace,ConflictHandleKeepBoth,ConflictHandleCancel} HandleOption;

@property (nonatomic, strong) UIManagedDocument *database;

- (void)processTransientRecords:(NSArray *)records 
                     andFolders:(NSArray *)folders 
       withValidationMessageLog:(NSArray *)validationLog;

- (void)processTransientFormations:(NSArray *)formations 
               andFormationFolders:(NSArray *)folders 
       withValidationMessageLog:(NSArray *)validationLog;

- (void)userDidChooseToHandleFolderNameConflictWith:(HandleOption)handleOption;
- (void)userDidChooseToHandleFormationFolderNameConflictWith:(HandleOption)handleOption;

#pragma mark - Duplicate Temporary Data

@property (nonatomic,strong) NSArray *transientRecords;
@property (nonatomic,strong) NSArray *transientFolders;

@property (nonatomic,strong) NSArray *transientFormations;
@property (nonatomic,strong) NSArray *transientFormationFolders;

@property (nonatomic,strong) NSString *duplicateFolderName;
@property (nonatomic,strong) NSString *duplicateFormationFolderName;

@end
