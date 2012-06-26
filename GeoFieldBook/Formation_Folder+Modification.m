//
//  Formation_Folder+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder+Modification.h"

@implementation Formation_Folder (Modification)

- (BOOL)changeFormationFolderNameTo:(NSString *)newName {
    //Query the database to see if the any formation folder with the new name already exists
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",newName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is one result, return NO
    if ([results count])
        return NO;
    
    self.folderName=newName;
    return YES;
}

@end
