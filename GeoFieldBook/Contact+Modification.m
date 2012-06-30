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

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo {
    [super updateWithNewRecordInfo:recordInfo];
    
    NSFetchRequest *request=nil;
    NSArray *results=nil;
    
    //If the lower formation name is an empty string, nillify this record's lower formation
    NSString *lowerFormationName=[recordInfo objectForKey:RECORD_LOWER_FORMATION];
    if (!lowerFormationName.length)
        self.lowerFormation=nil;
    
    //Else, update the lower formation if it exists in database
    else {
        request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",lowerFormationName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        if ([results count]) {
            Formation *lowerFormation=[results lastObject];
            self.lowerFormation=lowerFormation;
        }
    }
     
    //If the lower formation name is an empty string, nillify this record's lower formation
    NSString *upperFormationName=[recordInfo objectForKey:RECORD_UPPER_FORMATION];
    if (!upperFormationName.length)
        self.upperFormation=nil;
    
    //Else, update the upper formation if it exists in database
    else {
        request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",upperFormationName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        if ([results count]) {
            Formation *upperFormation=[results lastObject];
            self.upperFormation=upperFormation;
        }    
    }
}

@end
