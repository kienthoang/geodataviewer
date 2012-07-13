//
//  TransientContact.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientContact.h"

@implementation TransientContact

@synthesize lowerFormation=_lowerFormation;
@synthesize upperFormation=_upperFormation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create a contact record
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formation
    [(Contact *)self.nsManagedRecord setLowerFormation:[self.lowerFormation saveFormationToManagedObjectContext:context]];
    [(Contact *)self.nsManagedRecord setUpperFormation:[self.upperFormation saveFormationToManagedObjectContext:context]];
    
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}

@end
