//
//  Formation+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Creation.h"
#import "TextInputFilter.h"

@implementation Formation (Creation)

+ (Formation *)formationForName:(NSString *)formationName 
      inFormationFolderWithName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Filter formation and folder names
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    folderName=[TextInputFilter filterDatabaseInputText:folderName];
    
    //Query for the folder with the specified name, if it does not exist return nil
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (![results count])
        return nil;
    
    Formation_Folder *formationFolder=[results lastObject];
    
    //Query for a formation with the specified name, if it exists, return nil
    request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@ && formationFolder.folderName=%@",formationName,folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    results=[context executeFetchRequest:request error:NULL];
    if ([results count] || !results)
        return nil;
    
    //Create a new formation
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=formationName;
    formation.formationFolder=formationFolder;
    
    return formation;
}

@end
