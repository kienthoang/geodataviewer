//
//  GDVTransientDataProcessor.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDVTransientDataProcessorDelegate.h"

@interface GDVTransientDataProcessor : NSObject

@property (nonatomic,weak) id<GDVTransientDataProcessorDelegate> delegate;

-(void) updateDatabaseWithRecords:(NSArray *)records withFolders:(NSArray *)folders withGroups:(NSArray *) groups;

-(void) updateDatabaseWithFormations:(NSArray *)formations withFormationFolders:(NSArray *)formationFolders;



@end
