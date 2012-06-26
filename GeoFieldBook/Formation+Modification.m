//
//  Formation+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Modification.h"

@implementation Formation (Modification)

- (BOOL)changeFormationNameTo:(NSString *)formationName {
    //Query the database to see if the any formation with the new name already exists
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",formationName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is one result, return NO
    if ([results count])
        return NO;
    
    self.formationName=formationName;
    
    return YES;
}

@end
