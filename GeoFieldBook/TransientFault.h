//
//  TransientFault.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
#import "TransientFormation.h"

#import "Fault.h"

@interface TransientFault : TransientRecord
@property (nonatomic, retain) NSNumber * plunge;
@property (nonatomic, retain) NSNumber * trend;
@property (nonatomic, retain) TransientFormation *formation;

- (NSString *)setPlungeWithValidations:(NSString *)plungeString;

- (NSString *)setTrendWithValidations:(NSString *)trendString;

@end
