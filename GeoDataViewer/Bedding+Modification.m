//
//  Bedding+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Bedding+Modification.h"
#import "Formation.h"
#import "Record+DictionaryKeys.h"
#import "Record+Modification.h"

@implementation Bedding (Modification)

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo {
    [super updateWithNewRecordInfo:recordInfo];
    
    NSString *formationName=[recordInfo objectForKey:RECORD_FORMATION];
    
    //If the formation name is empty, nillify the formation of this record
    if (![formationName length])
        self.formation=nil;
    
    //Else, update the formation if it exists in database
    else {
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",formationName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        if ([results count]) {
            Formation *formation=[results lastObject];
            self.formation=formation;
        }
    }
}

@end
