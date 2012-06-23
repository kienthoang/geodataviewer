//
//  Contact+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Contact+Modification.h"
#import "Formation.h"
#import "Record+DictionaryKeys.h"
#import "Record+Modification.h"

@implementation Contact (Modification)

- (BOOL)updateWithNewRecordInfo:(NSDictionary *)recordInfo {
    [super updateWithNewRecordInfo:recordInfo];
    
    //Update the lower formation if it exists in database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",[recordInfo objectForKey:RECORD_LOWER_FORMATION]];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    if ([results count]) {
        Formation *lowerFormation=[results lastObject];
        self.lowerFormation=lowerFormation;
    } else {
        return false;
    }
    
    //Update the upper formation if it exists in database
    request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",[recordInfo objectForKey:RECORD_UPPER_FORMATION]];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    if ([results count]) {
        Formation *upperFormation=[results lastObject];
        self.upperFormation=upperFormation;
    } else {
        return false;
    }
    
    return true;
}

@end
