//
//  Formation+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation.h"
#import "Formation_Folder+Creation.h"

@interface Formation (Creation)

+ (Formation *)formationWithName:(NSString *)formationName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
