//
//  Formation+Creation.h
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation.h"
#import "Formation_Folder+Creation.h"

@interface Formation (Creation)

+ (Formation *)formationForInfo:(NSDictionary *)formationInfo 
      inFormationFolderWithName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Formation *)formationWithName:(NSString *)formationName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
