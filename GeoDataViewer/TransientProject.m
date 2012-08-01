//
//  TransientProject.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientProject.h"

@interface TransientProject()

@property (nonatomic,strong) Folder *nsManagedFolder;

@end

@implementation TransientProject

@synthesize folderID;
@synthesize folderDescription;
@synthesize formationFolder;
@synthesize folderName=_folderName;
@synthesize records=_records;

@synthesize nsManagedFolder=_nsManagedFolder;

- (Folder *)saveFolderToManagedObjectContext:(NSManagedObjectContext *)context {
    //Query for the folder with the same name before saving
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Folder"];
    request.predicate=[NSPredicate predicateWithFormat:@"folderName=%@",self.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    
    if (results.count)
        return [results lastObject];
    
    //Save folder
    [self saveToManagedObjectContext:context completion:^(NSManagedObject *folder){}];
    return self.nsManagedFolder;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    self.nsManagedFolder=[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
    self.nsManagedFolder.folderName=self.folderName;
}

@end
