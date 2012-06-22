//
//  Folder+Creation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder.h"

@interface Folder (Creation)

+ (Folder *)folderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
