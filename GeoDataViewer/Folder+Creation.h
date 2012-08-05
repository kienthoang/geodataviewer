//
//  Folder+Creation.h
//  GeoFieldBook
//

//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder.h"


#import "Group.h"

@interface Folder (Creation)

+ (Folder *)folderForName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
