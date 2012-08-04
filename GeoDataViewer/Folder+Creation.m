//
//  Folder+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder+Creation.h"

@implementation Folder (Creation)

+ (Folder *)folderForName:(NSString *)folderName inStudentGroup:(Group *)studentGroup {
    //Create a new folder in the given student group
    Folder *folder=[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:studentGroup.managedObjectContext];
    folder.folderName=folderName;
    folder.group=studentGroup;
    
    return folder;
}

@end
