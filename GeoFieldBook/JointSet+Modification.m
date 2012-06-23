//
//  JointSet+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "JointSet+Modification.h"
#import "Formation.h"
#import "Record+DictionaryKeys.h"
#import "Record+Modification.h"

@implementation JointSet (Modification)

- (BOOL)updateWithNewRecordInfo:(NSDictionary *)recordInfo {
    [super updateWithNewRecordInfo:recordInfo];
    
    //Update the formation if it exists in database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",[recordInfo objectForKey:RECORD_FORMATION]];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    if ([results count]) {
        Formation *formation=[results lastObject];
        self.formation=formation;
    } else {
        return false;
    }
    
    return true;
}

@end
