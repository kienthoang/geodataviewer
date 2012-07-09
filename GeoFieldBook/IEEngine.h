//
//  IEEngine.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IEConflictHandler.h"


@interface IEEngine : NSObject

@property (nonatomic, strong) IEConflictHandler *handler;

-(void) createRecordsFromCSVFiles:(NSArray *) files;
-(void) createFormationsFromCSVFiles:(NSArray *) files;

@end
