//
//  Formation+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Creation.h"

@implementation Formation (Creation)

+ (Formation *)formationForName:(NSString *)formationName 
      inFormationFolderWithName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Query for a formation with the specified name, if it exists, return nil
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",formationName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if ([results count] || !results)
        return nil;
    
    //Query for the folder with the specified name, if it does not exist return nil
    request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    results=[context executeFetchRequest:request error:NULL];
    if (![results count])
        return nil;
    
    //Create a new formation
    Formation_Folder *formationFolder=[results lastObject];
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=formationName;
    formation.formationFolder=formationFolder;
    
    return formation;
}

@end
