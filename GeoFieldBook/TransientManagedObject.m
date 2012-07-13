//
//  TransientManagedObject.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientManagedObject.h"

@implementation TransientManagedObject

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    NSLog(@"Subclass of TransientManagedObject should override this method.");
}

@end
