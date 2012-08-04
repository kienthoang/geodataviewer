//
//  Group+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group+Creation.h"

@implementation Group (Creation)

+ (Group *)studentGroupForInfo:(NSDictionary *)groupInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Extract the id
    NSString *groupID=[groupInfo objectForKey:GDVStudentGroupIdentifier];
    
    //Grabs all groups from the database to compare ids (faster than letting the database compare the ids itself)
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    for (Group *group in results) {
        if ([group.identifier isEqualToString:groupID])
            return group;
    }
    
    //Create a new student group
    Group *group=[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    group.name=[groupInfo objectForKey:GDVStudentGroupName];
    group.faulty=[groupInfo objectForKey:GDVStudentGroupIsFaulty];
    
    return group;
}

@end
