//
//  Fault.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Record.h"

@class Formation;

@interface Fault : Record

@property (nonatomic, retain) NSString * plunge;
@property (nonatomic, retain) NSString * trend;
@property (nonatomic, retain) Formation *formation;

@end
