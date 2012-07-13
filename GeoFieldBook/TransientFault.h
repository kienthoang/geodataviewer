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
@property (nonatomic, retain) NSString * plunge;
@property (nonatomic, retain) NSString * trend;
@property (nonatomic, retain) TransientFormation *formation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler;

@end
