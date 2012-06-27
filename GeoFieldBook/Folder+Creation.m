//
//  Folder+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Creation.h"
#import "Folder+DictionaryKeys.h"

@implementation Folder (Creation)

+ (Folder *)folderWithInfo:(NSDictionary *)folderInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Get info out of the dictionary
    NSString *folderName=[folderInfo objectForKey:FOLDER_NAME];
    NSString *folderDescription=[folderInfo objectForKey:FOLDER_DESCRIPTION];
    
    //Query the database for the folder with folder name
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    
    Folder *folder=nil;
    //If there is result or the result array is nil, handle errors
    if ([results count] || !results) {
        //handle errors
    }
    
    //If there is no result, create a new folder
    else {
        //Insert a folder entity into the database
        folder=[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
        folder.folderName=folderName;
        folder.folderDescription=folderDescription;
    }
    
    return folder;
}

@end
