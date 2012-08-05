//
//  Formation_Folder+Creation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder.h"

@interface Formation_Folder (Creation)

+ (Formation_Folder *)formationFolderForName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
