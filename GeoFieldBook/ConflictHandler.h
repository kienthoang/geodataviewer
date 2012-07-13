//
//  ConflictHandler.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConflictHandler : NSObject

@property (nonatomic, strong) UIManagedDocument *database;

- (BOOL)handleConflictsForArray:(NSArray *) items;

@end
