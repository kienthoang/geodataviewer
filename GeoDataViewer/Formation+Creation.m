//
//  Formation+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Creation.h"

@implementation Formation (Creation)

+ (Formation *)formationWithName:(NSString *)formationName inManagedObjectContext:(NSManagedObjectContext *)context 
{    
    Formation *formation=nil;
    
    //Look for a formation with the given name in the database
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Formation"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (results.count)
        formation=results.lastObject;
    else {
        //If no such formation exists, create one
        Formation_Folder *folder=[Formation_Folder defaultFormationFolderInManagedObjectContext:context];
        formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
        formation.formationName=formationName;
        formation.formationSortNumber=[NSNumber numberWithInt:folder.formations.count+1];
        formation.formationFolder=folder;
    }
#warning Set default color for imported formations
    
    return formation;
}

@end
