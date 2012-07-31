//
//  Fault.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/19/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Record.h"

@class Formation;

@interface Fault : Record

@property (nonatomic, retain) NSNumber * plunge;
@property (nonatomic, retain) NSNumber * trend;
@property (nonatomic, retain) Formation *formation;

@end
