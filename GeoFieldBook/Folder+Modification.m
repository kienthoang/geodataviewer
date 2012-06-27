//
//  Folder+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Modification.h"

@implementation Folder (Modification)

- (BOOL)changeFolderNameTo:(NSString *)newName {
    //Query the database to see if the any folder with the new name already exists
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",newName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is one result, return NO
    if ([results count])
        return NO;
    
    self.folderName=newName;
    return YES;
}

- (BOOL)setFormationFolderWithName:(NSString *)formationFolder 
{
    //Query for the formation folder with the specified name
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",formationFolder];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is no formation folder with the specified name, return false
    if (![results count])
        return NO;
    
    //Change the formation folder of the folder
    self.formationFolder=[results lastObject];
    
    return YES;
}

@end
