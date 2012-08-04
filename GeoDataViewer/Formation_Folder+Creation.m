//
//  Formation_Folder+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder+Creation.h"

@implementation Formation_Folder (Creation)

+ (Formation_Folder *)defaultFormationFolderInManagedObjectContext:(NSManagedObjectContext *)context {
    Formation_Folder *folder=nil;
    
    //Query for the folder with the same name before creation
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",DEFAULT_FORMATION_FOLDER_NAME];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    if (results.count)
        folder=results.lastObject;
    else {
        //Create a new folder with the default name
        folder=[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
        folder.folderName=DEFAULT_FORMATION_FOLDER_NAME;
    }
    
    return folder;
}


@end
