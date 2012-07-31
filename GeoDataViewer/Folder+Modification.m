//
//  Folder+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Modification.h"
#import "Folder+DictionaryKeys.h"

@implementation Folder (Modification)

- (BOOL)updateWithNewInfo:(NSDictionary *)newInfo {
    //Get the info out of the info dictionary
    NSString *newName=[newInfo objectForKey:FOLDER_NAME];
    NSString *folderDescription=[newInfo objectForKey:FOLDER_DESCRIPTION];
    
   //if the new name is different from the old name, check for name duplication
    if (![newName isEqualToString:self.folderName]) {
        //Query the database to see if the any folder with the new name already exists
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
        request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",newName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
        NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
        
        //if there is one result and the name, return NO
        if ([results count])
            return NO;
    }
    
    //Update the folder
    self.folderName=newName;
    self.folderDescription=folderDescription;
    
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
