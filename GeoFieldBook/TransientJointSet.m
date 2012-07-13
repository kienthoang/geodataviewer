//
//  TransientJointSet.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientJointSet.h"

@implementation TransientJointSet

@synthesize formation=_formation;

#pragma mark - Database Operations

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create  a joint set
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"JointSet" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formation
    [(JointSet *)self.nsManagedRecord setFormation:[self.formation saveFormationToManagedObjectContext:context]];
    
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}

@end
