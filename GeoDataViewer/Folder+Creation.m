//
//  Folder+Creation.m
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Creation.h"

@implementation Folder (Creation)

+ (Folder *)folderForName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)context {
    //Create a new folder in the given student group
    Folder *folder=[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
    folder.folderName=folderName;
    folder.records=[NSSet set];
    
    return folder;
}

@end
