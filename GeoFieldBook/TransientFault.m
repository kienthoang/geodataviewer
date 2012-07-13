//
//  TransientFault.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFault.h"

@implementation TransientFault

@synthesize plunge;
@synthesize trend;
@synthesize formation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create a fault record
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"Fault" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formation
    //[(JointSet *)self.nsManagedRecord setFormation:self.formation];
    
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}

@end
