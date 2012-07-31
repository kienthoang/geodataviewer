//
//  Formation+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Creation.h"

#import "Formation+DictionaryKeys.h"

#import "TextInputFilter.h"

@implementation Formation (Creation)

+ (Formation *)formationForInfo:(NSDictionary *)formationInfo 
      inFormationFolderWithName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Get the formation name and color from the info dictionary
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    NSString *colorName=[formationInfo objectForKey:GeoFormationColorName];

    //Query for the folder with the specified name, if it does not exist return nil
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (!results.count)
        return nil;
    
    //Else get the formation folder
    Formation_Folder *formationFolder=results.lastObject;
    
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
    formation.colorName=colorName;
    
    return formation;
}

@end
