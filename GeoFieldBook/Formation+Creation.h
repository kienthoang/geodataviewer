//
//  Formation+Creation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation.h"

@interface Formation (Creation)

+ (Formation *)formationForInfo:(NSDictionary *)formationInfo 
      inFormationFolderWithName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
