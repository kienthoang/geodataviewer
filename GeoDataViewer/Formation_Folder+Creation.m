//
//  Formation_Folder+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder+Creation.h"
#import "TextInputFilter.h"

@implementation Formation_Folder (Creation)

+ (Formation_Folder *)formationFolderForName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)context {
    Formation_Folder *formationFolder=nil;
    
    //Filter folder name
    folderName=[TextInputFilter filterDatabaseInputText:folderName];
    
    //Query to see if there is any Formation Folder in the database with the same name
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    //if there result or results is nil, handle error
    if (!results || [results count]) {
        //handle errors
    }
    
    //Else, create a new formation folder
    else {
        formationFolder=[NSEntityDescription insertNewObjectForEntityForName:@"Formation_Folder" inManagedObjectContext:context];
        formationFolder.folderName=folderName;
    }
    
    return formationFolder;
}

@end
