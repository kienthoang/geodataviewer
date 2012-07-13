//
//  TransientFormation_Folder.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFormation_Folder.h"

@interface TransientFormation_Folder()

@property (nonatomic,strong) Formation_Folder *managedFormationFolder;

@end

@implementation TransientFormation_Folder

@synthesize folderName;
@synthesize formations;
@synthesize folders;

@synthesize managedFormationFolder=_managedFormationFolder;

- (Formation_Folder *)saveFormationFolderToManagedObjectContext:(NSManagedObjectContext *)context 
                                                     completion:(completion_handler_t)completionHandler
{
    //Query to see if the formation folder is already in the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",self.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (results.count)
        return [results lastObject];
    
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
