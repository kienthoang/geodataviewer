//
//  Group+Creation.m
//  GeoDataViewer
//

//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group+Creation.h"
#import "Group+DictionaryKeys.h"
#import "TextInputFilter.h"

@implementation Group (Creation)

+ (Group *)studentGroupForInfo:(NSDictionary *)groupInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Extract the id
    Group *selectedGroup=nil;
    NSString *groupID=[groupInfo objectForKey:GDVStudentGroupIdentifier];
    
    NSLog(@"groupID:%@!",groupID);
    
    //Grabs all groups from the database to compare ids (faster than letting the database compare the ids itself)
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    for (Group *group in results) {
        if ([group.identifier isEqualToString:groupID]) {
            selectedGroup=group;
            break;
        }
    }
    
    if (!selectedGroup) {
        //Create a new student group
        selectedGroup=[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        selectedGroup.identifier=groupID;
        selectedGroup.name=[groupInfo objectForKey:GDVStudentGroupName];
        selectedGroup.faulty=[groupInfo objectForKey:GDVStudentGroupIsFaulty];
    }
        
    return selectedGroup;
}

@end
