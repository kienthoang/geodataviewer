//
//  Formation_Folder+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder.h"

@interface Formation_Folder (Creation)

+ (Formation_Folder *)defaultFormationFolderInManagedObjectContext:(NSManagedObjectContext *)context;

#define DEFAULT_FORMATION_FOLDER_NAME @"__Imported Formations"

@end
