//
//  Group+Creation.m
//  GeoDataViewer
//
//  Created by excel 2011 on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group+Creation.h"
#import "Group+DictionaryKeys.h"
#import "TextInputFilter.h"

@implementation Group (Creation)

+(Group *)groupWithGroupInfo:(NSDictionary *)info
      inManagedObjectContext:(NSManagedObjectContext *)context {
    
    //Get info out of the dictionary
    NSString *groupName=[TextInputFilter filterDatabaseInputText:[info objectForKey:GROUP_NAME]];
    NSString *groupID=[TextInputFilter filterDatabaseInputText:[info objectForKey:GROUP_ID]];
    
    //Query the database for the group with group name
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate=[NSPredicate predicateWithFormat:@"identifier=%@",groupID];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    
    Group *group=nil;
    //If there is result or the result array is nil, handle errors
    if ([results count] || !results) {
        //handle errors
    }
    
    //If there is no result, create a new folder
    else {
        //Insert a folder entity into the database
        group=[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        group.name=groupName;
        group.identifier=groupID;
    }
    
    return group;
    
}

@end
