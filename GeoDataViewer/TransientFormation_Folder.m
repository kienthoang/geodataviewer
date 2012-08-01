//
//  TransientFormation_Folder.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFormation_Folder.h"

@interface TransientFormation_Folder()

@end

@implementation TransientFormation_Folder

@synthesize folderName;
@synthesize formations;
@synthesize folders;

@synthesize managedFormationFolder=_managedFormationFolder;

+ (Formation_Folder *)defaultFolderManagedObjectContext:(NSManagedObjectContext *)context {
    //Query for the folder with the same name before saving
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",DEFAULT_FORMATION_FOLDER_NAME];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    if (results.count)
        return results.lastObject;
    
    //Save folder
    TransientFormation_Folder *folder=[[TransientFormation_Folder alloc] init];
    folder.folderName=DEFAULT_FORMATION_FOLDER_NAME;
    [folder saveToManagedObjectContext:context completion:^(NSManagedObject *folder){}];
    return folder.managedFormationFolder;
}

- (Formation_Folder *)saveFormationFolderToManagedObjectContext:(NSManagedObjectContext *)context 
                                                     completion:(completion_handler_t)completionHandler
{
    //Query to see if the formation folder is already in the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",self.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (results.count)
        return results.lastObject;
    
    //Save to database otherwise
    [self saveToManagedObjectContext:context completion:completionHandler];
    return self.managedFormationFolder;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert into the database
    self.managedFormationFolder=[NSEntityDescription insertNewObjectForEntityForName:@"Formation_Folder" inManagedObjectContext:context];
    self.managedFormationFolder.folderName=self.folderName;
}

@end
