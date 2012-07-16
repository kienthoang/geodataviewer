//
//  IEEngine.h
//  GeoFieldBook
//
//  Created by excel 2012 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConflictHandler.h"


@interface IEEngine : NSObject

@property (nonatomic, strong) ConflictHandler *handler;

-(void) createRecordsFromCSVFiles:(NSArray *)files; //passes the array of records to the ConflictaHandler
-(void) createFormationsFromCSVFiles:(NSArray *)files; //passes the array of formations to the ConflictHandler
-(void) createCSVFilesFromRecords:(NSArray *)records;
-(void) createCSVFilesFromFormations:(NSArray *)formations;

#define NUMBER_OF_COLUMNS_PER_RECORD_LINE 16

@end
