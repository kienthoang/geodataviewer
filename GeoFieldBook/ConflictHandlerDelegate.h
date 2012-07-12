//
//  ConflictHandlerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/12/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConflictHandler.h"

@class ConflictHandler;

@protocol ConflictHandlerDelegate <NSObject>

- (void)conflictHandler:(ConflictHandler *)sender conflictDidHappenWithProjectss:(NSArray *)folders;
- (void)conflictHandler:(ConflictHandler *)sender conflictDidHappenWithFormationFolders:(NSArray *)formationfolders;

@end
