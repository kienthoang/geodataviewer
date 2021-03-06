//
//  Formation_Folder+Creation.m
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
    
    //if there exists such a formation folder, return it
    if (results.count) {
        formationFolder=results.lastObject;
    }
    
    //Else, create a new formation folder
    else {
        formationFolder=[NSEntityDescription insertNewObjectForEntityForName:@"Formation_Folder" inManagedObjectContext:context];
        formationFolder.folderName=folderName;
    }
    
    return formationFolder;
}

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
        folder=[NSEntityDescription insertNewObjectForEntityForName:@"Formation_Folder" inManagedObjectContext:context];
        folder.folderName=DEFAULT_FORMATION_FOLDER_NAME;
    }
        
    return folder;
}


@end
